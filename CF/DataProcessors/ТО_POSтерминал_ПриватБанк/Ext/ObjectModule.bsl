﻿
////////////////////////////////////////////////////////////////////
//			ОПИСАНИЕ ОШИБКИ !!!                                   //


// Получение текстовой информации об ошибке ЭККР 	///////////////

Функция ОшибкаPOS_Сообщить(пPOSтерминал, ДопТекстОшибки="", ВыводПарметровПодключенияPOS=Ложь, НеВыводитьОшибку=Ложь)
	ТекстОшибки				= "*";
	LastErrorDescription 	= "*";
	RC						= "*";
	LEC						= "*";
	LastResult				= "*";
	AddData					= "*";
	
	Попытка
		LastResult				= СокрЛП(пPOSтерминал.LastResult());
		RC						= СокрЛП(пPOSтерминал.ResponseCode);
		LEC						= СокрЛП(пPOSтерминал.LastErrorCode());
		LastErrorDescription 	= СокрЛП(пPOSтерминал.LastErrorDescription);
		ТекстAddData			= СокрЛП(пPOSтерминал.AddData);
		
		СтрокиВывода = "";
		СтрокаВывода = "";
		Массив = ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(ТекстAddData, " ");
		Для Каждого ЭлементМассива Из Массив Цикл 
			Если (СтрДлина(СтрокаВывода) + СтрДлина(ЭлементМассива) + 1) > 21 Тогда 
				СтрокиВывода = СтрокиВывода + СтрокаВывода + Символы.ПС;
				СтрокаВывода = "";
				СтрокаВывода = ЭлементМассива;
			Иначе
				СтрокаВывода = СтрокаВывода + " " +ЭлементМассива;
			КонецЕсли;	
		КонецЦикла;
		
		Если НЕ ПустаяСтрока(СтрокаВывода) Тогда 
			СтрокиВывода = СтрокиВывода + СтрокаВывода;	
		КонецЕсли;	
		AddData = СтрокиВывода;
	Исключение
	КонецПопытки;	
	
	ПолныйТекст = ДопТекстОшибки + Символы.ПС +  Символы.ПС +
				" LastResult: " + LastResult+ ";" + Символы.ПС +
				" LastErrorCode: " + LEC+ ";" + Символы.ПС +
				" LastErrorDescription: " + LastErrorDescription+ ";" + Символы.ПС +
				" ResponseCode: " + RC+ ";" + Символы.ПС +
				" AddData: " + AddData+ ";";
				 //"LastResult: " + LastResult+ "; LastErrorCode: " + LEC+"; LastErrorDescription: " + LastErrorDescription+"; ResponseCode: " + RC; 
	
    Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Предупреждение, "ОшибкаPOS_Сообщить()", ПолныйТекст, Неопределено, Неопределено, "Обработки.ТО_POSтерминал_ПриватБанк");
	
	Если НЕ НеВыводитьОшибку Тогда
		Предупреждение(ПолныйТекст,,"ERROR POS-терминал!");
	КонецЕсли;
	
КонецФункции	
//		                                                          //
////////////////////////////////////////////////////////////////////

Функция WaitPOSResponse(пPOSтерминал, ВремяОжидания = 200)
																			
	ВремяОжиданияPOS = ВремяОжидания;
	ВремяЗавершенияОжиданияPOS = ТекущаяДата()+ВремяОжиданияPOS;
	Пока Истина Цикл 
		LastResult = пPOSтерминал.LastResult();
		Если LastResult <> 2 Тогда 
			Возврат ?(LastResult = 0, 0, -1);
		КонецЕсли;	
		
		Если ТекущаяДата() > ВремяЗавершенияОжиданияPOS Тогда 
			Предупреждение("Перевищений час очікування відповіді терміналу!");
			Возврат -1
		КонецЕсли;	
	КонецЦикла;	
КонецФункции	

Функция ПолучитьИнфоТерминала(ПараметрыPOSтерм) Экспорт
	
	пPOSтерминал = ПараметрыPOSтерм.POSтерминал_Объект;	
	пPOSтерминал.POSGetInfo();
	ПараметрыPOSтерм.POSтерминал_LastResult = WaitPOSResponse(пPOSтерминал, 10000);
	Если ПараметрыPOSтерм.POSтерминал_LastResult = 0 Тогда 
		ПараметрыPOSтерм.POSтерминал_СтрокаИнфо = пPOSтерминал.TerminalInfo;
		Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Предупреждение, "ПолучитьИнфоТерминала()", ПараметрыPOSтерм.POSтерминал_СтрокаИнфо, Неопределено, Неопределено, "Обработки.ТО_POSтерминал_ПриватБанк");
        Возврат Истина;                                 
    КонецЕсли; 
			
КонецФункции	

