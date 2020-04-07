﻿////////////////////////////////////////////////////////////////////
//			ОПИСАНИЕ ОШИБКИ !!!                                   //

// Получение информации о текущем состоянии ЭККР 	///////////////
Функция СтатусРегистратора(пЭККР)
 	Возврат пЭККР.GetByteStatus;
КонецФункции
 	
// Получение кода ошибки ЭККР 						///////////////
Функция Результат(пЭККР)
	Возврат пЭККР.GetByteResult;
КонецФункции

// Получение текстовой информации об ошибке ЭККР 	///////////////
Функция СообщениеОбОшибке(пЭККР)
	Возврат пЭККР.GetTextErrorMessage;
КонецФункции

Процедура ОшибкаСообщить(пЭККР)
	ТекстОшибки				= СообщениеОбОшибке(пЭККР) 	+ Символы.ПС + Символы.ПС +
								"Байт статуса    - "	+ Строка(СтатусРегистратора(пЭККР)) + Символы.ПС +
				 	   	  		"Байт результата - "	+ Строка(Результат(пЭККР));
	Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Ошибка, "ОшибкаСообщить().ОШИБКА_ФР", ТекстОшибки, Неопределено, Неопределено, "Обработки.ТО_IKC_E260T");
	Предупреждение(ТекстОшибки, 3);
КонецПроцедуры	

Функция ПолучитьБиты_GetByteReserv(пЭККР);
	ДесятичноеЗначение			= пЭККР.GetByteReserv;
	БайтРезультат				= Новый Структура; 
	
	Если ДесятичноеЗначение>=128 Тогда 
		ДесятичноеЗначение = ДесятичноеЗначение-128;
		БайтРезультат.Вставить("Бит7", "1");
	Иначе 
		БайтРезультат.Вставить("Бит7", "0");
	КонецЕсли;		
	
	Если   ДесятичноеЗначение>=64 Тогда
		ДесятичноеЗначение = ДесятичноеЗначение-64;
		БайтРезультат.Вставить("Бит6", "1");
	Иначе 
		БайтРезультат.Вставить("Бит6", "0");
	КонецЕсли;		
	
	Если   ДесятичноеЗначение>=32 Тогда
		ДесятичноеЗначение = ДесятичноеЗначение-32;
		БайтРезультат.Вставить("Бит5", "1");
	Иначе 
		БайтРезультат.Вставить("Бит5", "0");
	КонецЕсли;		
	
	Если   ДесятичноеЗначение>=16 Тогда
		ДесятичноеЗначение = ДесятичноеЗначение-16;
		БайтРезультат.Вставить("Бит4", "1");
	Иначе 
		БайтРезультат.Вставить("Бит4", "0");
	КонецЕсли;		
	
	Если   ДесятичноеЗначение>=8 Тогда
		ДесятичноеЗначение = ДесятичноеЗначение-8;
		БайтРезультат.Вставить("Бит3", "1");
	Иначе 
		БайтРезультат.Вставить("Бит3", "0");
	КонецЕсли;		
		
	Если   ДесятичноеЗначение>=4 Тогда
		ДесятичноеЗначение = ДесятичноеЗначение-4;
		БайтРезультат.Вставить("Бит2", "1");
	Иначе 
		БайтРезультат.Вставить("Бит2", "0");
	КонецЕсли;		
	
	Если   ДесятичноеЗначение>=2 Тогда
		ДесятичноеЗначение = ДесятичноеЗначение-2;
		БайтРезультат.Вставить("Бит1", "1");
	Иначе 
		БайтРезультат.Вставить("Бит1", "0");
	КонецЕсли;	
	
	Если   ДесятичноеЗначение>=1 Тогда
		ДесятичноеЗначение = ДесятичноеЗначение-1;
		БайтРезультат.Вставить("Бит0", "1");
	Иначе 
		БайтРезультат.Вставить("Бит0", "0");
	КонецЕсли;	
	
 	Возврат	БайтРезультат;
КонецФункции	
//		                                                          //
////////////////////////////////////////////////////////////////////



Функция ОткрытьПорт() Экспорт
	
	ТО_ФР.ПараметрыФР_Очистить();
	
	пЭККР 	= ПараметрыФР.ФР_Объект;
	пМодем 	= ПараметрыФР.ФР_ОбъектМодем;
	
	//Попытка		
		пЭККР 		= Новый COMОбъект("ICSFP.ICS_EP_06");
		пЭККР.Lang 	= 1;
		пЭККР.CP866 = Ложь;
		
		// В случае отсутствия ответа на команду, драйвер не будет посылать команду повторно
	    пЭККР.RepeatCount = 0;                                                                  
	    // Коэфициент времени ожидания ответа
	    пЭККР.AnswerWaiting = 1; 
		
		Если НЕ пЭККР.FPInit(ПараметрыФР.ФР_Порт, ПараметрыФР.ФР_Скорость, 3, 3) Тогда  
			ТО_ФР.ПараметрыФР_Очистить();
			Возврат Неопределено;
			
		Иначе
		 	Версия = пЭККР.GetHardwareVersion; 
		 	Если СтрДлина(Версия) = 0 Тогда
				ОшибкаСообщить(пЭККР);
		  		Возврат ЗакрытьПорт();
			КонецЕсли; 
			
			// Закрываем служебный отчет если он открыт
			БайтСостоянияФР = ПолучитьБиты_GetByteReserv(пЭККР);
			Если БайтСостоянияФР.Бит0 = "1" Тогда
    			пЭККР.FPTransPrint("", Истина, 1); 
    		КонецЕсли;
			
			Попытка
				пЭККР.ModemStatusUpdate(Ложь);
				ПараметрыФР.ФР_IКС260_РевизияМодемаIКС = пЭККР.ModemOSRev;
			Исключение
				ПараметрыФР.ФР_IКС260_РевизияМодемаIКС = 0;	
			КонецПопытки;	
		КонецЕсли;
		
	ПараметрыФР.ФР_Объект 		= пЭККР;
	ПараметрыФР.ФР_ОбъектМодем 	= пМодем;
	
	Возврат пЭККР;
	
КонецФункции	 

Функция ЗакрытьПорт() Экспорт
	
	пЭККР = ПараметрыФР.ФР_Объект;
	
	Попытка
    	пЭККР.FPClose();
	Исключение		
	КонецПопытки;
	
	ТО_ФР.ПараметрыФР_Очистить();
	Возврат Неопределено;
	
КонецФункции

Функция ПроверитьПодключениеФР() Экспорт 
	
	пЭККР = ПараметрыФР.ФР_Объект;
	
	Если пЭККР = Неопределено Тогда Возврат Ложь	КонецЕсли;
																				
	СерийныйНомерФР = СокрЛП(ПолучитьСерийныйНомер()); 	
	Если СерийныйНомерФР <> СокрЛП(Константы.осн_КассаККМ.Получить()) Тогда		Возврат	Ложь    КонецЕсли;
	
	ДатаФР = ПолучитьДатуВремяФР();
	Если НачалоДня(ТекущаяДата())<>НачалоДня(ДатаФР) Тогда
		пЭККР=Неопределено;
		Возврат	Ложь;
	КонецЕсли; 
	
	БайтСостоянияФР = ПолучитьБиты_GetByteReserv(пЭККР);    	
	Если БайтСостоянияФР.Бит1 = "1" Или БайтСостоянияФР.Бит2 = "1" Или БайтСостоянияФР.Бит6 = "1" Тогда 
		ОшибкаСообщить(пЭККР);
		пЭККР = Неопределено;
		Возврат Ложь;
	КонецЕсли;	
	
	Возврат Истина;
