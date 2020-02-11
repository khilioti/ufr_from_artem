﻿Перем глОбработкаЭмулятор Экспорт;
Перем ПараметрыЧекаККМ Экспорт;
Перем ПараметрыФР Экспорт;
Перем ПараметрыPOSтерм Экспорт;
Перем ПараметрыFISHKA Экспорт;
Перем ПараметрыBPM7 Экспорт;

// Дьяченко перенос акций в BPM
Перем глАкционнаяСистемаBPM Экспорт; 
//Мулько
//---------------
Перем ЕстьАкцииПросканироватьБК Экспорт;
Перем глФРКоличествоПопыток Экспорт;
//---------------

Перем глТекущееПодразделение Экспорт;

Перем глОбщиеЗначения Экспорт;

Перем глТекПользовательИБ Экспорт;   //++VS18.02.2015
Перем глТекущийПользователь Экспорт;
Перем глЗапрашиватьПодтверждениеПриЗакрытии Экспорт;

//ЛОВ

  Перем глПуть экспорт;
  
  //перем Plus1 экспорт;
  //перем скидкаПС экспорт;
  перем РежимВозвратаЧека экспорт;
  перем глСтрокВозврата экспорт;
  
  Перем СтруктураФайлаПРодаж экспорт;
  Перем СтруктураДБФ экспорт;
  Перем SaleListdbf экспорт;
  
  //11.08.2012 Прог
  //Перем СОМ_Объект_АльтернативногоСервера Экспорт;         // Тип - СОМ-соединитель
  //Перем СОМ_Объект_ДополнительногоСервера Экспорт;         // Тип - СОМ-соединитель
  Перем СОМСоединительУТ Экспорт;
  Перем АвтономныйРежимОсновногоСервераТорговойИБ Экспорт; // Тип - Булево. Истина - когда нет сетевого соединения. Ложь = когда сетевое соединение присутствует.
  //Перем АвтономныйРежимАльтернативногоСервераККМ Экспорт;  // Тип - Булево. Истина - когда нет сетевого соединения. Ложь = когда сетевое соединение присутствует.
  //Перем АвтономныйРежимДополнительногоСервераККМ Экспорт;  // Тип - Булево. Истина - когда нет сетевого соединения. Ложь = когда сетевое соединение присутствует. 
  //Перем АвтономныйРежимВсеСервераНедоступны Экспорт;       // Тип - Булево. Истина - когда нет сетевого соединения. Ложь = когда сетевое соединение присутствует.
  
  Перем ФайлЖурнала Экспорт; //05.10.2012
  Перем ИмяФЖ Экспорт;       //09.10.2012
  Перем ПолноеИмяФЖ Экспорт; //09.10.2012
  Перем СписокМетаЯзыков Экспорт;

  Перем глРазрешенныеСимволы Экспорт; //22.03.2013
  Перем глСписокЦифр Экспорт;         //22.03.2013
  Перем глДлиныПодстрок Экспорт;      //22.03.2013
  
Перем глЭККР Экспорт;
Перем глМОДЕМ Экспорт;
Перем глСКАНЕР Экспорт;
Перем глPOSтерминал Экспорт;

Перем глВыгрузитьФайлНаFTP_АварийныеРС  Экспорт;

Перем глСкачатьПредсказания             Экспорт;
Перем глСерийныйНомерФР_VS				Экспорт;
Перем глНомерПоследнегоЧека_VS			Экспорт;


Перем ТаблицаСписокФайловНаFTP_VS       Экспорт; 

Перем глЗначениеШК						Экспорт;

// переменные для BPMonline  
Перем глОтключитьBPMonline              Экспорт;

Перем Объект_BPMonline 					Экспорт;
Перем ВладелецБК_BPMonline				Экспорт;
Перем РезультатЗапроса_SetPurchaseInfo  Экспорт;
Перем РезультатЗапроса_GetWriteOffLimits Экспорт;

Перем ТабРезультат_TransactionsResult 		Экспорт;
Перем ТабРезультат_RemainResult 			Экспорт;
Перем ТабРезультат_WriteOffBonus 			Экспорт;
Перем ТабРезультат_CardAccountRemainsClass 	Экспорт;