Функция ОткрытьПорт(ПараметрыPOSтерм, НеВыводитьОшибку=Ложь) Экспорт
	
	ТО_Терминал.ПараметрыPOSтерм_Очистить(ПараметрыPOSтерм);
	
	пPOSтерминал																	= ПараметрыPOSтерм.POSтерминал_Объект;	
	Попытка
		пPOSтерминал 																= Новый COMОбъект("ECRCommX.BPOS1Lib");
		Попытка
            пPOSтерминал.CommOpen(ПараметрыPOSтерм.POSтерминал_Порт, ПараметрыPOSтерм.POSтерминал_Скорость);  
			
			Если ПараметрыPOSтерм.POSтерминал_ЗаписыватьLogFile=0 Тогда 
				пPOSтерминал.useLogging(0, "");
			Иначе 	
				СоздатьКаталог(глПуть+"\LogFile\POS_terminal\");
            	ИмяФайлаXML															= Формат(ТекущаяДата(), "ДФ=ггггММддHHmmss")+"LogFile.txt";
				пPOSтерминал.useLogging(ПараметрыPOSтерм.POSтерминал_ЗаписыватьLogFile, глПуть+"\LogFile\POS_terminal\"+ИмяФайлаXML);
			КонецЕсли;	
			
			//пPOSтерминал.POSGetInfo();
			ПараметрыPOSтерм.POSтерминал_Объект										= пPOSтерминал;
			
			//Мулько
			//ПараметрыPOSтерм.POSтерминал_LastResult									= WaitPOSResponse(пPOSтерминал, 1000000);
			//В следующем обновлении
			ПараметрыPOSтерм.POSтерминал_LastResult									= WaitPOSResponse(пPOSтерминал);
			Если ПараметрыPOSтерм.POSтерминал_LastResult=0 Тогда 
				ПараметрыPOSтерм.POSтерминал_Объект.SetErrorLang(2);
				//Мулько К.П.
				//ПараметрыPOSтерм.POSтерминал_СтрокаИнфо = пPOSтерминал.TerminalInfo;
				Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Предупреждение, "ОткрытьПорт()", "Порт открыт", Неопределено, Неопределено, "Обработки.ТО_POSтерминал_ПриватБанк");
	            Возврат Истина;                                 
	        КонецЕсли; 
			
			ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! CommOpen()", Истина, НеВыводитьОшибку);
			Возврат Ложь;
	
		Исключение
			пPOSтерминал															= Неопределено;
			ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Терминал не подключен!", Ложь, НеВыводитьОшибку);
			Возврат Ложь;
       	КонецПопытки;
		
	Исключение
		
		пPOSтерминал																= Неопределено;
		ОшибкаPOS_Сообщить(пPOSтерминал, "НЕ удалось загрузить ActiveX ECRCommX для связи с POS-терминалом!", Ложь);	
		Возврат Ложь;
	КонецПопытки;

КонецФункции	 
																																						
Функция ЗакрытьПорт(ПараметрыPOSтерм) Экспорт 
	пPOSтерминал																	= ПараметрыPOSтерм.POSтерминал_Объект;	
	
	Попытка		
		пPOSтерминал.CommClose();
		Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Предупреждение, "ЗакрытьПорт()", "Порт закрыт", Неопределено, Неопределено, "Обработки.ТО_POSтерминал_ПриватБанк");
	Исключение
	КонецПопытки;	
	
	ПараметрыPOSтерм.POSтерминал_Объект												= Неопределено;
	Возврат Неопределено;

КонецФункции