КонецФункции

//Мулько 04.12.2019
Функция ОборотыФР_Z_Отчет(Рез_ОборотыФР) Экспорт
	
	Попытка
		
		пЭККР = ПараметрыФР.ФР_Объект;
		//Рез_ОборотыФР.ФР_Номер_Z_Отчета 						= Число(пЭККР.GetNumZReport)+1;
		Рез_ОборотыФР.ФР_Номер_Z_Отчета 						= Число(пЭККР.GetNumZReport);
		Рез_ОборотыФР.ФР_ДатаВремяПоследнегоОтчета				= пЭККР.GetLastDateZReport;
		Рез_ОборотыФР.ФР_СерийныйНомер 							= пЭККР.GetSerialNumber;
		Рез_ОборотыФР.ФР_ФискальныйНомер 						= пЭККР.GetFiscalNumber;
		
		Рез_ОборотыФР.ФР_ОборотиПродаж							= Число(пЭККР.GetDaySaleSum)*0.01;
		Рез_ОборотыФР.ФР_ОборотиВозвратов						= Число(пЭККР.GetDayPaySum)*0.01;
		
		Рез_ОборотыФР.ФР_ОборотиПродаж_БезНал					= Число(пЭККР.GetTurnSaleCard)*0.01;
		Рез_ОборотыФР.ФР_ОборотиПродаж_Нал						= Число(пЭККР.GetTurnSaleCash)*0.01;
		Рез_ОборотыФР.ФР_ОборотиПродаж_ПС						= Число(пЭККР.GetTurnSaleIndex5)*0.01;
		//Рез_ОборотыФР.ФР_ОборотиПродаж_Ваучер					= Число(пЭККР.GetTurnSaleIndex6)*0.01;		
		
		Рез_ОборотыФР.ФР_ОборотиВозвратов_БезНал				= Число(пЭККР.GetTurnPayCard)*0.01;
		Рез_ОборотыФР.ФР_ОборотиВозвратов_Нал					= Число(пЭККР.GetTurnPayCash)*0.01;
		Рез_ОборотыФР.ФР_ОборотиВозвратов_ПС					= Число(пЭККР.GetTurnPayIndex5)*0.01;
		//Рез_ОборотыФР.ФР_ОборотиВозвратов_Ваучер				= Число(пЭККР.GetTurnPayIndex6)*0.01;		

		Рез_ОборотыФР.ФР_КоличествоЧеков_Продажа 				= Число(пЭККР.GetSaleCheckNumber);
		Рез_ОборотыФР.ФР_КоличествоЧеков_Возврат 				= Число(пЭККР.GetPayCheckNumber);
		Рез_ОборотыФР.ФР_КоличествоАннулированныхЧеков_Продажа 	= Число(пЭККР.GetGlobCancSale);
		Рез_ОборотыФР.ФР_КоличествоАннулированныхЧеков_Возврат 	= Число(пЭККР.GetGlobCancPay);
		
		Рез_ОборотыФР.ФР_ОборотПродаж_А							= Число(пЭККР.GetTurnSaleTax_A)*0.01;
		Рез_ОборотыФР.ФР_ОборотПродаж_Б							= Число(пЭККР.GetTurnSaleTax_B)*0.01;
		Рез_ОборотыФР.ФР_ОборотПродаж_В							= Число(пЭККР.GetTurnSaleTax_C)*0.01;
		Рез_ОборотыФР.ФР_ОборотПродаж_Г							= Число(пЭККР.GetTurnSaleTax_D)*0.01;
		Рез_ОборотыФР.ФР_ОборотПродаж_Д							= Число(пЭККР.GetTurnSaleTax_E)*0.01;
		Рез_ОборотыФР.ФР_ОборотПродаж_Е							= Число(пЭККР.GetTurnSaleTax_F)*0.01;
		
		Рез_ОборотыФР.ФР_ОборотВозврат_А						= Число(пЭККР.GetTurnPayTax_A)*0.01;
		Рез_ОборотыФР.ФР_ОборотВозврат_Б						= Число(пЭККР.GetTurnPayTax_B)*0.01;
		Рез_ОборотыФР.ФР_ОборотВозврат_В						= Число(пЭККР.GetTurnPayTax_C)*0.01;
		Рез_ОборотыФР.ФР_ОборотВозврат_Г						= Число(пЭККР.GetTurnPayTax_D)*0.01;
		Рез_ОборотыФР.ФР_ОборотВозврат_Д						= Число(пЭККР.GetTurnPayTax_E)*0.01;
		Рез_ОборотыФР.ФР_ОборотВозврат_Е						= Число(пЭККР.GetTurnPayTax_F)*0.01;
		
		Рез_ОборотыФР.ФР_СтавкаНалога_А							= Число(пЭККР.GetBaseTax_A)*0.01;
		Рез_ОборотыФР.ФР_СтавкаНалога_Б							= Число(пЭККР.GetBaseTax_B)*0.01;
		Рез_ОборотыФР.ФР_СтавкаНалога_В							= Число(пЭККР.GetBaseTax_C)*0.01;
		Рез_ОборотыФР.ФР_СтавкаНалога_Г							= Число(пЭККР.GetBaseTax_D)*0.01;
		Рез_ОборотыФР.ФР_СтавкаНалога_Д							= Число(пЭККР.GetBaseTax_E)*0.01;
		//Рез_ОборотыФР.ФР_СтавкаНалога_Е							= Число(пЭККР.GetBaseTax_F)*0.01;
		
		Рез_ОборотыФР.ФР_СуммаВнесение							= Число(пЭККР.GetAvansSum)*0.01;
		Рез_ОборотыФР.ФР_СуммаИзъятие							= Число(пЭККР.GetPaymentSum)*0.01;
		
		Рез_ОборотыФР.ФР_СуммаСкидокПродажа						= Число(пЭККР.GetDiscountSale)*0.01;
		Рез_ОборотыФР.ФР_СуммаСкидокВозврат						= Число(пЭККР.GetDiscountPay)*0.01;
		
		Рез_ОборотыФР.ФР_СуммаВСейфе							= Рез_ОборотыФР.ФР_ОборотиПродаж_Нал - Рез_ОборотыФР.ФР_ОборотиВозвратов_Нал
																 + Рез_ОборотыФР.ФР_СуммаВнесение - Рез_ОборотыФР.ФР_СуммаИзъятие;
		
		Рез_ОборотыФР.Результат									= Истина;
	Исключение
	КонецПопытки;
		
    Возврат Рез_ОборотыФР;

КонецФункции	