Перем WS Экспорт;
Перем глGUID_ЧекаККМ_VS					Экспорт;
Перем глGUID_Смены_VS					Экспорт;

// Открывает форму текущего пользователя для изменения его настроек.
//
// Параметры:
//  Нет.
//
Процедура ОткрытьФормуТекущегоПользователя() Экспорт

	Если НЕ ЗначениеЗаполнено(глТекущийПользователь) Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Не задан текущий пользователь.");
	Иначе
		Форма = глТекущийПользователь.ПолучитьФорму();
		Форма.Открыть();
	КонецЕсли;

КонецПроцедуры // ОткрытьФормуТекущегоПользователя()

// Функция возвращает значение экспортных переменных модуля приложенийа
//
// Параметры
//  Имя - строка, содержит имя переменной целиком 
//
// Возвращаемое значение:
//   значение соответствующей экспортной переменной
Функция глЗначениеПеременной(Имя) Экспорт

	Возврат ОбщегоНазначения.ПолучитьЗначениеПеременной(Имя, глОбщиеЗначения);
	
КонецФункции

// Процедура установки значения экспортных переменных модуля приложения
//
// Параметры
//  Имя - строка, содержит имя переменной целиком
// 	Значение - значение переменной
//
Процедура глЗначениеПеременнойУстановить(Имя, Значение, ОбновлятьВоВсехКэшах = Ложь) Экспорт
	
	ОбщегоНазначения.УстановитьЗначениеПеременной(Имя, глОбщиеЗначения, Значение, ОбновлятьВоВсехКэшах);
	
КонецПроцедуры