Функция НачалоТранзакции(ПараметрыPOSтерм, ПараметрыЧекаККМ) Экспорт 
	
	пPOSтерминал															= ПараметрыPOSтерм.POSтерминал_Объект;	
	
	Если ПараметрыЧекаККМ.ЭтоЧекВозврата И ПустаяСтрока(ПараметрыЧекаККМ.Возврат_RRN) Тогда
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Не указан RRN ЧЕКА ПРОДАЖИ!!!", Истина);
		Возврат Ложь
	КонецЕсли;

	ТекстКомандыДляОшибки = "Purchase()/Refund()";
	
	Попытка		
		Если ПараметрыЧекаККМ.ЭтоЧекПродажи Тогда 			
			пPOSтерминал.Purchase(ПараметрыЧекаККМ.ФО_СуммаПоКарте*100, 0, 1);
		Иначе	
			Если Константы.ТО_POSтерминал_НовыйВидВозврата.Получить() Тогда 
				//24.02.2020
				пPOSтерминал.POSGetInfo();
				ПараметрыPOSтерм.POSтерминал_LastResult = WaitPOSResponse(пPOSтерминал);
				Если ПараметрыPOSтерм.POSтерминал_LastResult = 0 Тогда 
					ПараметрыPOSтерм.POSтерминал_МерчаныСтр						= пPOSтерминал.TerminalInfo;
					ПараметрыPOSтерм.POSтерминал_МерчаныМассив					= СтрРазделить(ПараметрыPOSтерм.POSтерминал_МерчаныСтр, "/", Ложь);						
					ПараметрыPOSтерм.POSтерминал_НомерМерчанаВозврата			= ПараметрыPOSтерм.POSтерминал_МерчаныМассив.Найти("REFUND");
				
					Если ПараметрыPOSтерм.POSтерминал_НомерМерчанаВозврата>0 Тогда
						ТекстКомандыДляОшибки = "PurchaseService()";
						пPOSтерминал.PurchaseService(ПараметрыPOSтерм.POSтерминал_НомерМерчанаВозврата, ПараметрыЧекаККМ.ФО_СуммаПоКарте*100, "0054//" + ПараметрыЧекаККМ.Возврат_RRN);
					Иначе 
						ВызовИсключения												= 1/0;	
					КонецЕсли;	
				Иначе	
					ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Не выполненна команада POSGetInfo", Истина);
	                Возврат Ложь;
				КонецЕсли;	
			Иначе 
				пPOSтерминал.Refund(ПараметрыЧекаККМ.ФО_СуммаПоКарте*100, 0, 1, ПараметрыЧекаККМ.Возврат_RRN);	
			КонецЕсли;	
		КонецЕсли;	
	Исключение
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Не выполненна команада " + ТекстКомандыДляОшибки, Истина);
		ПараметрыPOSтерм.POSтерминал_Объект = пPOSтерминал;
		Возврат Ложь;
	КонецПопытки;	
																				
	ErrorDescription														= "";
	LastResult																= WaitPOSResponse(пPOSтерминал);
	Если LastResult=0 Тогда 
		ПараметрыPOSтерм.POSтерминал_Объект									= пPOSтерминал;
		Возврат Истина
	КонецЕсли;	
	
	пPOSтерминал.Cancel();
	
	ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! НачалоТранзакции! Purchase()/Refund() ", Истина);
	ПараметрыPOSтерм.POSтерминал_Объект										= пPOSтерминал;
	Возврат Ложь;
	
КонецФункции

Функция ЗавершитьТранзакцию(ПараметрыPOSтерм, ПараметрыЧекаККМ) Экспорт
	пPOSтерминал															= ПараметрыPOSтерм.POSтерминал_Объект;
	
	Если Константы.ТО_POSтерминал_НовыйВидВозврата.Получить() 
		И ПараметрыЧекаККМ.ЭтоЧекВозврата Тогда    							Возврат Истина;			КонецЕсли;	
	
	Попытка
		//глInvoiceNum                             							= пPOSтерминал.InvoiceNum;
		//пPOSтерминал.Cancel();
		пPOSтерминал.Confirm();
	Исключение
	КонецПопытки;	
		
	ErrorDescription														= "";
	LastResult																= WaitPOSResponse(пPOSтерминал);
	LastStatMsgCode 														= пPOSтерминал.LastStatMsgCode();
    LastResult1 															= пPOSтерминал.LastResult();
	Если LastResult<>0 Тогда 
		
		//Мулько К.П. 05.09.2019
		//при ошибке связи с терминалом сделаем несколько попыток
		Если LastResult = 1 Тогда //ошибка связи
			
			Попытка
				LastErrorCode = пPOSтерминал.LastErrorCode();
			Исключение
			КонецПопытки;	
			
			КолПопытокСвязиСТерминалом = 3;
	
			Если LastErrorCode = 3 Тогда
				Пока LastResult = 1 И КолПопытокСвязиСТерминалом > 0 Цикл
					LastResult	= WaitPOSResponse(пPOSтерминал);
					КолПопытокСвязиСТерминалом = КолПопытокСвязиСТерминалом - 1;
					Если LastResult = 0 Тогда //получили ответ об успешном заверешении команды
						Возврат Истина;
					КонецЕсли;	
				КонецЦикла;	
			КонецЕсли;
			
		КонецЕсли;		
		
		пPOSтерминал.Cancel();
		
		//ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Платеж не проведен! Confirm()", Истина);
		ПолныйТекст = "ОШИБКА! Платеж не проведен! LastResult операции Confirm: " + LastResult;
		Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Предупреждение, "ERROR POS-терминал! Confirm()", ПолныйТекст, Неопределено, Неопределено, "Обработки.ТО_POSтерминал_ОщадБанк");
		
		ПараметрыPOSтерм.POSтерминал_Объект									= пPOSтерминал;
		Возврат Ложь;
	КонецЕсли;
	
	//Мулько 04.11.2019
	//при оплате чипом вызывает ложную ошибку, т.к при оплате чипом LastStatMsgCode = 7 (card was removed)
	//Если LastStatMsgCode<>0 И LastStatMsgCode<>11 Тогда 
	//	
	//	пPOSтерминал.Cancel();
	//	
	//	ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Платеж не проведен! Confirm()", Истина);
	//	ПараметрыPOSтерм.POSтерминал_Объект									= пPOSтерминал;
	//	Возврат Ложь;
	//КонецЕсли;
	
	//Мулько К.П.
	//проверка корректна ли была завершена транзакция
	Попытка
		пPOSтерминал.ReqCurrReceipt();
		LastResult																= WaitPOSResponse(пPOSтерминал);
	//Если LastResult<>0 Тогда 
	
		Если СтрНайти(пPOSтерминал.Receipt, "АНУЛЬОВАНО") <> 0 Тогда
			//ОшибкаPOS_Сообщить(пPOSтерминал, "ОШИБКА! Платеж не проведен! Будет АВТОМАТИЧЕСКИ сделан возврат по кассе.", Истина);
			ПолныйТекст = "ОШИБКА! Платеж не проведен! В квитанции терминала есть текст ""АНУЛЬОВАНО""";
			Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Предупреждение, "ERROR POS-терминал! ЗавершитьТранзакцию()", ПолныйТекст, Неопределено, Неопределено, "Обработки.ТО_POSтерминал_ОщадБанк");
			ПараметрыPOSтерм.POSтерминал_Объект									= пPOSтерминал;
			Возврат Ложь;
		КонецЕсли;
		
	//КонецЕсли;	
	Исключение
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Возникло исключение в операции ReqCurrReceipt()", Истина);
		Возврат Ложь;
	КонецПопытки;	
				
	Возврат Истина;