Функция ОборотыФР (пЭККР) Экспорт 
	Рез_ОборотыФР															= Новый Структура;
	Рез_ОборотыФР.Вставить("Результат", 						Ложь);
	Рез_ОборотыФР.Вставить("ФР_ОборотиПродаж", 				0);
	Рез_ОборотыФР.Вставить("ФР_ОборотиПродаж_БезНал", 		0);
   	Рез_ОборотыФР.Вставить("ФР_ОборотиПродаж_Нал", 			0);
	Рез_ОборотыФР.Вставить("ФР_ОборотиПродаж_ПС", 			0);
	Рез_ОборотыФР.Вставить("ФР_ОборотиПродаж_Ваучер",		0);
	Рез_ОборотыФР.Вставить("ФР_ОборотиВозвратов", 			0);
	Рез_ОборотыФР.Вставить("ФР_ОборотиВозвратов_БезНал", 	0);
   	Рез_ОборотыФР.Вставить("ФР_ОборотиВозвратов_Нал", 		0);
	Рез_ОборотыФР.Вставить("ФР_ОборотиВозвратов_ПС", 		0);
	Рез_ОборотыФР.Вставить("ФР_ОборотиВозвратов_Ваучер", 	0);
	Рез_ОборотыФР.Вставить("ФР_СуммаВыручки_Нал", 			0); //Только для ФР МИНИ
	Рез_ОборотыФР.Вставить("ФР_СуммаВыручки_БезНал", 		0); //Только для ФР МИНИ
	Рез_ОборотыФР.Вставить("ФР_СуммаВыручки_ПС", 			0); //Только для ФР МИНИ
	Рез_ОборотыФР.Вставить("ФР_СуммаВыручки_Ваучер", 		0); //Только для ФР МИНИ

	Попытка
		Рез_ОборотыФР.ФР_ОборотиПродаж								= Число(пЭККР.GetDaySaleSum)*0.01;
		Рез_ОборотыФР.ФР_ОборотиВозвратов							= Число(пЭККР.GetDayPaySum)*0.01;
		
		Рез_ОборотыФР.ФР_ОборотиПродаж_БезНал						= Число(пЭККР.GetTurnSaleCard)*0.01;
		Рез_ОборотыФР.ФР_ОборотиПродаж_Нал							= Число(пЭККР.GetTurnSaleCash)*0.01;
		Рез_ОборотыФР.ФР_ОборотиПродаж_ПС							= Число(пЭККР.GetTurnSaleIndex5)*0.01;
		Рез_ОборотыФР.ФР_ОборотиПродаж_Ваучер						= Число(пЭККР.GetTurnSaleIndex6)*0.01;		
		
		Рез_ОборотыФР.ФР_ОборотиВозвратов_БезНал					= Число(пЭККР.GetTurnPayCard)*0.01;
		Рез_ОборотыФР.ФР_ОборотиВозвратов_Нал						= Число(пЭККР.GetTurnPayCash)*0.01;
		Рез_ОборотыФР.ФР_ОборотиВозвратов_ПС						= Число(пЭККР.GetTurnPayIndex5)*0.01;
		Рез_ОборотыФР.ФР_ОборотиВозвратов_Ваучер					= Число(пЭККР.GetTurnPayIndex6)*0.01;		

		Рез_ОборотыФР.Результат										= Истина;
	Исключение
	КонецПопытки;	

     Возврат Рез_ОборотыФР
КонецФункции	

функция УстановитьОператора() экспорт
	пЭККР																	= ПараметрыФР.ФР_Объект;
	
	Кассир																	= Лев(СокрЛП(глТекущийПользователь), 15);
	Результат 																= пЭККР.FPSetCashier(0, Кассир, 0, 0);
	Возврат Результат;
 Конецфункции	

 Функция ПолучитьДатуВремяФР() Экспорт
	 
	пЭККР																	= ПараметрыФР.ФР_Объект;
	ПараметрыФР.ФР_ДатаВеремяНаФР											= Дата(1,1,1);

	Попытка
		СтрокаДата 															= пЭККР.CurrentDate;
		СтрокаВремя 														= пЭККР.CurrentTime;
		ПараметрыФР.ФР_ДатаВеремяНаФР 										= ДатаИзПредставленияДМГЧМС(СтрокаДата,СтрокаВремя);
	Исключение
		ПараметрыФР.ФР_ДатаВеремяНаФР 										= Дата(1,1,1); // ошибка
	КонецПопытки;
	
	Возврат ПараметрыФР.ФР_ДатаВеремяНаФР;
КонецФункции

Функция ДатаИзПредставленияДМГЧМС(СтрокаДата,СтрокаВремя)
	
	СтрокаВремя 	= СтрЗаменить(СтрокаВремя, ":",Символы.ПС);
	СтрокаДата 		= СтрЗаменить(СтрокаДата, ".",Символы.ПС);
    р 				= СтрокаДата + Символы.ПС + СтрокаВремя ;
	    
    Возврат 
        Дата(
        Формат(Число(СтрПолучитьСтроку(р,3)),"ЧЦ=4; ЧН=0000; ЧВН=; ЧГ=") +
        Формат(Число(СтрПолучитьСтроку(р,2)),"ЧЦ=2; ЧН=00; ЧГ=; ЧВН=") +
        Формат(Число(СтрПолучитьСтроку(р,1)),"ЧЦ=2; ЧН=00; ЧВН=") +
        Формат(Число(СтрПолучитьСтроку(р,4)),"ЧЦ=2; ЧН=00; ЧВН=") +
        Формат(Число(СтрПолучитьСтроку(р,5)),"ЧЦ=2; ЧН=00; ЧГ=; ЧВН=") +
        Формат(Число(СтрПолучитьСтроку(р,6)),"ЧЦ=2; ЧН=00; ЧГ=; ЧВН=") 
        );

	    
    Возврат 
        Дата(
        Формат(Число(СтрПолучитьСтроку(р,3)),"ЧЦ=4; ЧН=0000; ЧВН=; ЧГ=") +
        Формат(Число(СтрПолучитьСтроку(р,2)),"ЧЦ=2; ЧН=00; ЧГ=; ЧВН=") +
        Формат(Число(СтрПолучитьСтроку(р,1)),"ЧЦ=2; ЧН=00; ЧВН=") +
        Формат(Число(СтрПолучитьСтроку(р,4)),"ЧЦ=2; ЧН=00; ЧВН=") +
        Формат(Число(СтрПолучитьСтроку(р,5)),"ЧЦ=2; ЧН=00; ЧГ=; ЧВН=") +
        Формат(Число(СтрПолучитьСтроку(р,6)),"ЧЦ=2; ЧН=00; ЧГ=; ЧВН=") 
        );

КонецФункции

Функция ПолучитьСерийныйНомер() Экспорт
	// Серийный номер выдаеться заводом. 
	// Уникальность контролируеться каждым заводом. 
	// Длина разная (10, 11, 12 символов).
	пЭККР = ПараметрыФР.ФР_Объект;
	ПараметрыФР.ФР_СерийныйНомер = "";
		
	Попытка
		ПараметрыФР.ФР_СерийныйНомер = пЭККР.GetSerialNumber;
	Исключение
		ПараметрыФР.ФР_СерийныйНомер = ""; // ошибка
	КонецПопытки;
	
	Возврат ПараметрыФР.ФР_СерийныйНомер;
	
КонецФункции

Функция ПолучитьФискальныйНомер() Экспорт
	// Фискальный номер выдаеться налоговой. 
	// Он уникальный в пределах Укарины.
	// Длина ограничена (10 символов).

	пЭККР																	= ПараметрыФР.ФР_Объект;
	ПараметрыФР.ФР_ФискальныйНомер                                          = "";

	Попытка
		ПараметрыФР.ФР_ФискальныйНомер 										= пЭККР.GetFiscalNumber;
	Исключение
		ПараметрыФР.ФР_ФискальныйНомер 										= ""; // ошибка
	КонецПопытки;
	
	Возврат ПараметрыФР.ФР_ФискальныйНомер;