Процедура ДобавитьПользователя(ИмяПользователя, ПолноеИмяПользователя, СписокРолей, Интерфейс, Показ) Экспорт
			
			НовыйПользовательИБ                            = ПользователиИнформационнойБазы.СоздатьПользователя();
			НовыйПользовательИБ.Имя                        = ИмяПользователя;
			НовыйПользовательИБ.ПолноеИмя                  = ПолноеИмяПользователя;
			НовыйПользовательИБ.АутентификацияСтандартная  = Истина;
			НовыйПользовательИБ.ОсновнойИнтерфейс          = Интерфейс;
			НовыйПользовательИБ.Пароль 					   = РаботаСПользователями.ПолучитьПараметры(ИмяПользователя);
			НовыйПользовательИБ.ПоказыватьВСпискеВыбора    = Показ;
			НовыйПользовательИБ.ЗапрещеноИзменятьПароль    = Истина;
			Если Показ = Истина Тогда // для неадминистративных ролей доступен выбор языка интерфейса
				МетаЯзык                                       = СписокМетаЯзыков.ВыбратьЭлемент("Язык интерфейса для " + ИмяПользователя, Метаданные.Языки.Русский);
				НовыйПользовательИБ.Язык                       = ?(МетаЯзык = Неопределено, Метаданные.Языки.Русский, МетаЯзык.Значение);
			Иначе                    // для административных ролей доступен только русский язык интерфейса при автоматическом создании
				НовыйПользовательИБ.Язык                       = Метаданные.Языки.Русский;
 			КонецЕсли;
			Для каждого Элем Из СписокРолей Цикл
				НовыйПользовательИБ.Роли.Добавить(Элем.Значение);
			КонецЦикла;
			НовыйПользовательИБ.Записать();
			ОбъектПользователь              = Справочники.Пользователи.СоздатьЭлемент();
			ОбъектПользователь.Код          = ИмяПользователя;
			ОбъектПользователь.Наименование = ПолноеИмяПользователя;
			Попытка
				ОбъектПользователь.Записать();
	        Исключение
	            #Если Клиент Тогда
				Предупреждение("Пользователь : Программист не был найден в справочнике пользователей. Возникла ошибка при добавлении пользователя в справочник.
					|" + ОписаниеОшибки());
				ЗавершитьРаботуСистемы(Ложь);
	            #КонецЕсли
			КонецПопытки;
			ТекущийПользователь = ОбъектПользователь.Ссылка;
			
			
КонецПроцедуры

Процедура ПередНачаломРаботыСистемы(Отказ)
	// 21.01.2014 VS++ Проверка на установку региональных настроек БД администратором
	КонтрольноеЧисло = 9999;
	Если СтрДлина(КонтрольноеЧисло) > 4 Тогда 
		Предупреждение("Администрирование-->Региональные настройки информационной базы-->Группировка должно быть равно нулю!
		|Сообщите об ошибке администратору системы");
		ПрекратитьРаботуСистемы();
	КонецЕсли;
	
	
	Если НЕ РольДоступна("ОператорККМ") Тогда
		МассивПИБ = ПользователиИнформационнойБазы.ПолучитьПользователей();
		Если МассивПИБ.Количество() = 0 Тогда
			СписокМетаЯзыков = Новый СписокЗначений;
			Для каждого МетаЯзык из Метаданные.Языки Цикл
				СписокМетаЯзыков.Добавить(МетаЯзык);
			КонецЦикла;
			// Программист
			СписокРолей = Новый СписокЗначений;
			СписокРолей.Добавить(Метаданные.Роли.АдминистративныеФункции);
			СписокРолей.Добавить(Метаданные.Роли.АдминистраторККМ);
			СписокРолей.Добавить(Метаданные.Роли.ПолныеПрава);
			СписокРолей.Добавить(Метаданные.Роли.Программист);
			ДобавитьПользователя("Программист", "Программист", СписокРолей, Метаданные.Интерфейсы.Полный, Ложь);
			// Почтальон
			СписокРолей = Новый СписокЗначений;
			СписокРолей.Добавить(Метаданные.Роли.АдминистраторККМ);
			СписокРолей.Добавить(Метаданные.Роли.ПолныеПрава);
			СписокРолей.Добавить(Метаданные.Роли.Пользователь);
			ДобавитьПользователя("Почтальон", "Почтальон", СписокРолей, Метаданные.Интерфейсы.Пустой, Ложь);
			// Администратор ККМ
			СписокРолей = Новый СписокЗначений;
			СписокРолей.Добавить(Метаданные.Роли.АдминистраторККМ);
			СписокРолей.Добавить(Метаданные.Роли.ОператорККМ);
			СписокРолей.Добавить(Метаданные.Роли.Пользователь);
			ДобавитьПользователя("АдминистраторККМ", "Администратор ККМ", СписокРолей, Метаданные.Интерфейсы.Полный, Ложь);
			
			ПрекратитьРаботуСистемы(Истина,"/N Программист");
		КонецЕсли;
	КонецЕсли;

	//ккк = Константы.ЭтоСозданиеНачальногоОбраза.СоздатьМенеджерЗначения();			
	//ккк.Значение  = Ложь;       													
	//Попытка
	//ккк.Записать();   
	//Исключение                                             
	//КонецПопытки;
			
КонецПроцедуры

Процедура ПриНачалеРаботыСистемы()
	глТекПользовательИБ					= ПользователиИнформационнойБазы.ТекущийПользователь();
	// ++VS 24.12.2013 При старте путь к БД будет всегда считываться с файла DBPath.txt
	// Необходимо считывать до обновлений БД
	УстановитьАдресаКасс_DBPath();
	
	Если КонфигурацияИзменена() тогда
		Режим = РежимДиалогаВопрос.ДаНет;
		Ответ = Вопрос("Основная конфигурация ОТЛИЧАЕТСЯ от конфигурации БД !!!  ОБНОВИТЬ ??? ",Режим,0,,"ВНИМАНИЕ ОБНОВЛЕНИЯ НЕ УСТАНОВЛЕННЫ !!! ");
		Если Ответ = КодВозвратаДиалога.Да Тогда
		    // ++VS 24.12.2013
			// Синхронизируем конфигурацию базы данных с основной конф.
			ОбновлениеБД.ОбновлениеКонфигурацииБД();
		КонецЕсли;
	Иначе 
	//	// ++VS 24.12.2013
	//	// Установка обновлений на основную конф. + синхронизация с конф. базы данных
	//	ОбновлениеБД.УстановкаОбновлений();	
		ОбновлениеБД.ВыполнитьОбновление();
    КонецЕсли;	
	
	Константы.ПризнакНачалаУстановкиОбновлений.Установить(Ложь);		
	
	глТекущийПользователь 			= ПараметрыСеанса.ТекущийПользователь;

	ОткрытиеСмены.прУстановитьЗаголовокСистемы();
	
	Если ПустаяСтрока(Константы.Розница_Сервер.Получить()) Тогда
		Константы.Розница_Сервер.Установить("http://rtk.prostor.ua/bas_roznica/ws/dataforstore.1cws?wsdl");
	КонецЕсли;	
	
	//вывод окна с номером версии
	ПолучитьОбщуюФорму("ФормаОПрограмме").ОткрытьМодально(2);
	
	//Закрыть доступ к данным БД под пользователем Почтальон
	НашПользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
	Если СокрЛП(НашПользователь.Имя) = "Почтальон" Тогда
		Отказ 		= Истина;
		Предупреждение("Пользователь Почтальон не предназначен для интерактивной работы!", 5, "Критическая ошибка системы");
		ЗаписьЖурналаРегистрации("МодульОбычногоПриложения.ПриНачалеРаботыСистемы()", УровеньЖурналаРегистрации.Ошибка, , ,"ОШИБКА:Попытка интерактивного входа под пользователем Почтальон",);
		ПрекратитьРаботуСистемы();
	КонецЕсли;

		
	// Автоматичексий запуск Обработки РМК
	Если  РольДоступна("ОператорККМ") И НЕ РольДоступна("АдминистраторККМ") Тогда 
		Обработки.РМК.ПолучитьФорму("Форма").Открытьмодально();
	КонецЕсли;
	
КонецПроцедуры // ПриНачалеРаботыСистемы()

Процедура ПередЗавершениемРаботыСистемы(Отказ)
	
	//Если глЗапрашиватьПодтверждениеПриЗакрытии <> Ложь Тогда
	//	ЗапрашиватьПотверждение = УправлениеПользователями.ПолучитьЗначениеПоУмолчанию(глТекущийПользователь,
	//														  "ЗапрашиватьПодтверждениеПриЗакрытии");
	//	Если ЗапрашиватьПотверждение Тогда
			Ответ = Вопрос("Завершить работу с программой?", РежимДиалогаВопрос.ДаНет);
			Отказ = (Ответ = КодВозвратаДиалога.Нет);
	//	КонецЕсли;
	//КонецЕсли;
	
	//Если НЕ Отказ Тогда
	//	
	//	//// отдельно получаем настройки для которых нужно выполнить обмен при выходе из программы
	//	//ПроцедурыОбменаДанными.ВыполнитьОбменПриЗавершенииРаботыПрограммы(глЗначениеПеременной("глОбработкаАвтоОбменДанными"));
	//		
	//КонецЕсли;

КонецПроцедуры

Процедура ПриЗавершенииРаботыСистемы()
	
	НашПользователь = ПользователиИнформационнойБазы.ТекущийПользователь();
	Если СокрЛП(НашПользователь.Имя) = "АдминистраторККМ" ИЛИ РольДоступна("АдминистраторККМ") Тогда
		НашПользователь.Пароль = РаботаСПользователями.ПолучитьПараметры("АдминистраторККМ");
		НашПользователь.Записать();
	КонецЕсли;
 	Если СокрЛП(НашПользователь.Имя) = "Программист" ИЛИ РольДоступна("Программист") Тогда
		НашПользователь.Пароль = РаботаСПользователями.ПолучитьПараметры("Программист");
		НашПользователь.Записать();
	КонецЕсли;

	//СОМ_Объект_АльтернативногоСервера = Неопределено;
	//СОМ_Объект_ДополнительногоСервера = Неопределено;
	СОМСоединительУТ                  = Неопределено;
	// Показ финальной дополнительной информации
	//Форма = Обработки.ДополнительнаяИнформация.Создать();
	//Форма.ВыполнитьДействие();
	////
	

КонецПроцедуры


Функция ПолучитьОбработкуТО() Экспорт
	Если Константы.ТО_МодельФР.Получить()=1 Тогда 
		глОбработкаТО	= Обработки.ТО_IKC_E260T.Создать();	
	ИначеЕсли Константы.ТО_МодельФР.Получить()=2 Тогда 
		глОбработкаТО	= Обработки.ТО_IKC_E810T.Создать();
	ИначеЕсли Константы.ТО_МодельФР.Получить()=3 Тогда 
		глОбработкаТО	= Обработки.ТО_Datecs_FP_3530T.Создать();	
	ИначеЕсли Константы.ТО_МодельФР.Получить()=4 Тогда 
		глОбработкаТО	= Обработки.ТО_MINI_FP82.Создать();	
	ИначеЕсли Константы.ТО_МодельФР.Получить()=5 Тогда 
		глОбработкаТО	= Обработки.ТО_Datecs_OPOS.Создать();	
	ИначеЕсли Константы.ТО_МодельФР.Получить()=6 Тогда 
		Если глОбработкаЭмулятор = Неопределено Тогда
			глОбработкаЭмулятор	= Обработки.ТО_ЭмуляторФР.Создать();	
		КонецЕсли;	
		глОбработкаТО = глОбработкаЭмулятор;
	КонецЕсли;	

	Возврат глОбработкаТО;
	
КонецФункции

Функция ПолучитьОбработкуТО_POSтерминал() Экспорт
	Если Константы.ТО_POSтерминал_ВидОбработки.Получить()=1 Тогда 
		глОбработкаТО	= Обработки.ТО_POSтерминал_ПриватБанк.Создать();	
	ИначеЕсли Константы.ТО_POSтерминал_ВидОбработки.Получить()=2 Тогда 
		глОбработкаТО	= Обработки.ТО_POSтерминал_ПУМБ.Создать();
	ИначеЕсли Константы.ТО_POSтерминал_ВидОбработки.Получить()=3 Тогда 	
		глОбработкаТО	= Обработки.ТО_POSтерминал_ОщадБанк.Создать();
	КонецЕсли;	

	Возврат глОбработкаТО;
КонецФункции


//Функция ПолучитьСоединениеСБазойАльтернативногоСервераУФР(ПутьКБазе, ТипОткрытия = "V83.COMConnector") Экспорт
//	
//	Перем Соединитель, ИсточникБД;
//	
//	Состояние("Подключение ко второму рабочему месту кассира");
//	Соединитель   					= Неопределено;
//	Логин         					= "Почтальон";
//	Пасворд       					= РабочееМестоКассира.ПолучитьПараметры("Почтальон");
//	СтрСоединения 					= "File="""+СокрЛП(ПутьКбазе)+""";Usr="""+СокрЛП(Логин)+""";Pwd = """ + СокрЛП(Пасворд) + """;";
//	
//	СисИнфо = Новый СистемнаяИнформация;
//	//Если Найти(СисИнфо.ВерсияПриложения, "8.3.")<>0 Тогда 
//		Попытка
//			Соединитель   			= Новый COMObject("V83.COMConnector");
//	        СОМ_Объект 				= Соединитель.Connect(СтрСоединения);			
//			Возврат СОМ_Объект 
//		Исключение
//			Предупреждение(ОписаниеОшибки());
//		КонецПопытки;
//	//КонецЕсли;	
//		
//	Возврат Неопределено;
//КонецФункции

Процедура УстановитьАдресаКасс_DBPath() Экспорт 
	
 
	ЛокальныйПуть = "C:\cashserv\";
	CatalogueCashServ = Новый Файл(ЛокальныйПуть);
	Если CatalogueCashServ.Существует()	Тогда
		Константы.Путь.Установить(ЛокальныйПуть);
	Иначе
		ФСО 		= Новый COMОбъект("Scripting.FileSystemObject");
		ФСО_Диски 	= ФСО.Drives;
		Для каждого ФСО_Диск из ФСО_Диски Цикл
			БукваДиска = ФСО_Диск.DriveLetter;
			Если ФСО_Диск.DriveType = 2 И НЕ БукваДиска = "c" Тогда
				// Это жесткий диск
				ЛокальныйПуть 		= БукваДиска + ":\cashserv\";
				CatalogueCashServ 	= Новый Файл(ЛокальныйПуть);
				Если CatalogueCashServ.Существует()	Тогда
					Константы.Путь.Установить(ЛокальныйПуть);
					ФСО_Диск 	= Неопределено;
					ФСО_Диски	= Неопределено;
					ФСО      	= Неопределено;
					глПуть      = Константы.Путь.Получить();
					Прервать;
				Иначе 
					ЛокальныйПуть 		= "\\" + ИмяКомпьютера() + "\cashserv\";
					CatalogueCashServ 	= Новый Файл(ЛокальныйПуть);
					Если CatalogueCashServ.Существует()	Тогда
						Константы.Путь.Установить(ЛокальныйПуть);
						глПуть      = Константы.Путь.Получить();
					КонецЕсли;    //Проверка сетевого пути
				КонецЕсли;        //Проверка локального пути на прочих жестких дисках
			КонецЕсли;            //Проверка тапи диска
		КонецЦикла;               //Перебор дисков файловой системы
	КонецЕсли;                    //Проверка локального пути на С:
	
КонецПроцедуры	


// ПЕРЕМЕННЫЕ
//Plus1                     		= "1+1=3";
глПуть                    		= Константы.Путь.Получить();  // "D:\db\toLOV\db\"
РежимВозвратаЧека               = Ложь;
SaleListDbf						="\salelist.dbf";

глВыгрузитьФайлНаFTP_АварийныеРС= Ложь;
глСкачатьПредсказания			= Ложь;

//Смотрим = РабочееМестоКассира.ПолучитьПараметры();
а1								=1;
//22.03.2013
глДлиныПодстрок      			= Новый ТаблицаЗначений;
глРазрешенныеСимволы 			= Новый СписокЗначений;
глСписокЦифр         			= Новый СписокЗначений;
глСписокЦифр.Добавить(",");  //Десятичный знак внутри числа
глСписокЦифр.Добавить(".");  //Десятичный знак внутри числа

Массив = Новый Массив;
Массив.Добавить(Тип("Число"));
КвалЧисла1 = Новый КвалификаторыЧисла(1,0);
КвалЧисла2 = Новый КвалификаторыЧисла(2,0);
ТиЧисло1   =  Новый ОписаниеТипов(Массив, КвалЧисла1);
ТиЧисло2   =  Новый ОписаниеТипов(Массив, КвалЧисла2);

глДлиныПодстрок.Колонки.Добавить("ИндексМассива",  ТиЧисло2);
глДлиныПодстрок.Колонки.Добавить("ДлинаПодстроки", ТиЧисло2);
глДлиныПодстрок.Колонки.Добавить("ПрерватьЦикл",   ТиЧисло1);
Для ы = 48 По 57 Цикл
	глРазрешенныеСимволы.Добавить(Символ(ы));
	глСписокЦифр.Добавить(Символ(ы));
КонецЦикла;
Для ы = 97 По 122 Цикл
	глРазрешенныеСимволы.Добавить(Символ(ы));
КонецЦикла;
Для ы = 1072 По 1103 Цикл
	глРазрешенныеСимволы.Добавить(Символ(ы));
КонецЦикла;
глРазрешенныеСимволы.Добавить(Символ(1107));
глРазрешенныеСимволы.Добавить(Символ(1108));
глРазрешенныеСимволы.Добавить(Символ(1110));
глРазрешенныеСимволы.Добавить(Символ(1111));
глРазрешенныеСимволы.Добавить(Символ(32));


ТаблицаСписокФайловНаFTP_VS	= Новый ТаблицаЗначений;
ТаблицаСписокФайловНаFTP_VS.Колонки.Добавить("ИмяФайла");
ТаблицаСписокФайловНаFTP_VS.Колонки.Добавить("МаскаДляПоиска");
ТаблицаСписокФайловНаFTP_VS.Колонки.Добавить("КаталогИсточник");
ТаблицаСписокФайловНаFTP_VS.Колонки.Добавить("ИмяКаталога");
ТаблицаСписокФайловНаFTP_VS.Колонки.Добавить("ИмяПодкаталога");
ТаблицаСписокФайловНаFTP_VS.Колонки.Добавить("ПерезаписьНаFTP");


// Настройки для BPMonline (первые по умолчанию)
Если ПустаяСтрока(Константы.BPMonline_Адрес.Получить()) Тогда 
	Константы.BPMonline_Адрес.Установить("processing.prostor.ua");
КонецЕсли;	

Если Константы.BPMonline_ReceiveTimeout_Login.Получить()=0 Тогда		Константы.BPMonline_ReceiveTimeout_Login.Установить(5)		КонецЕсли;
Если Константы.BPMonline_ConnectTimeout_Login.Получить()=0 Тогда		Константы.BPMonline_ConnectTimeout_Login.Установить(5)		КонецЕсли;
Если Константы.BPMonline_SendTimeout_Login.Получить()=0 Тогда			Константы.BPMonline_SendTimeout_Login.Установить(5)			КонецЕсли;
Если Константы.BPMonline_ResolveTimeout_Login.Получить()=0 Тогда		Константы.BPMonline_ResolveTimeout_Login.Установить(5)		КонецЕсли;

Если Константы.BPMonline_ReceiveTimeout.Получить()=0 Тогда				Константы.BPMonline_ReceiveTimeout.Установить(15)			КонецЕсли;
Если Константы.BPMonline_ConnectTimeout.Получить()=0 Тогда				Константы.BPMonline_ConnectTimeout.Установить(15)			КонецЕсли;
Если Константы.BPMonline_SendTimeout.Получить()=0 Тогда					Константы.BPMonline_SendTimeout.Установить(15)				КонецЕсли;
Если Константы.BPMonline_ResolveTimeout.Получить()=0 Тогда				Константы.BPMonline_ResolveTimeout.Установить(15)			КонецЕсли;




// Настройки для FISHKA (первые по умолчанию)
//Константы.FISHKA_ОткрытьДоступ.Установить(Истина);
Если ПустаяСтрока(Константы.FISHKA_URL.Получить()) Тогда
	//Дьяченко А. 27.03.19 закомментил:  FISHKA_URL.Установить;  FISHKA_НеИспользовать.Установить(Истина);   FISHKA_ОткрытьДоступ.Установить(Ложь);
	//Константы.FISHKA_URL.Установить("https://partners.myfishka.com:4101/IntApi/axservices/pos1");
	Константы.FISHKA_ТаймаутPING.Установить(15);
	//Константы.FISHKA_НеИспользовать.Установить(Истина);
	//Константы.FISHKA_ОткрытьДоступ.Установить(Ложь);
КонецЕсли;	



// Таблици для хранения результатов после запросов BPMonline
ТабРезультат_RemainResult					= Новый ТаблицаЗначений;
ТабРезультат_RemainResult.Колонки.Добавить("CardNumber");	
ТабРезультат_RemainResult.Колонки.Добавить("BonusTypeCode");
ТабРезультат_RemainResult.Колонки.Добавить("BonusesStatusCode");
ТабРезультат_RemainResult.Колонки.Добавить("BonusQuantity");

ТабРезультат_TransactionsResult				= Новый ТаблицаЗначений;
ТабРезультат_TransactionsResult.Колонки.Добавить("CardNumber");	
ТабРезультат_TransactionsResult.Колонки.Добавить("TransactionTypeCode");
ТабРезультат_TransactionsResult.Колонки.Добавить("BonusTypeCode");
ТабРезультат_TransactionsResult.Колонки.Добавить("BonusesStatusCode");
ТабРезультат_TransactionsResult.Колонки.Добавить("BonusQuantity");

ТабРезультат_WriteOffBonus					= Новый ТаблицаЗначений;
ТабРезультат_WriteOffBonus.Колонки.Добавить("Position");	
ТабРезультат_WriteOffBonus.Колонки.Добавить("ProductCode");
ТабРезультат_WriteOffBonus.Колонки.Добавить("PaidByBonus");

ТабРезультат_CardAccountRemainsClass					= Новый ТаблицаЗначений;
ТабРезультат_CardAccountRemainsClass.Колонки.Добавить("BaseBonusQuantity");	
ТабРезультат_CardAccountRemainsClass.Колонки.Добавить("BonusQuantity");
ТабРезультат_CardAccountRemainsClass.Колонки.Добавить("BonusStatus");
ТабРезультат_CardAccountRemainsClass.Колонки.Добавить("BonusType");
ТабРезультат_CardAccountRemainsClass.Колонки.Добавить("Currency");

//Мулько
глФРКоличествоПопыток = 3;
// Дьяченко перенос акций в BPM
глАкционнаяСистемаBPM = Истина;