КонецФункции	

Функция ПолучитьПарметрыЧекаТерминала(ПараметрыPOSтерм, ПараметрыЧекаККМ) Экспорт
	пPOSтерминал															= ПараметрыPOSтерм.POSтерминал_Объект;
	
	Попытка
		ПараметрыЧекаККМ.POSтерминал_ВидТранзакции							= ПараметрыЧекаККМ.ВидОперацииКод;
		ПараметрыЧекаККМ.POSтерминал_СуммаТранзакции						= пPOSтерминал.Amount/100;      // сумма транзакции
		ПараметрыЧекаККМ.POSтерминал_ПодписьКлиента							= ?(пPOSтерминал.SignVerif=1, Истина, Ложь); 		// необходимость подписи клиента 0 (нет) или 1 (да)
		ПараметрыЧекаККМ.POSтерминал_ВладелецКарты							= СокрЛП(пPOSтерминал.CardHOlder); 		// владелец карты IVAN/PETROV
		ПараметрыЧекаККМ.POSтерминал_ВидКарты	 							= СокрЛП(пPOSтерминал.IssuerName); 		// наименование банка, выпустившего карту	
		ПараметрыЧекаККМ.POSтерминал_НомерКарты								= СокрЛП(пPOSтерминал.PAN);  			// номера карты в формате 1234хххххх5678
		ПараметрыЧекаККМ.POSтерминал_ТерминалаID   							= СокрЛП(пPOSтерминал.TerminalID);		 
        ПараметрыЧекаККМ.POSтерминал_ДатаЧека          						= Дата("20"+пPOSтерминал.DateTime);
        ПараметрыЧекаККМ.POSтерминал_КодАвторизации                 		= СокрЛП(пPOSтерминал.AuthCode);
		ПараметрыЧекаККМ.POSтерминал_НомерЧека                        		= СокрЛП(пPOSтерминал.InvoiceNum);
		ПараметрыЧекаККМ.POSтерминал_RRN									= СокрЛП(пPOSтерминал.RRN); 			// идентификатор транзакции
		ПараметрыЧекаККМ.POSтерминал_TerminalInfo           				= СокрЛП(пPOSтерминал.TerminalInfo);
	Исключение
		Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Ошибка, "ПолучитьПарметрыЧекаТерминала", "ОШИБКА ПРИ ПОЛУЧЕНИИ ПАРАМЕТРОВ ТРАНЗАКЦИИ ИЗ POS-Терминала!"+ОписаниеОшибки() , Неопределено, Неопределено, "Обработки.ТО_POSтерминал_ПриватБанк");
	КонецПопытки;
	
	// при возврате через сервис RRN и КодАвторизации не создаеться. Присваюю занчение из орыгинал. транзакции
	Если Константы.ТО_POSтерминал_НовыйВидВозврата.Получить() И ПараметрыЧекаККМ.ЭтоЧекВозврата Тогда 
		ПараметрыЧекаККМ.POSтерминал_RRN									= ПараметрыЧекаККМ.Возврат_ЧекККМ.POSтерминал_RRN; 
		ПараметрыЧекаККМ.POSтерминал_КодАвторизации                 		= ПараметрыЧекаККМ.Возврат_ЧекККМ.POSтерминал_КодАвторизации;
	КонецЕсли;	
																				
    МассивТЕКСТ																= Новый Массив;
	МассивТЕКСТ.Добавить("**********************");
	Если ПараметрыЧекаККМ.POSтерминал_ВидТранзакции=0 Тогда
		МассивТЕКСТ.Добавить("***    ОПЛАТА      ***");
	ИначеЕсли ПараметрыЧекаККМ.POSтерминал_ВидТранзакции=1 Тогда 	
		МассивТЕКСТ.Добавить("***  ПОВЕРНЕННЯ    ***");
		МассивТЕКСТ.Добавить("*** ЗБЕРЕЖІТЬ ЧЕК  ***");
	Иначе
		МассивТЕКСТ.Добавить("***   АНУЛЯЦИЯ     ***");
	КонецЕсли;
	
	//Мулько 06.11.2019
	//МассивТЕКСТ.Добавить("ТЕРМІНАЛ №: "+ПараметрыЧекаККМ.POSтерминал_ТерминалаID);
	МассивТЕКСТ.Добавить("ПРИВАТБАНК №: "+ПараметрыЧекаККМ.POSтерминал_ТерминалаID);
	МассивТЕКСТ.Добавить("ЧЕК N: "+ПараметрыЧекаККМ.POSтерминал_НомерЧека);
	МассивТЕКСТ.Добавить("RRN: "+ПараметрыЧекаККМ.POSтерминал_RRN);
	МассивТЕКСТ.Добавить(ПараметрыЧекаККМ.POSтерминал_ВидКарты);
	МассивТЕКСТ.Добавить(ПараметрыЧекаККМ.POSтерминал_НомерКарты);
	МассивТЕКСТ.Добавить(ПараметрыЧекаККМ.POSтерминал_ВладелецКарты);
	МассивТЕКСТ.Добавить("КОД АВТОРИЗ. "+ПараметрыЧекаККМ.POSтерминал_КодАвторизации);
	МассивТЕКСТ.Добавить( Формат(ПараметрыЧекаККМ.POSтерминал_ДатаЧека, "ДФ='dd/MM/yyyy HH:mm:ss'"));
	МассивТЕКСТ.Добавить("Касир: підпис не потрібен");//27.03.2020 новое
	Если ПараметрыЧекаККМ.POSтерминал_ПодписьКлиента Тогда 
		МассивТЕКСТ.Добавить("Держатель ЕПЗ: Підпис");
		МассивТЕКСТ.Добавить("_______________");
	Иначе 
		МассивТЕКСТ.Добавить("Держатель ЕПЗ: Підпис");
		МассивТЕКСТ.Добавить("власника картки не потрібен!");
		//МассивТЕКСТ.Добавить("не потрібен!");
	КонецЕсли;	
	МассивТЕКСТ.Добавить("**********************");
	ПараметрыЧекаККМ.POSтерминал_ТекстДляЧекаФР = МассивТЕКСТ;
	
	Текст = "POSтерминал_ВидТранзакции: "+ПараметрыЧекаККМ.POSтерминал_ВидТранзакции+
			"POSтерминал_ТерминалаID: "+ПараметрыЧекаККМ.POSтерминал_ТерминалаID+
			"POSтерминал_НомерЧека: "+ПараметрыЧекаККМ.POSтерминал_НомерЧека+
			"POSтерминал_КодАвторизации: "+ПараметрыЧекаККМ.POSтерминал_КодАвторизации+
			"POSтерминал_RRN: "+ПараметрыЧекаККМ.POSтерминал_RRN+
			"POSтерминал_ВидКарты: "+ПараметрыЧекаККМ.POSтерминал_ВидКарты+
			"POSтерминал_НомерКарты: "+ПараметрыЧекаККМ.POSтерминал_НомерКарты+
			"POSтерминал_ВладелецКарты: "+ПараметрыЧекаККМ.POSтерминал_ВладелецКарты+
			"POSтерминал_ДатаЧека: "+Формат(ПараметрыЧекаККМ.POSтерминал_ДатаЧека, "ДФ='dd/MM/yyyy HH:mm:ss'")+
            "POSтерминал_ПодписьКлиента: "+ПараметрыЧекаККМ.POSтерминал_ПодписьКлиента;

	Логирование.ДобавитьЗаписьЖурнала(, "ПолучитьПарметрыЧекаТерминала", " ПАРАМЕТРЫ ТРАНЗАКЦИИ => "+Текст , Неопределено, Неопределено, "Обработки.ТО_POSтерминал_ПриватБанк");