КонецФункции

Функция ПолучитьНомерЧекаФР(пЭККР) Экспорт //06.10.2012
	НомерЧекаККМ 	= Константы.глСчетчикЧеков.Получить();
    Возврат НомерЧекаККМ;
КонецФункции

Функция ПолучитьНомерZОтчета_ТекущейСмены() Экспорт
	пЭККР																	= ПараметрыФР.ФР_Объект;
	ПараметрыФР.ФР_НомерZОтчета												= 0;

	Попытка
		ПараметрыФР.ФР_НомерZОтчета	 										= Число(пЭККР.GetNumZReport)+1;
	Исключение
		ПараметрыФР.ФР_НомерZОтчета	 										= 0; 
	КонецПопытки;
	
	Возврат ПараметрыФР.ФР_НомерZОтчета;
	
КонецФункции

Функция НулевойЧек(пЭККР) Экспорт
	//Пока Не СостояниеЭККА(Объект) Цикл  КонецЦикла; 
	пЭККР.FPSendCustomer(0, ""); 
	пЭККР.FPSendCustomer(1, "Нульовий чек");
 	Если НЕ пЭККР.FPNullCheck() Тогда
  		ОшибкаСообщить(пЭККР);
		Возврат Ложь;
	Иначе
		n=5;
		Пока НЕ пЭККР.FPOpenBox() И n<>0 Цикл  
			n=n-1;	
		КонецЦикла;	
		Возврат Истина;
	КонецЕсли;
КонецФункции // Нулевой чек

//Функция осуществляет печать Х-отчёта на ФР.
Функция Х_отчет(пЭККР) Экспорт 
	Если не пЭККР.FPDayReport(0) Тогда
		ОшибкаСообщить(пЭККР);	
		Возврат Ложь;
	Иначе                                                              
			//Сообщить ("Печать X-отчета по финансовым операциям была успешно завершена!",СтатусСообщения.Информация);
		Возврат Истина;
    КонецЕсли;
КонецФункции	

//Функция осуществляет печать Z-отчёта на ФР.
Функция Z_Отчет() Экспорт
	
	пЭККР 	= ПараметрыФР.ФР_Объект;
	пМодем 	= ПараметрыФР.ФР_ОбъектМодем;

	
	пЭККР.FPSendCustomer(0, ""); 
	пЭККР.FPSendCustomer(1, "Z-ЗВIТ"); 
	//	Проверка наличия открытого фискального чека в ККМ
	Если пЭККР.GetCheckOpened = True Тогда
		пЭККР.FPResetOrder();//отмена чека
	КонецЕсли;	
	Если НЕ пЭККР.FPDayClrReport(0) Тогда
		ОшибкаСообщить(пЭККР);	
		Возврат Ложь;
	Иначе
		пЭККР.FPOpenBox();
		Попытка
			ПечатьОтчетСостояниеМодема();
		Исключение
		КонецПопытки;
		
		Возврат Истина;
	КонецЕсли;	
КонецФункции // ZОтчет()

Функция Сумма(пЭККР, Сумма) Экспорт
	//Пока Не СостояниеЭККА(Объект) Цикл  КонецЦикла; 
	Если Сумма>0 Тогда
		пЭККР.FPSendCustomer(0, "Служб. внесення"); 
		пЭККР.FPSendCustomer(1, Формат(Сумма, "Ч6.2"));
		Если НЕ пЭККР.FPInToCash(Сумма*100) Тогда
			ОшибкаСообщить(пЭККР);
		КонецЕсли;
		пЭККР.FPOpenBox();
	ИначеЕсли Сумма < 0 Тогда  
		пЭККР.FPSendCustomer(0, "Службова видача"); 
		пЭККР.FPSendCustomer(1, Формат(-Сумма, "Ч6.2"));
		Если НЕ пЭККР.FPOutOfCash(-Сумма*100) Тогда
			ОшибкаСообщить(пЭККР);
		КонецЕсли;
		пЭККР.FPOpenBox(); // Открытие денежного ящика
	Иначе
		Возврат Ложь;
	КонецЕсли;
	Возврат Истина;
КонецФункции // Сумма()

Функция ОстатокКассы(пЭККР) Экспорт
	Попытка
		Рез													= СокрЛП(пЭККР.GetMoneyInBox);
		Если ОбщегоНазначения.ЭтоЧисло(Рез) Тогда 
			Результат										= Число(Рез);
		Иначе 	
			Результат										= 0;
		КонецЕсли;	
	Исключение 	
		Результат											= 0;
	КонецПопытки;
	
	Возврат Результат;
КонецФункции

Функция ОткрытьДенежныйЯщик(пЭККР) Экспорт 
	пЭККР.FPOpenBox(); // Открытие денежного ящика
КонецФункции

// НЕ ИСПОЛЬЗУЮ. ОбъемТовараВПрайсе > ОбъемаПамятиФР. В описании сказано, что регистрацию товара нужно делать до начала смены.     
Функция РегистрацияАртикула_в_ФР(СтрокаТЧ) Экспорт
	Возврат Истина;
КонецФункции

Функция ПроверкаОборотовФР_ДоОткрытияЧека(пЭККР, ПараметрыЧекаККМ) Экспорт
	// ++ VS Ализируем ответил ли мне фискальник и правильные цифры он мне показывает.
	ПараметрыЧекаККМ.ФР_ОбротыДоЧека											= 0;
	ПараметрыЧекаККМ.ФР_ОбротыПослеЧека											= 0;
	
	Попытка																			
		Если ПараметрыЧекаККМ.ЭтоЧекПродажи Тогда 
			ПараметрыЧекаККМ.ФР_ОбротыДоЧека									= Число(пЭККР.GetDaySaleSum)*0.01;
			//ПараметрыЧекаККМ.ФР_ОборотыПослеЧека									= Число(пЭККР.GetDaySaleSum)*0.01;
		Иначе	
			ПараметрыЧекаККМ.ФР_ОбротыДоЧека									= Число(пЭККР.GetDayPaySum)*0.01;                   
			//ПараметрыЧекаККМ.ФР_ОбротыПослеЧека									= Число(пЭККР.GetDayPaySum)*0.01;                   
		КонецЕсли;
	Исключение
		ПараметрыЧекаККМ.ФР_ОбротыДоЧека										= 0;
		//ПараметрыЧекаККМ.ФР_ОбротыПослеЧека										= 0;
		Возврат Ложь;
	КонецПопытки;
	
	Если пЭККР.GetByteStatus<>0 Или пЭККР.GetByteResult<>0 Тогда 
		ОшибкаСообщить(пЭККР);
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
КонецФункции

Функция ОткрытьЧек(пЭККР, ПараметрыЧекаККМ) Экспорт 
	Попытка	
		// Проверим овечает ли ФР 
		
		Если пЭККР.GetByteStatus<>0 Или пЭККР.GetByteResult<>0 Тогда 
			ОшибкаСообщить(пЭККР);
			Возврат Ложь;
		КонецЕсли;	
	Исключение
		Возврат Ложь;
	КонецПопытки;
	
	Возврат Истина
КонецФункции	