КонецФункции	

Функция АнуляцияТранзакции(ПараметрыPOSтерм) Экспорт
	пPOSтерминал															= ПараметрыPOSтерм.POSтерминал_Объект;
	
	НомерЧека 																= 0;
	Если Не ВвестиЧисло(НомерЧека, "Введите номер ТЕРМИНАЛЬНОГО ЧЕКА !!!", 10, 0) И НомерЧека>0 Тогда
   		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! АНУЛЯЦИЯ! Отмена ввода номера ТЕРМИНАЛЬНОГО ЧЕКА!", Ложь);
		ПараметрыPOSтерм.POSтерминал_Объект									= пPOSтерминал;
		Возврат Ложь;
	КонецЕсли;
   
	Попытка
		пPOSтерминал.Void(НомерЧека, 1);
	Исключение
	КонецПопытки;	
		
	ErrorDescription														= "";
	LastResult																= WaitPOSResponse(пPOSтерминал);
	Если LastResult<>0 Тогда 
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Ануляция не проведена! Void()", Истина);
		ПараметрыPOSтерм.POSтерминал_Объект									= пPOSтерминал;
		Возврат Ложь;
	КонецЕсли;
		
	ОшибкаPOS_Сообщить(пPOSтерминал, "POS-терминал! Ануляция ВЫПОЛНЕНА! Чек № "+СокрЛП(НомерЧека), Ложь);
	ПараметрыPOSтерм.POSтерминал_Объект										= пPOSтерминал;
	Возврат Истина;