Функция ПечатьКоментария(пЭККР, КомментарийМассив, ОткрытьЧекВозврата) Экспорт 
	Попытка	
		Для Каждого СтрокаКомментария Из КомментарийМассив Цикл
	    	Результат = пЭККР.FPComment(СтрокаКомментария, ОткрытьЧекВозврата);
		КонецЦикла;
	Исключение
		Результат = Ложь;
	КонецПопытки;		
	
	Возврат Результат;
КонецФункции	

Функция ПечатьСтрокиЧека(пЭККР, ПризнакВозврата ,СтрокаТЧ) Экспорт
	// подготовка переменных
	Артикул					= СтрокаТЧ.Код;
	КолТовара				= СтрокаТЧ.Количество;
	ЦенаТовара				= СтрокаТЧ.Цена*100;
	НаименованиеТовра		= СтрокаТЧ.DATASTR2;      
	СкидкаНаТовар			= СтрокаТЧ.СкидкаСумма+СтрокаТЧ.СкидкаБК;
	
	// Дьяченко 25.10.2019
	// Возврат товара после округления по математическим правилам получаем наценку
	//Если СкидкаНаТовар < 0 Тогда
	//	ЦенаТовара = ЦенаТовара - СкидкаНаТовар * 100;
	//	СкидкаНаТовар = 0;
	//КонецЕсли;	
	
	Если  СтрокаТЧ.СтавкаНДС=Перечисления.СтавкиНДС.НДС20 Тогда 
		ПризнакСтавкиНДС	= 0;		
	ИначеЕсли СтрокаТЧ.СтавкаНДС=Перечисления.СтавкиНДС.БезНДС Тогда 
		ПризнакСтавкиНДС	= 1;
	ИначеЕсли СтрокаТЧ.СтавкаНДС=Перечисления.СтавкиНДС.НДС7 Тогда 	
		ПризнакСтавкиНДС	= 2;
	ИначеЕсли СтрокаТЧ.СтавкаНДС=Перечисления.СтавкиНДС.Акциз5_НДС20 Тогда 	
		ПризнакСтавкиНДС	= 3;
	КонецЕсли;
	
	// вывод на печать
	Попытка	
		Если Не ПризнакВозврата Тогда
			// продажа товара на ККМ
			пЭККР.FPSaleEx(КолТовара, 0, 0, ЦенаТовара, ПризнакСтавкиНДС, 0, НаименованиеТовра, Артикул);
		Иначе
			// возврат товара на ККМ
			пЭККР.FPPayMoneyEx(КолТовара, 0, 0, ЦенаТовара, ПризнакСтавкиНДС, 0, НаименованиеТовра, Артикул);
		КонецЕсли;
		
		Если СкидкаНаТовар > 0 Тогда
			Если НЕ пЭККР.FPDiscount(0, СкидкаНаТовар*100, "") Тогда
				ОшибкаСообщить(пЭККР);
				пЭККР.FPResetOrder(); //отмена чека
				Возврат Ложь;
			КонецЕсли;
		ИначеЕсли СкидкаНаТовар < 0 Тогда	
			Если НЕ пЭККР.FPDiscount(5, (-1)*СкидкаНаТовар*100, "ЗАОКРУГЛЕННЯ") Тогда
				ОшибкаСообщить(пЭККР);
				пЭККР.FPResetOrder(); //отмена чека
				Возврат Ложь;
			КонецЕсли;
		КонецЕсли;
		
		Возврат Истина;
	Исключение
		Возврат Ложь;
	КонецПопытки;	

КонецФункции

//Скидка на весь чек
Функция ПечатьСкидкиНаЧек(пЭККР, СуммаПС) экспорт
	Попытка
		пЭККР.FPDiscount(4, СуммаПС*100, "ЗАОГРУГЛЕННЯ");    
		Возврат Истина
	Исключение
		ОшибкаСообщить(пЭККР);
		Возврат Ложь
	КонецПопытки;	
Конецфункции

Функция ЗакрытьЧек(пЭККР, ПараметрыЧекаККМ) Экспорт
																				
	РезультатERROR															= Истина;
	Попытка
		
		Если ПараметрыЧекаККМ.ФО_СуммаПоКарте>0 И РезультатERROR Тогда
			пЭККР.FPPayment(0, 0, 0, 1);  // Картой
			
			ПечатьКоментария(пЭККР, ПараметрыЧекаККМ.POSтерминал_ТекстДляЧекаФР, ПараметрыЧекаККМ.ЭтоЧекВозврата);	

			пЭККР.FPPayment(0, ПараметрыЧекаККМ.ФО_СуммаПоКарте*100, 0, 1);  // Картой
			
			Если пЭККР.GetByteStatus<>0 Или пЭККР.GetByteResult<>0  Тогда 
				РезультатERROR												= Ложь; 	
			КонецЕсли;
		КонецЕсли;

		Если ПараметрыЧекаККМ.ФО_СуммаВаучером>0 И РезультатERROR Тогда
			пЭККР.FPPayment(5, ПараметрыЧекаККМ.ФО_СуммаВаучером*100, 0, 1);  //Ваучер 
			
			Если пЭККР.GetByteStatus<>0 Или пЭККР.GetByteResult<>0 Тогда 
				РезультатERROR												= Ложь; 	
			КонецЕсли;
		КонецЕсли;	

		
		
		Если ПараметрыЧекаККМ.ФО_СуммаСертификатом>0 И РезультатERROR Тогда
			пЭККР.FPPayment(4, ПараметрыЧекаККМ.ФО_СуммаСертификатом*100, 0, 1);  //ПС 
			
			Если пЭККР.GetByteStatus<>0 Или пЭККР.GetByteResult<>0 Тогда 
				РезультатERROR												= Ложь; 	
			КонецЕсли;
		КонецЕсли;	
		
		
		Если ПараметрыЧекаККМ.ФО_СуммаНалички>0 И РезультатERROR Тогда
			пЭККР.FPPayment(3, ПараметрыЧекаККМ.ФО_СуммаНалички*100, 0, 1);  // Наличкой
			
			Если пЭККР.GetByteStatus<>0 Или пЭККР.GetByteResult<>0  Тогда 
				РезультатERROR												= Ложь; 	
			КонецЕсли;
		КонецЕсли;
		
		// Открытие денежного ящика
	    n=3;
		Пока n<>0 Цикл  
			пЭККР.FPOpenBox();
			n=n-1;	
		КонецЦикла;
	Исключение
		РезультатERROR														= Ложь
	КонецПопытки;
	
	Возврат РезультатERROR;	
КонецФункции	