КонецФункции	

Функция АнуляцияТранзакцииПоНомеруЧека(ПараметрыPOSтерм, ПараметрыЧекаККМ) Экспорт
	пPOSтерминал															= ПараметрыPOSтерм.POSтерминал_Объект;
	
	Если ПараметрыЧекаККМ.POSтерминал_НомерЧека = 0 Тогда
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! АНУЛЯЦИЯ! Номер транзкации ТЕРМИНАЛЬНОГО ЧЕКА указан НЕВЕРНО!", Ложь);
		ПараметрыPOSтерм.POSтерминал_Объект									= пPOSтерминал;
		Возврат Ложь;
	КонецЕсли;
   
	Попытка
		пPOSтерминал.Void(ПараметрыЧекаККМ.POSтерминал_НомерЧека, 1);
	Исключение
	КонецПопытки;	
		
	ErrorDescription														= "";
	LastResult																= WaitPOSResponse(пPOSтерминал);
	Если LastResult<>0 Тогда 
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Ануляция не проведена! Void()", Истина);
		ПараметрыPOSтерм.POSтерминал_Объект									= пPOSтерминал;
		Возврат Ложь;
	КонецЕсли;
		
	ОшибкаPOS_Сообщить(пPOSтерминал, "POS-терминал! Ануляция ВЫПОЛНЕНА! Чек № "+СокрЛП(ПараметрыЧекаККМ.POSтерминал_НомерЧека), Ложь);
	ПараметрыPOSтерм.POSтерминал_Объект										= пPOSтерминал;
	Возврат Истина;

КонецФункции	

Функция get_TxnType(пPOSтерминал, InvoiceNum) Экспорт 
	Попытка
		//пPOSтерминал.GetTxnDataByInv(InvoiceNum, 0);
		пPOSтерминал.ReqReceiptByInv(InvoiceNum, 0);
		LastResult 															= пPOSтерминал.LastResult();
		Если LastResult=0 Тогда 
			TxnType															= пPOSтерминал.TxnType;
		Иначе 
			TxnType															= 0;	
		КонецЕсли;	
	Исключение
		TxnType		= 0;
	КонецПопытки;	
	
	Возврат TxnType	
КонецФункции	

Функция PrintLastSettleCopy(пPOSтерминал) Экспорт 
	Попытка
		пPOSтерминал.PrintLastSettleCopy(0);
		
		LastResult																= WaitPOSResponse(пPOSтерминал);
		Если LastResult<0 Тогда 
			Возврат Ложь
        КонецЕсли;
	Исключение
		Возврат Ложь
	КонецПопытки;	
	
	Возврат Истина	
КонецФункции	

Функция PrintLastSettleCopy_На_ФР(ПараметрыPOSтерм, МассивНефискальногоТекста) Экспорт 
	пPOSтерминал = ПараметрыPOSтерм.POSтерминал_Объект;
	Попытка
		пPOSтерминал.PrintLastSettleCopy(0);
		
		LastResult																= WaitPOSResponse(пPOSтерминал);
		Если LastResult<>0 Тогда 
			Возврат Ложь
        КонецЕсли;
	Исключение
		Возврат Ложь
	КонецПопытки;	
	
	Попытка
		пPOSтерминал.ReqCurrReceipt();
		LastResult																= WaitPOSResponse(пPOSтерминал);
	//Если LastResult<>0 Тогда 
	
		ТекстСообщения = пPOSтерминал.Receipt;
		
		Массив = ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(ТекстСообщения, Символы.ПС);
		СтрокиВывода 														= "";
		СтрокаВывода														= "";
				
		Массив											= ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(ТекстСообщения, " ");
		Для Каждого ЭлементМассива Из Массив Цикл 
			Если (СтрДлина(СтрокаВывода)+СтрДлина(ЭлементМассива)+1)>21 Тогда 
				СтрокиВывода												= СтрокиВывода + СтрокаВывода + Символы.ПС;
				СтрокаВывода												= "";
				СтрокаВывода												= ЭлементМассива;
			Иначе
				СтрокаВывода 												= СтрокаВывода + " " +ЭлементМассива;
			КонецЕсли;	
		КонецЦикла;
		
		Если НЕ ПустаяСтрока(СтрокаВывода) Тогда 
			СтрокиВывода 													= СтрокиВывода + СтрокаВывода;	
		КонецЕсли;	
		
		МассивНефискальногоТекста.Добавить("------------------");
		МассивНефискальногоТекста.Добавить("----ПРИВАТБАНК----");
		МассивНефискальногоТекста.Добавить("                  ");
		МассивНефискальногоТекста.Добавить("---Копия Z-отчет--");
		Для Х=1 по СтрЧислоСтрок(СтрокиВывода) Цикл
			СтрокаМассива = СокрЛП(СтрПолучитьСтроку(СтрокиВывода,Х));
			СтрокаМассива = СтрЗаменить(СтрокаМассива, ";", "");
			МассивНефискальногоТекста.Добавить(СтрокаМассива);	
		КонецЦикла;
	
	//КонецЕсли;	
	Исключение
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Возникло исключение в операции ReqCurrReceipt()", Истина);
		Возврат Ложь;
	КонецПопытки;
	
	Возврат Истина;
	
КонецФункции	

Функция Печать_X_Отчет(ПараметрыPOSтерм) Экспорт
	пPOSтерминал															= ПараметрыPOSтерм.POSтерминал_Объект;
	Попытка
		пPOSтерминал.PrintBatchTotals(0);
	Исключение
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! При печати X-отчета по терминалу!!!", Истина);   
	КонецПопытки;

КонецФункции	

Функция Печать_Z_Отчет(ПараметрыPOSтерм) Экспорт
	
	пPOSтерминал = ПараметрыPOSтерм.POSтерминал_Объект;
	
	Попытка
		пPOSтерминал.Settlement(0);
	Исключение
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! При печати Z-отчета по терминалу!!!", Истина);   
	КонецПопытки;
	
КонецФункции

Функция Печать_X_Отчет_На_ФР(ПараметрыPOSтерм, МассивНефискальногоТекста) Экспорт
	
	пPOSтерминал															= ПараметрыPOSтерм.POSтерминал_Объект;
	Попытка
		пPOSтерминал.PrintBatchTotals(0);
	Исключение
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! При печати X-отчета по терминалу!!!", Истина);   
	КонецПопытки;
	
	//Мулько 27.11.2019
	ErrorDescription														= "";
	LastResult																= WaitPOSResponse(пPOSтерминал);
	LastStatMsgCode 														= пPOSтерминал.LastStatMsgCode();
    LastResult1 															= пPOSтерминал.LastResult();
	
	Если LastResult<>0 Тогда 
		
		Если LastResult = 1 Тогда //ошибка связи
			
			Попытка
				LastErrorCode = пPOSтерминал.LastErrorCode();
			Исключение
			КонецПопытки;	
			
			КолПопытокСвязиСТерминалом = 3;
	
			Если LastErrorCode = 3 Тогда
				Пока LastResult = 1 И КолПопытокСвязиСТерминалом > 0 Цикл
					LastResult	= WaitPOSResponse(пPOSтерминал);
					КолПопытокСвязиСТерминалом = КолПопытокСвязиСТерминалом - 1;
					Если LastResult = 0 Тогда //получили ответ об успешном заверешении команды
						Возврат Истина;
					КонецЕсли;	
				КонецЦикла;	
			КонецЕсли;
			
		КонецЕсли;	
		
	КонецЕсли;
	
	Попытка
		пPOSтерминал.ReqCurrReceipt();
		LastResult																= WaitPOSResponse(пPOSтерминал);
		Если LastResult = 0 Тогда 
	
			ТекстСообщения = пPOSтерминал.Receipt;
			
			Массив = ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(ТекстСообщения, Символы.ПС);
			СтрокиВывода 														= "";
			СтрокаВывода														= "";
					
			Массив											= ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(ТекстСообщения, " ");
			Для Каждого ЭлементМассива Из Массив Цикл 
				Если (СтрДлина(СтрокаВывода)+СтрДлина(ЭлементМассива)+1)>21 Тогда 
					СтрокиВывода												= СтрокиВывода + СтрокаВывода + Символы.ПС;
					СтрокаВывода												= "";
					СтрокаВывода												= ЭлементМассива;
				Иначе
					СтрокаВывода 												= СтрокаВывода + " " +ЭлементМассива;
				КонецЕсли;	
			КонецЦикла;
			
			Если НЕ ПустаяСтрока(СтрокаВывода) Тогда 
				СтрокиВывода 													= СтрокиВывода + СтрокаВывода;	
			КонецЕсли;	
			
			
			МассивНефискальногоТекста.Добавить("------------------");
			МассивНефискальногоТекста.Добавить("----ПРИВАТБАНК----");
			МассивНефискальногоТекста.Добавить("                  ");
			МассивНефискальногоТекста.Добавить("-----Х-отчет------");
			
			Для Х=1 по СтрЧислоСтрок(СтрокиВывода) Цикл
				СтрокаМассива = СокрЛП(СтрПолучитьСтроку(СтрокиВывода,Х));
				СтрокаМассива = СтрЗаменить(СтрокаМассива, ";", "");
				МассивНефискальногоТекста.Добавить(СтрокаМассива);	
			КонецЦикла;
	
		КонецЕсли;	
	Исключение
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Возникло исключение в операции ReqCurrReceipt()", Истина);
		Возврат Ложь;
	КонецПопытки;	