Функция ПроверкаОборотовФР_ПослеЗакарытияЧека(пЭККР, ПараметрыЧекаККМ, КоличествоПопыток=0, ВыдаватьПредупреждение=Истина) Экспорт 
	///////////// Анализаируем пробился ли чекв ФР. Если нет идем на завершение работы.
	Результат															= Ложь;
	ПараметрыЧекаККМ.ФР_ОбротыПослеЧека									= 0;
	СуммаПоЧеку															= ПараметрыЧекаККМ.ФО_СуммаЧекаИтого;

	Попытка
		Если ПараметрыЧекаККМ.ЭтоЧекПродажи Тогда
			ПараметрыЧекаККМ.ФР_ОбротыПослеЧека							= Число(пЭККР.GetDaySaleSum)*0.01;
			Результат													= ((ПараметрыЧекаККМ.ФР_ОбротыПослеЧека-ПараметрыЧекаККМ.ФР_ОбротыДоЧека)=СуммаПоЧеку);
		Иначе
			ПараметрыЧекаККМ.ФР_ОбротыПослеЧека							= Число(пЭККР.GetDayPaySum)*0.01;	
			Результат													= ((ПараметрыЧекаККМ.ФР_ОбротыПослеЧека-ПараметрыЧекаККМ.ФР_ОбротыДоЧека)=СуммаПоЧеку);
		КонецЕсли;
	Исключение
		Результат														= Ложь;                      
	КонецПопытки;	
	
	
	
	Если НЕ Результат Тогда 
		Если ВыдаватьПредупреждение Тогда
			Результат													= ВыводСообщенияПользователю(	ПараметрыЧекаККМ.ЭтоЧекВозврата, 
																										СуммаПоЧеку, 
																										ПараметрыЧекаККМ.ФР_ОбротыДоЧека, 
																										ПараметрыЧекаККМ.ФР_ОбротыПослеЧека,
																										КоличествоПопыток);
		КонецЕсли;																								
	КонецЕсли;		
		
	Возврат Результат;
	
КонецФункции


Функция ВыводСообщенияПользователю(ПризнакВозврата, СуммаПоЧеку, ОборотыПродаж_ДоЧека, ОборотыПродаж_ПослеЧека, КоличествоПопыток=0)
	ТекстСообщения			= "ВНИМАНИЕ !!! Нет подтверждения от ФР о закрытии чека !!!" + Символы.ПС + Символы.ПС;
	Если ПризнакВозврата Тогда 
	   	ТекстСообщения 		= ТекстСообщения+  "ПОДРОБНО:" 			+ Символы.ПС +  
								"ЧекВозвратаНаСумму 			= " 		+ Формат(СуммаПоЧеку,"ЧДЦ=2; ЧН=; ЧВН=") 			+ Символы.ПС +
								"ОборотыПродаж_ДоЧека			= " 		+ Формат(ОборотыПродаж_ДоЧека,"ЧДЦ=2; ЧН=; ЧВН=")		+ Символы.ПС +
								"ОборотыПродаж_ПослеЧека 		= " 		+ Формат(ОборотыПродаж_ПослеЧека,"ЧДЦ=2; ЧН=; ЧВН=")		+ Символы.ПС + Символы.ПС+
								"НЕОБХОДИМО ВЫПОЛНИТЬ:" 																+ Символы.ПС + 
                                " 1. Выключить ФР / Подождать 10 секунд / Включить ФР;" 								+ Символы.ПС +
								" 2. Нажимаем кнопку <ДА>;" 															+ Символы.ПС +
								" 3. Если ФР НЕ отвечает, для перезапуска 1С нажимаем кнопку <НЕТ>;" 					+ Символы.ПС +
								" 4. Если не помогло, звоните админу или в службу поддержки;" 							+ Символы.ПС + Символы.ПС + 
                                "ВОПРОС: Попробуем получить данные с ФР повторно ???";
								//Мулько 18.10.2019
								Если КоличествоПопыток > 0 тогда
									ТекстСообщения = ТекстСообщения + Символы.ПС +"
									|КОЛИЧЕСТВО ПОПЫТОК ОСТАЛОСЬ: " + Строка(КоличествоПопыток);
								КонецЕсли;	

    Иначе 
        ТекстСообщения 		= ТекстСообщения+  "ПОДРОБНО:" 			+ Символы.ПС +
								"ЧекПродажиНаСумму 				= " 		+ Формат(СуммаПоЧеку,"ЧДЦ=2; ЧН=; ЧВН=") 			+ Символы.ПС +
								"ОборотыПродаж_ДоЧека			= " 		+ Формат(ОборотыПродаж_ДоЧека,"ЧДЦ=2; ЧН=; ЧВН=")		+ Символы.ПС +
								"ОборотыПродаж_ПослеЧека		= " 		+ Формат(ОборотыПродаж_ПослеЧека,"ЧДЦ=2; ЧН=; ЧВН=")		+ Символы.ПС + Символы.ПС+
								"НЕОБХОДИМО ВЫПОЛНИТЬ:" 																+ Символы.ПС + 
                                " 1. Выключить ФР / Подождать 10 секунд / Включить ФР;" 								+ Символы.ПС +
								" 2. Нажимаем кнопку <ДА>;" 															+ Символы.ПС +
								" 3. Если ФР НЕ отвечает, для перезапуска 1С нажимаем кнопку <НЕТ>;" 					+ Символы.ПС +
								" 4. Если не помогло, звоните админу или в службу поддержки;" 							+ Символы.ПС + Символы.ПС + 
                                "ВОПРОС: Попробуем получить данные с ФР повторно ???";
								Если КоличествоПопыток > 0 тогда
									ТекстСообщения = ТекстСообщения + Символы.ПС +"
									|КОЛИЧЕСТВО ПОПЫТОК ОСТАЛОСЬ: " + Строка(КоличествоПопыток);
								КонецЕсли;	
	КонецЕсли;

	
	Режим = РежимДиалогаВопрос.ДаНет;
	Ответ = Вопрос(ТекстСообщения, Режим, 0,,"ВНИМАНИЕ !!! Не пройден контроль печати чека !!!");
	Если Ответ = КодВозвратаДиалога.Нет Тогда
   		Возврат Неопределено;
	Иначе
		Предупреждение("Необходимо ВЫКЛ. а потом ВКЛ. ФР !!!");
		Возврат Ложь;
	КонецЕсли;

	
КонецФункции	

////Мулько 11.11.2019
Функция ПолучитьОборотыФР_АварийныйЧек(пЭККР, ПараметрыЧекаККМ) Экспорт
	// ++ VS Ализируем ответил ли мне фискальник и правильные цифры он мне показывает.
	ПараметрыЧекаККМ.ФР_ОбротыПослеЧека											= 0;
	
	Попытка																			
		Если ПараметрыЧекаККМ.ЭтоЧекПродажи Тогда 
			ПараметрыЧекаККМ.ФР_ОбротыПослеЧека									= Число(пЭККР.GetDaySaleSum)*0.01;
		Иначе	
			ПараметрыЧекаККМ.ФР_ОбротыПослеЧека									= Число(пЭККР.GetDayPaySum)*0.01;                   
		КонецЕсли;
	Исключение
		ПараметрыЧекаККМ.ФР_ОбротыПослеЧека										= 0;
		Возврат Ложь;
	КонецПопытки;
	
	Если пЭККР.GetByteStatus<>0 Или пЭККР.GetByteResult<>0 Тогда 
		ОшибкаСообщить(пЭККР);
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
КонецФункции

// *Функция осуществляет аннулирование текущего открытого чека на ФР.
Функция АннулироватьЧек(пЭККР) Экспорт

	// Аннулировать чек
	Попытка
		пЭККР.FPPayment(0,0,1,0);// Закрытие нефискального чека (чека комментариев)
		Возврат Истина;
	Исключение
		пЭККР.FPResetOrder();//отмена чека
		//Объект.ОписаниеОшибки = НСтр("ru='Ошибка ';uk='Помилка '")+ пЭККР.LastErrorText ;
		//Результат = мОшибкаНеизвестно;
		Возврат Ложь;
	КонецПопытки;

	//Возврат Результат;