КонецФункции	

Функция Печать_Z_Отчет_На_ФР(ПараметрыPOSтерм, МассивНефискальногоТекста) Экспорт
	
	пPOSтерминал															= ПараметрыPOSтерм.POSтерминал_Объект;
	
	Попытка
		пPOSтерминал.Settlement(0);
	Исключение
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! При печати Z-отчета по терминалу!!!", Истина);   
	КонецПопытки;
	
	//Мулько 27.11.2019
	ErrorDescription														= "";
	LastResult																= WaitPOSResponse(пPOSтерминал);
	LastStatMsgCode 														= пPOSтерминал.LastStatMsgCode();
    LastResult1 															= пPOSтерминал.LastResult();
	
	Если LastResult<>0 Тогда 
		
		Если LastResult = 1 Тогда //ошибка связи
			
			Попытка
				LastErrorCode = пPOSтерминал.LastErrorCode();
			Исключение
			КонецПопытки;	
			
			КолПопытокСвязиСТерминалом = 3;
	
			Если LastErrorCode = 3 Тогда
				Пока LastResult = 1 И КолПопытокСвязиСТерминалом > 0 Цикл
					LastResult	= WaitPOSResponse(пPOSтерминал);
					КолПопытокСвязиСТерминалом = КолПопытокСвязиСТерминалом - 1;
					Если LastResult = 0 Тогда //получили ответ об успешном заверешении команды
						Возврат Истина;
					КонецЕсли;	
				КонецЦикла;	
			КонецЕсли;
			
		КонецЕсли;	
		
	КонецЕсли;
	
	Попытка
		пPOSтерминал.ReqCurrReceipt();
		LastResult																= WaitPOSResponse(пPOSтерминал);
	//Если LastResult<>0 Тогда 
	
		ТекстСообщения = пPOSтерминал.Receipt;
		
		Массив = ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(ТекстСообщения, Символы.ПС);
		СтрокиВывода 														= "";
		СтрокаВывода														= "";
				
		Массив											= ОбщегоНазначения.РазложитьСтрокуВМассивПодстрок(ТекстСообщения, " ");
		Для Каждого ЭлементМассива Из Массив Цикл 
			Если (СтрДлина(СтрокаВывода)+СтрДлина(ЭлементМассива)+1)>21 Тогда 
				СтрокиВывода												= СтрокиВывода + СтрокаВывода + Символы.ПС;
				СтрокаВывода												= "";
				СтрокаВывода												= ЭлементМассива;
			Иначе
				СтрокаВывода 												= СтрокаВывода + " " +ЭлементМассива;
			КонецЕсли;	
		КонецЦикла;
		
		Если НЕ ПустаяСтрока(СтрокаВывода) Тогда 
			СтрокиВывода 													= СтрокиВывода + СтрокаВывода;	
		КонецЕсли;	
		
		МассивНефискальногоТекста.Добавить("------------------");
		МассивНефискальногоТекста.Добавить("----ПРИВАТБАНК----");
		МассивНефискальногоТекста.Добавить("                  ");
		МассивНефискальногоТекста.Добавить("-----Z-отчет------");
		Для Х=1 по СтрЧислоСтрок(СтрокиВывода) Цикл
			СтрокаМассива = СокрЛП(СтрПолучитьСтроку(СтрокиВывода,Х));
			СтрокаМассива = СтрЗаменить(СтрокаМассива, ";", "");
			МассивНефискальногоТекста.Добавить(СтрокаМассива);	
		КонецЦикла;

	//КонецЕсли;	
	Исключение
		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! Возникло исключение в операции ReqCurrReceipt()", Истина);
		Возврат Ложь;
	КонецПопытки;	
	
КонецФункции

//Функция ПечатьКопии_Последний_Z_Отчет(пPOSтерминал) Экспорт
//	Попытка
//		пPOSтерминал.PrintLastSettleCopy(0);
//	Исключение
//		ОшибкаPOS_Сообщить(пPOSтерминал, "ERROR POS-терминал! При печати копии последнего Z-отчета по терминалу!!!", Истина);   
//	КонецПопытки;
//КонецФункции	