КонецФункции 

Функция ПолнаяАннуляцияЧека(пЭККР) Экспорт
	БайтСостоянияФР				= ПолучитьБиты_GetByteReserv(пЭККР);
	Если БайтСостоянияФР.Бит6="1" Тогда
		Попытка
			пЭККР.FPResetOrder();
			Возврат Истина;
		Исключение	
			ОшибкаСообщить(пЭККР);
			Возврат Ложь
		КонецПопытки;	
	КонецЕсли;	
КонецФункции	

//////////////////////////////////////////////////////////////////////////////////////////////
//                        ВЫВОД НА ДИСПЛЕЙ ФР !!!                                           //
// *UKN Функция осуществляет вывод строки на две строки диспля ФР
//
Функция ДисплейВерхВниз(пЭККР, Данные1 ,Данные2) Экспорт
	Попытка
		пЭККР.FPSendCustomer(0, Лев(Данные1, 20)); 
		пЭККР.FPSendCustomer(1, Лев(Данные2, 20));
		Возврат Истина
	Исключение
		Возврат Ложь
	КонецПопытки;	
КонецФункции 
//                                                                                         	//
//////////////////////////////////////////////////////////////////////////////////////////////

// *Можно печатать сколько угодно копий
Функция ПечатьКопииПоследнегоФискальногоЧека(пЭККР) Экспорт
	Результат = Ложь;
	Попытка
		Результат	= пЭККР.FPCopyLastCheck();
		Если Результат Тогда
			Возврат Истина
		Иначе 
			Возврат Ложь
		КонецЕсли;	

	Исключение
		Возврат Ложь // ошибка
	КонецПопытки;
	
КонецФункции


// НЕ РАБОТАЕТ ПОКА!!!
// + UKN Функция осуществляет печать полного периодического отчета по датам
Функция ОтчетПоНалоговымСтавкамЗаПериод(пЭККР, С_Даты, По_Дату) Экспорт
	//Объект.Драйвер.FPPrintEAN13(С_Даты); //метод есть в коде передаем строку
	Возврат Истина;
КонецФункции //

// *UKN Функция осуществляет печать короткого периодического отчета по датам
Функция КороткийОтчетПоДатам(пЭККР, С_Даты, По_Дату) Экспорт
	
	Если НЕ пЭККР.FPPeriodicReportShort(0, С_Даты, По_Дату) Тогда
		ОшибкаСообщить(пЭККР); 
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
	
КонецФункции //

// *UKN Функция осуществляет печать полного периодического отчета по датам
Функция ПолныйОтчетПоДатам(пЭККР, С_Даты, По_Дату) Экспорт
	
	Если НЕ пЭККР.FPPeriodicReport(0, С_Даты, По_Дату) Тогда
		ОшибкаСообщить(пЭККР);
		Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
КонецФункции //

// *UKN Функция осуществляет печать короткого периодического отчета по номерам
Функция КороткийОтчетПоНомерам(пЭККР, С_Номера, По_Номер) Экспорт
	
	Предупреждение("Функция не поддерживается! 
	|Используйте полный отчет по номерам!", 2);
	Возврат Истина;
	
 
	Если (С_Номера > 9999) или ( С_Номера < 1) Тогда
		 Предупреждение("Неверный диапазон номеров Z отчетов"); Возврат Ложь;
	КонецЕсли;
	Результат=пЭККР.printRepByNum(С_Номера, По_Номер);
	Если пЭККР.LastError<>0 Тогда 
		//Объект.Драйвер.ClosePort(); 
		Предупреждение(пЭККР.LastErrorText); Возврат Ложь;
	Иначе
		Возврат Истина;
	КонецЕсли;
КонецФункции //

// *UKN Функция осуществляет печать полного периодического отчета по номерам
Функция ПолныйОтчетПоНомерам(пЭККР, С_Номера, По_Номер) Экспорт
	
	Если (С_Номера > 3600) или ( С_Номера < 1) или (По_Номер > 3600) или ( По_Номер < С_Номера) Тогда
		Предупреждение("Неверный диапазон номеров Z отчетов"); 
		Возврат Ложь;
	КонецЕсли;
		 
	Результат	= пЭККР.FPPeriodicNumberReport(0, С_Номера, По_Номер);
	Если Не Результат Тогда 
		ОшибкаСообщить(пЭККР);
		Возврат Ложь;
	КонецЕсли;
	
	Возврат Истина;
КонецФункции //

Функция ОткрытьЗакрытьНефискальныйЧек(пЭККР, ОткрытьЗакрыть) Экспорт
	
	Если НЕ ОткрытьЗакрыть Тогда 	
		БайтСостоянияФР				= ПолучитьБиты_GetByteReserv(пЭККР);
		Если БайтСостоянияФР.Бит0="1" Тогда
			пЭККР.FPTransPrint("", Истина, 1); 
		КонецЕсли;
	КонецЕсли;

	Возврат Истина;
КонецФункции

// *Функция осуществляет построчную печать нефискального чека из переданного массива строк.
Функция НапечататьСтроки(пЭККР, МассивСтрок, Ширина) Экспорт
	
	Ширина    = 36;
	Для Каждого СтрокаМассива Из МассивСтрок Цикл
		// Функция печати текстовой информации в чеке
		пЭККР.FPTransPrint(Лев(СтрокаМассива, Ширина), Ложь, 1); // Печать текста в чеке
	КонецЦикла;
	пЭККР.FPTransPrint("", Истина, 1); // Печать текста в чеке
	Возврат Истина
КонецФункции // НапечататьСтроки()

//Мулько К.П.
Функция ПолучитьСостояниеМодема() Экспорт 
	
	пЭККР                                                                   = ПараметрыФР.ФР_Объект;
	пМодем                                                                  = ПараметрыФР.ФР_ОбъектМодем;
		
	СтруктураОтвета = Новый Структура;
	СтруктураОтвета.Вставить("ЕстьДанные", Ложь);
	
	Если пЭККР=Неопределено Тогда
		Возврат СтруктураОтвета;
	КонецЕсли;
	
	Попытка
		Если пЭККР.ModemStatusUpdate(Ложь) Тогда 
			ПоследнийПакетСчитанИзРРО										= пЭККР.ModemPID_LastWrite;
			ПоследнийПереданыйПакет											= пЭККР.ModemPID_LastSend;
			ДатаПоследнегоПакета											= пЭККР.ModemFirstUnsendPIDDateTime;
			
			ДатаНеОтправленного												= ДатаИзПредставленияДМГЧМС(Лев(ДатаПоследнегоПакета,10), "00:00:00");
		КонецЕсли;	
	Исключение
		Возврат СтруктураОтвета;
	КонецПопытки;	
	
	СтруктураОтвета.ЕстьДанные = Истина;
	
	Если ПоследнийПакетСчитанИзРРО=ПоследнийПереданыйПакет Тогда 
		СтруктураОтвета.Вставить("ПакетыОтправлены", Истина);
		СтруктураОтвета.Вставить("ДатаОтправки", ДатаПоследнегоПакета);
	ИначеЕсли НачалоДня(ТекущаяДата())-ДатаНеОтправленного=0 Тогда 
		СтруктураОтвета.Вставить("ПакетыОтправлены", Истина);
		СтруктураОтвета.Вставить("ДатаОтправки", ДатаПоследнегоПакета);
	Иначе
		СтруктураОтвета.Вставить("ПакетыОтправлены", Ложь);
		СтруктураОтвета.Вставить("ДатаОтправки", ДатаПоследнегоПакета);
	КонецЕсли;	
	
	Возврат СтруктураОтвета;
	
КонецФункции	

Функция ПечатьОтчетСостояниеМодема() Экспорт 
	пЭККР                                                                   = ПараметрыФР.ФР_Объект;
	пМодем                                                                  = ПараметрыФР.ФР_ОбъектМодем;
	
	Если пЭККР = Неопределено Тогда   										Возврат Ложь;	КонецЕсли;
	
	Попытка
		Если пЭККР.ModemStatusUpdate(Ложь) Тогда 
			ПоследнийПакетСчитанИзРРО										= пЭККР.ModemPID_LastWrite;
			ПоследнийПереданыйПакет											= пЭККР.ModemPID_LastSend;
			ДатаПоследнегоПакета											= пЭККР.ModemFirstUnsendPIDDateTime;
			
			ДатаНеОтправленного												= ДатаИзПредставленияДМГЧМС(Лев(ДатаПоследнегоПакета,10), "00:00:00");
			
			МассивСтрок														= Новый Массив;
			МассивСтрок.Добавить(" ");
			МассивСтрок.Добавить("**********************");	
			Если ПоследнийПакетСчитанИзРРО=ПоследнийПереданыйПакет Тогда 
				МассивСтрок.Добавить("*****    ВІТАЮ    ****");
				МассивСтрок.Добавить("ВСІ ПАКЕТИ відправ");
				МассивСтрок.Добавить("ленні на еквайринг !!!");
			ИначеЕсли НачалоДня(ТекущаяДата())-ДатаНеОтправленного=0 Тогда 
				МассивСтрок.Добавить("*****    ВІТАЮ    ****");
				МассивСтрок.Добавить("МАЙЖЕ ВСІ ПАКЕТИ відп" );
				МассивСтрок.Добавить("равленні на еквайринг!");  
				МассивСтрок.Добавить("ВСІ ПАКЕТИ будуть");
				МассивСтрок.Добавить("відправленні АВТОМАТ.");
				МассивСтрок.Добавить("пізніше або завтра!");
				МассивСтрок.Добавить("**********************");
				МассивСтрок.Добавить("Дата першого не ");
				МассивСтрок.Добавить("відправленного пакету:");
				МассивСтрок.Добавить("   " + ДатаПоследнегоПакета);
			Иначе
				МассивСтрок.Добавить("*****    УВАГА    ****");
				МассивСтрок.Добавить("**********************");
				МассивСтрок.Добавить("Більше доби дані з РРО");
				МассивСтрок.Добавить("не відправляються на");
				МассивСтрок.Добавить("еквайринг !!!");
				МассивСтрок.Добавить("**********************");
				МассивСтрок.Добавить("Дата першого не ");
				МассивСтрок.Добавить("відправленного пакету:");
				МассивСтрок.Добавить("   " + ДатаПоследнегоПакета);
		
				МассивСтрок.Добавить(" ");
				МассивСтрок.Добавить("**********************");
				МассивСтрок.Добавить("***** ОБОВ'ЯЗКОВО ****");
				МассивСтрок.Добавить("**********************");
				МассивСтрок.Добавить("Зверніться до ");
				МассивСтрок.Добавить("сист. адміністратора!");
				МассивСтрок.Добавить("----------------------");
			КонецЕсли;
			МассивСтрок.Добавить("**********************");
			МассивСтрок.Добавить(" ");
			
			//МассивСтрок.Добавить("Дата останньої успішної передачі пакетів:");
			//МассивСтрок.Добавить("   " + ДатаПоследнегоПакета);
			МассивСтрок.Добавить("Всього пакетів в РРО:");
			МассивСтрок.Добавить("   " + СокрЛП(ПоследнийПакетСчитанИзРРО));
			МассивСтрок.Добавить("Відправлено пакетів:");
			МассивСтрок.Добавить( "   " + СокрЛП(ПоследнийПереданыйПакет));

			МассивСтрок.Добавить(" ");
			МассивСтрок.Добавить("**********************");

			
			
			
			//МассивСтрок							= Новый Массив;
			//Если НачалоДня(ТекущаяДата())-ДатаНеОтправленного>=24*60*60 И ДатаНеОтправленного<>Дата(2136,02,07) И ДатаНеОтправленного<>Дата(2000,01,01) Тогда 
			//	МассивСтрок.Добавить(" ");
			//	МассивСтрок.Добавить("!!!  УВАГА  !!!");
			//	МассивСтрок.Добавить("Більше доби дані з РРО");
			//	МассивСтрок.Добавить("не відправляються на ");
			//	МассивСтрок.Добавить("еквайринг!");
			//	МассивСтрок.Добавить(" ");
			//	МассивСтрок.Добавить("!!! ОБОВ'ЯЗКОВО !!! ");
			//	МассивСтрок.Добавить("Зверніться до");
			//	МассивСтрок.Добавить("сист. адміністратора!");
			//	МассивСтрок.Добавить("------------------------");
			//  КонецЕсли;
			//МассивСтрок.Добавить(" ");
			//МассивСтрок.Добавить("Всього записаних пакетів із РРО:");
			//МассивСтрок.Добавить(ПоследнийПакетСчитанИзРРО);
			//МассивСтрок.Добавить(" ");
			//МассивСтрок.Добавить("Останній відправлений пакет:");
			//МассивСтрок.Добавить(ПоследнийПереданыйПакет);
			//МассивСтрок.Добавить(" ");
			//МассивСтрок.Добавить("Дата/час першого не відправленого");
			//МассивСтрок.Добавить("пакету: "+ДатаПоследнегоПакета);
			
						
			
			НапечататьСтроки(пЭККР, МассивСтрок, 50);
		КонецЕсли;	
	Исключение
		Возврат Ложь
	КонецПопытки;	
	
	Возврат Истина;
КонецФункции	


Функция ПечатьШК(пЭККР) Экспорт 
			
	Если пЭККР = Неопределено Тогда   
		Возврат Ложь;
	КонецЕсли;
	
	//ОткрытьЗакрытьНефискальныйЧек(пЭККР, Истина);
	//
	//МассивСтрок										= Новый Массив;
	//МассивСтрок.Вставить("Печать ШК: 1110305292600");
	//НапечататьСтроки(пЭККР, МассивСтрок, Ширина)
	//
	//ОткрытьЗакрытьНефискальныйЧек(пЭККР, Ложь);

	Результат = пЭККР.FPComment("Печать ШК: 1110305292600", Ложь);
	
	пЭККР.FPPrintEAN13("1110305292600"); 

	пЭККР.FPPayment(0,0,1,0);
	Возврат Истина;
КонецФункции	


Функция РегистрацияДопФормОплаты(пЭККР) Экспорт 
	Если НЕ пЭККР.GetSmenaOpened Тогда 
		РЕЗ = пЭККР.FPSetPayName(0, "5" ,"СЕРТИФІКАТ");
		РЕЗ = пЭККР.FPSetPayName(0, "6" ,"ВАУЧЕР");
	КонецЕсли;
КонецФункции	
	

