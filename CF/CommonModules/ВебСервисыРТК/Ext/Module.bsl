﻿#Область BAS_Розница_интерфейс

Функция BAS_РОЗНИЦА_ПолучитьАдминистративныеНастройки() Экспорт
	
	РезультатПолучения = Новый Структура("Успех, Комментарий");
	
	Попытка
		ВремяНачала = ТекущаяДата();
		Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore");
		Если Прокси = Неопределено Тогда
			РезультатПолучения.Успех = Ложь;
			РезультатПолучения.Комментарий = "Недоступен сервер получения данных. Повторите попытку позже";
			Возврат РезультатПолучения;
		КонецЕсли;
		АдминНастройки = Прокси.ПолучитьАдминистративныеНастройки(Константы.Розница_КодКассы.Получить());
		Если АдминНастройки.Результат Тогда
			НачатьТранзакцию();
			КодПодразделения = ?(АдминНастройки.Магазин.НомерМагазина = "999","6",АдминНастройки.Магазин.Код);
			ИскПодразделение = Справочники.Подразделения.НайтиПоКоду(КодПодразделения);
			Если ЗначениеЗаполнено(ИскПодразделение) Тогда
				обПодразделение = ИскПодразделение.ПолучитьОбъект();	
			Иначе
				обПодразделение = Справочники.Подразделения.СоздатьЭлемент();
				обПодразделение.Код = КодПодразделения;
			КонецЕсли;
			обПодразделение.ТестоваяКасса			= ?(АдминНастройки.Магазин.НомерМагазина="999", Истина, Ложь);
			обПодразделение.Наименование			= АдминНастройки.Магазин.Наименование;
			обПодразделение.НомерМагазина			= АдминНастройки.Магазин.НомерМагазина;
			обПодразделение.осн_СкладКод			= АдминНастройки.Склад.Код;
			обПодразделение.осн_СкладНаименование 	= АдминНастройки.Склад.Наименование;
			обПодразделение.ШК_Ануляции				= АдминНастройки.ШК_Ануляции;
			обПодразделение.ШК_Возврата				= АдминНастройки.ШК_Возврата;		
			обПодразделение.posCodeFISHKA			= АдминНастройки.Fishka_posCode;
			Для Каждого кассаККМ Из АдминНастройки.КассыККМ Цикл
				искКассаККМ = Справочники.КассыККМ.НайтиПоКоду(кассаККМ.Код);
				Если ЗначениеЗаполнено(искКассаККМ) Тогда
					обКассаККМ = искКассаККМ.ПолучитьОбъект();
				Иначе
					обКассаККМ = Справочники.КассыККМ.СоздатьЭлемент();
					обКассаККМ.код = кассаККМ.Код;
				КонецЕсли;
				обКассаККМ.Наименование				= кассаККМ.Наименование;
				обКассаККМ.СерийныйНомерФР_латиница	= СтрЗаменить(СтрЗаменить(СтрЗаменить(кассаККМ.Наименование, "ДО","DO"),"ПР","PR"),"АТ","AT");
				обКассаККМ.НомерМагазина 			= АдминНастройки.Магазин.НомерМагазина;	
				обКассаККМ.Записать();
				Если обКассаККМ.Наименование = ПараметрыФР.ФР_СерийныйНомер Тогда 
					обПодразделение.осн_КассаККМ = обКассаККМ.Ссылка;
					//для автоматизации работы тестовой кассы		
					Если СокрЛП(Константы.осн_Подразделение.Получить().Код) = "6" Тогда 
						ПараметрыФР.ФР_ФискальныйНомер 	= обКассаККМ.ФискальныйНомер;
						ПараметрыФР.ФР_НомерZОтчета  	= обКассаККМ.НомерZОтчета + 1;
					КонецЕсли;			
					обКассаККМ.ФискальныйНомер 	= ПараметрыФР.ФР_ФискальныйНомер;
					обКассаККМ.НомерZОтчета 	= ПараметрыФР.ФР_НомерZОтчета;
					обКассаККМ.Записать();
				КонецЕсли;	
			КонецЦикла;
			обПодразделение.Записать();
			
			Константы.осн_Подразделение.Установить(обПодразделение.Ссылка);
			Константы.осн_КассаККМ.Установить(обПодразделение.осн_КассаККМ);
			Константы.ШК_Ануляции.Установить(обПодразделение.ШК_Ануляции);
			Константы.ШК_Возврата.Установить(обПодразделение.ШК_Возврата);
			//Мулько К.П.
			//Получить строки для рекламы в чеке
			//-----------
			Константы.ТекстРекламаДляЧека.Установить(АдминНастройки.ТаблицаСтрокиЧекаРеклама);
			//-----------
			Константы.ТО_POSтерминал_НовыйВидВозврата.Установить(АдминНастройки.ТО_POSтерминал_НовыйВидВозврата);
			Константы.FISHKA_URL.Установить(АдминНастройки.Fishka_URL);
			Константы.FISHKA_МинимальнаяСумма.Установить(АдминНастройки.Fishka_МинимальнаяСумма);
			Константы.BPMonline_НеИспользовать.Установить(АдминНастройки.BPM_ЗакрытьДоступ);
		 	Константы.BPM_ОтправлятьВсеЧеки.Установить(АдминНастройки.BPM_ОтправкаВсехЧеков);
			Константы.BPM_РегистрацияВПроцессинге.Установить(АдминНастройки.BPM_РегистрацияВПроцессинге);
			Константы.BPM_АкцииЧерезBPM.Установить(АдминНастройки.BPM_АкцииЧерезBPM);
			Константы.ФР_СниматьКопиюZОтчета.Установить(АдминНастройки.ФР_СниматьКопиюZОтчета);
			Константы.ФР_ПаузаПослеZОтчета.Установить(АдминНастройки.ФР_ПаузаПослеZОтчета);
			Константы.ПередаватьЧекиВРТК.Установить(АдминНастройки.ПередаватьЧекиВРТК);
			
			СтараяКассаККМ = Константы.осн_КассаККМ.Получить();	
			Если ЗначениеЗаполнено(СтараяКассаККМ) Тогда
				строкаСтараяКассаККМ = "ФР: "+СокрЛП(СтараяКассаККМ.Код) + "/" + СокрЛП(СтараяКассаККМ.Наименование) + "/" + СокрЛП(СтараяКассаККМ.НомерМагазина)+".";
			Иначе
				строкаСтараяКассаККМ = "АВАРИЯ! НЕ УСТАНОВЛЕН ФИСКАЛЬНЫЙ НОМЕР РЕГИСТРАТОРА ИЛИ НОМЕР КАССЫ!";
			КонецЕсли;
			
			НоваяКассаККМ = обПодразделение.осн_КассаККМ;			
			Если ЗначениеЗаполнено(НоваяКассаККМ) Тогда
				строкаНоваяКассаККММ = "ФР: "+СокрЛП(НоваяКассаККМ.Код) + "/" + СокрЛП(НоваяКассаККМ.Наименование) + "/" + СокрЛП(НоваяКассаККМ.НомерМагазина)+".";
			Иначе
				строкаНоваяКассаККМ = "АВАРИЯ! НЕ УСТАНОВЛЕН ФИСКАЛЬНЫЙ НОМЕР РЕГИСТРАТОРА ИЛИ НОМЕР КАССЫ!";
			КонецЕсли;
			
			Если СтараяКассаККМ<>НоваяКассаККМ  Тогда	
				Предупреждение("ВНИМАНИЕ!!! Серийный номер РРО был изменен: " + строкаСтараяКассаККМ + " => " + строкаНоваяКассаККММ,, "ВНИМАНИЕ!!! Серийный номер РРО был изменен !!!");
			КонецЕсли;
			
			РабочееМестоКассира.УстановитьГраницуПараметраКассыККМ(Перечисления.ВидыПараметровКассыККМ.АдминистративныеНастройки, ТекущаяДата());
			ЗафиксироватьТранзакцию();
			
			Статус = "Получены";
			РезультатПолучения.Успех = Истина;
			РезультатПолучения.Комментарий = "";
		Иначе
			Статус = "Ошибка";
			РезультатПолучения.Успех = Ложь;
			РезультатПолучения.Комментарий = "Не найдена касса на веб-сервисе с кодом " + Константы.Розница_КодКассы.Получить();
		КонецЕсли;
	Исключение
		Если ТранзакцияАктивна() Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		Статус = "Ошибка";
		РезультатПолучения.Успех = Ложь;
		РезультатПолучения.Комментарий = "ОШИБКА, ОБРАТИТЕСЬ К АДМИНИСТРАТОРУ. Причина: " + ОписаниеОшибки();
	КонецПопытки;
	ВремяПолучения = ОбщегоНазначения.ПреобразоватьСекунды(ТекущаяДата() - ВремяНачала);
	BAS_РОЗНИЦА_ЗаписатьВремяПолученияДанных("АдминистративныеНастройки",Статус,РезультатПолучения.Комментарий + " (" + ВремяПолучения + ")");
	Возврат РезультатПолучения;
КонецФункции

Функция BAS_РОЗНИЦА_ПолучитьАкционныеМеханики() Экспорт
	РезультатПолучения = Новый Структура("Успех,Комментарий");
	Попытка	
		ВремяНачала = ТекущаяДата();
		Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore",300);
		Если Прокси = Неопределено Тогда
			РезультатПолучения.Успех = Ложь;
			РезультатПолучения.Комментарий = "Недоступен сервер получения данных. Повторите попытку позже";
			Возврат РезультатПолучения;
		КонецЕсли;
		АкционныеМеханики = Прокси.ПолучитьАкционныеМеханикиДляКассы(Константы.Розница_КодКассы.Получить());
		Если АкционныеМеханики.Результат Тогда		
			НачатьТранзакцию();
			НЗ = РегистрыСведений.УсловияПоАкции.СоздатьНаборЗаписей();
			НЗ.Очистить();
			НЗ.Записать();			
			КолАкций = 0;
			ТаблицаМаркетинговыеАкции = АкционныеМеханики.ТаблицаМаркетинговыеАкции.Получить();
			Для Каждого МаркетинговаяАкция Из ТаблицаМаркетинговыеАкции Цикл	 																								
				НоваяЗапись									= РегистрыСведений.УсловияПоАкции.СоздатьМенеджерЗаписи();
				НоваяЗапись.ШК								= МаркетинговаяАкция.ШК;
				НоваяЗапись.ДатаНачала	 					= МаркетинговаяАкция.ДатаНачала;
				НоваяЗапись.ДатаОкончания	 				= МаркетинговаяАкция.ДатаОкончания;
		        НоваяЗапись.ТипАкции 						= МаркетинговаяАкция.ТипАкции;
				НоваяЗапись.НомерАкции						= МаркетинговаяАкция.НомерАкции; 
				НоваяЗапись.КоличествоГруппЗакупки			= МаркетинговаяАкция.КоличествоГруппЗакупки;
				НоваяЗапись.КоличествоТовараГрЗакупки		= МаркетинговаяАкция.КоличествоТовараГрЗакупки;
				НоваяЗапись.СуммаЗакупки					= МаркетинговаяАкция.СуммаЗакупки;
				НоваяЗапись.КоличествоГруппВыдачи			= МаркетинговаяАкция.КоличествоГруппВыдачи;
				НоваяЗапись.КоличествоТовараГрВыдачи		= МаркетинговаяАкция.КоличествоТовараГрВыдачи;
				НоваяЗапись.СкидкаПроцентГрВыдачи			= МаркетинговаяАкция.СкидкаПроцентГрВыдачи;
				НоваяЗапись.СкидкаПроцент					= МаркетинговаяАкция.СкидкаПроцент;
				НоваяЗапись.СкидкаСумма						= МаркетинговаяАкция.СкидкаСумма;
				НоваяЗапись.НаименованиеАкции				= МаркетинговаяАкция.НаименованиеАкции;
				НоваяЗапись.КоличествоПримененийАкции		= МаркетинговаяАкция.КоличествоПримененийАкции;
				НоваяЗапись.ГраницаПримАкции_ПроцентЧека	= МаркетинговаяАкция.ГраницаПримАкции_ПроцентЧека;
		       	НоваяЗапись.ГраницаПримАкции_СуммаЧека		= МаркетинговаяАкция.ГраницаПримАкции_СуммаЧека;
		       	НоваяЗапись.СкидкаСуммаГрВыдачи				= МаркетинговаяАкция.СкидкаСуммаГрВыдачи;
				НоваяЗапись.НастройкаАкцийПриСканБК			= МаркетинговаяАкция.НастройкаАкцийПриСканБК;			
				НоваяЗапись.БлокЛистовок_UUID_ИзУТ			= МаркетинговаяАкция.БлокЛистовок_UUID_ИзУТ;
				НоваяЗапись.БлокЛистовок_Код				= МаркетинговаяАкция.БлокЛистовок_Код;		
				НоваяЗапись.ТестАкцииНаКассе				= МаркетинговаяАкция.ТестАкцииНаКассе;		
				НоваяЗапись.ИгнорироватьАкциюЖелтыйЦенник	= МаркетинговаяАкция.ИгнорироватьАкциюЖелтыйЦенник;
				НоваяЗапись.ВыдаетьсяПодарочныйФонд			= МаркетинговаяАкция.ВыдаетьсяПодарочныйФонд;
				НоваяЗапись.ВидЦеныДляОпределенияСкидкиНаВесьЧек = Перечисления.ВидыЦенников[МаркетинговаяАкция.ВидЦеныДляОпределенияСкидкиНаВесьЧек];
				НоваяЗапись.ВидЦеныДляОпределенияСкидкиНаГруппуВыдачи = Перечисления.ВидыЦенников[МаркетинговаяАкция.ВидЦеныДляОпределенияСкидкиНаГруппуВыдачи];
				НоваяЗапись.Записать();
				КолАкций = КолАкций + 1;
			КонецЦикла;
			
			НЗ = РегистрыСведений.АкционныеТовары.СоздатьНаборЗаписей();
			НЗ.Очистить();
			НЗ.Записать();
			КолАкционныхТоваров = 0;
			ТаблицаАкционныеТовары = АкционныеМеханики.ТаблицаАкционныеТовары.Получить();
			Для Каждого АкционныйТовар Из ТаблицаАкционныеТовары Цикл
				НоваяЗапись 					= РегистрыСведений.АкционныеТовары.СоздатьМенеджерЗаписи();
				НоваяЗапись.НачАкции 			= АкционныйТовар.ДатаНачала;
				НоваяЗапись.КонАкции 			= АкционныйТовар.ДатаОкончания;
				НоваяЗапись.ТипАкции 			= АкционныйТовар.ТипАкции;
				НоваяЗапись.Акция 				= АкционныйТовар.НаименованиеАкции;
				НоваяЗапись.НомерАкции 			= АкционныйТовар.НомерАкции;
				НоваяЗапись.КодТовара 			= АкционныйТовар.КодТовара;
				НоваяЗапись.НомерГруппыТоваров 	= АкционныйТовар.НомерГруппыТоваров;
				НоваяЗапись.ПодарочныйФонд 		= АкционныйТовар.ПодарочныйФонд;
				НоваяЗапись.Записать();
				КолАкционныхТоваров = КолАкционныхТоваров + 1;
			КонецЦикла;
			РабочееМестоКассира.УстановитьГраницуПараметраКассыККМ(Перечисления.ВидыПараметровКассыККМ.УсловияАкций, ТекущаяДата());
			ЗафиксироватьТранзакцию();
			
			Статус = "Получены";
			РезультатПолучения.Успех = Истина;
			РезультатПолучения.Комментарий = "Акций получено: " + КолАкций + "; Товаров в акциях: " + КолАкционныхТоваров;
		Иначе
			Статус = "Ошибка";
			РезультатПолучения.Успех = Ложь;
			РезультатПолучения.Комментарий = "Не найдена касса на веб-сервисе с кодом " + Константы.Розница_КодКассы.Получить();
		КонецЕсли;
	Исключение
		Если ТранзакцияАктивна() Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		Статус = "Ошибка";
		РезультатПолучения.Успех = Ложь;
		РезультатПолучения.Комментарий = "ОШИБКА, ОБРАТИТЕСЬ К АДМИНИСТРАТОРУ. Причина: " + ОписаниеОшибки();
	КонецПопытки;
	ВремяПолучения = ОбщегоНазначения.ПреобразоватьСекунды(ТекущаяДата() - ВремяНачала);
	BAS_РОЗНИЦА_ЗаписатьВремяПолученияДанных("АкционныеМеханики",Статус,РезультатПолучения.Комментарий + " (" + ВремяПолучения + ")");
	Возврат РезультатПолучения;
КонецФункции

Функция BAS_РОЗНИЦА_ПолучитьДанныеПодарочныхСертификатов() Экспорт
	РезультатПолучения = Новый Структура("Успех,Комментарий");
	Попытка
		ВремяНачала = ТекущаяДата();
		ВсеДанные = Истина;
		Выборка = РегистрыСведений.СостояниеПС.Выбрать();
		Пока Выборка.Следующий() Цикл
			ВсеДанные = Ложь;
			Прервать;
		КонецЦикла;
		Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore");
		Если Прокси = Неопределено Тогда
			РезультатПолучения.Успех = Ложь;
			РезультатПолучения.Комментарий = "Недоступен сервер получения данных. Повторите попытку позже";
			Возврат РезультатПолучения;
		КонецЕсли;
		ДанныеСертификатов = Прокси.ПолучитьДанныеПодарочныхСертификатовДляКассы(Константы.Розница_КодКассы.Получить(),ВсеДанные);
		Если ДанныеСертификатов.Результат Тогда
			НачатьТранзакцию();
			КолЗаписей = 0;
			ТаблицаПодарочныеСертификаты = ДанныеСертификатов.ТаблицаПодарочныеСертификаты.Получить();
			Для Каждого ПодарочныйСертификат Из ТаблицаПодарочныеСертификаты Цикл
				НЗ = РегистрыСведений.СостояниеПС.СоздатьНаборЗаписей();
				НЗ.Отбор.ШК_ПС.Установить(ПодарочныйСертификат.ШК);
				НЗ.Прочитать();
				НЗ.Очистить();
				
				НоваяЗапись = НЗ.Добавить();
				НоваяЗапись.Период = ПодарочныйСертификат.Период;
				НоваяЗапись.ШК_ПС = ПодарочныйСертификат.ШК;
				НоваяЗапись.СтатусПС = ПодарочныйСертификат.СтатусПодарочногоСертификата;
				НоваяЗапись.НоминалПС = ПодарочныйСертификат.НоминалПодарочногоСертификата;
				НоваяЗапись.НомерМагазина = ПодарочныйСертификат.НомерМагазина;
				НоваяЗапись.СерийныйНомерФР = ПодарочныйСертификат.СерийныйНомерФискальногоРегистратора;
				НоваяЗапись.НомерЧекаККМ = ПодарочныйСертификат.НомерЧека;
				
				НЗ.Записать();
				КолЗаписей = КолЗаписей + 1;
			КонецЦикла;
			РабочееМестоКассира.УстановитьГраницуПараметраКассыККМ(Перечисления.ВидыПараметровКассыККМ.ПодарочныеСертификаты, ТекущаяДата());
			ЗафиксироватьТранзакцию();
			
			Статус = "Получены";
			РезультатПолучения.Успех = Истина;
			РезультатПолучения.Комментарий = "Получено записей по сертификатам: " + КолЗаписей;
		Иначе
			Статус = "Ошибка";
			РезультатПолучения.Успех = Ложь;
			РезультатПолучения.Комментарий = "Не найдена касса на веб-сервисе с кодом " + Константы.Розница_КодКассы.Получить();
		КонецЕсли;
	Исключение
		Если ТранзакцияАктивна() Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		Статус = "Ошибка";
		РезультатПолучения.Успех = Ложь;
		РезультатПолучения.Комментарий = "ОШИБКА, ОБРАТИТЕСЬ К АДМИНИСТРАТОРУ. Причина: " + ОписаниеОшибки();
	КонецПопытки;
	ВремяПолучения = ОбщегоНазначения.ПреобразоватьСекунды(ТекущаяДата() - ВремяНачала);
	BAS_РОЗНИЦА_ЗаписатьВремяПолученияДанных("ДанныеПодарочныхСертификатов",Статус,РезультатПолучения.Комментарий + " (" + ВремяПолучения + ")");
	Возврат РезультатПолучения;
КонецФункции

Функция BAS_РОЗНИЦА_ПолучитьПрайс() Экспорт
	РезультатПолучения = Новый Структура("Успех,Комментарий");	
	Попытка	
		ВремяНачала = ТекущаяДата();
		ВсеДанные = Истина;
		Выборка = РегистрыСведений.Прайс.Выбрать();
		Пока Выборка.Следующий() Цикл
			ВсеДанные = Ложь;
			Прервать;
		КонецЦикла;
		Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore",600);
		Если Прокси = Неопределено Тогда
			РезультатПолучения.Успех = Ложь;
			РезультатПолучения.Комментарий = "Недоступен сервер получения данных. Повторите попытку позже";
			Возврат РезультатПолучения;
		КонецЕсли;
		ДанныеПрайса = Прокси.ПолучитьПрайсДляКассы(Константы.Розница_КодКассы.Получить(),ВсеДанные);
		Если ДанныеПрайса.Результат Тогда		
			НачатьТранзакцию();
			Если ДанныеПрайса.ПерваяЗагрузка Тогда
				НЗ = РегистрыСведений.Прайс.СоздатьНаборЗаписей();
				НЗ.Записать();
			КонецЕсли;
			
			КолЗаписей = 0;
			ТаблицаПрайса = ДанныеПрайса.ТаблицаПрайса.Получить();
			Для Каждого СтрокаПрайса Из ТаблицаПрайса Цикл
				НЗ = РегистрыСведений.Прайс.СоздатьНаборЗаписей();
				НЗ.Отбор.CODE.Установить(СтрокаПрайса.КодНоменклатуры);
				НЗ.Отбор.BAR.Установить(СтрокаПрайса.ШК);
				НЗ.Прочитать();
				НЗ.Очистить();
				
				НоваяЗапись = НЗ.Добавить();
				НоваяЗапись.Период = ТекущаяДата();
				НоваяЗапись.CODE = СтрокаПрайса.КодНоменклатуры;
				НоваяЗапись.CODE_PREF = СтрокаПрайса.ПризнакНоменклатуры;
				НоваяЗапись.BAR = СтрокаПрайса.ШК;
				НоваяЗапись.NAME = СтрокаПрайса.Наименование;
				НоваяЗапись.PRICE = СтрокаПрайса.Цена;
				НоваяЗапись.FULLPRICE = СтрокаПрайса.ЦенаБезСкидки;
				НоваяЗапись.DISCOUNT = СтрокаПрайса.Скидка;
				НоваяЗапись.NALOG = СтрокаПрайса.Налог;
				НоваяЗапись.GROUP_ID = СтрокаПрайса.КодГруппы;
				НоваяЗапись.DATASTR1 = СтрокаПрайса.ДополнительнаяИнформация1;
				НоваяЗапись.DATASTR2 = СтрокаПрайса.ДополнительнаяИнформация2;		
			
				НЗ.Записать();
				КолЗаписей = КолЗаписей + 1;
			КонецЦикла;
			РабочееМестоКассира.УстановитьГраницуПараметраКассыККМ(Перечисления.ВидыПараметровКассыККМ.ПрайсЛист, ТекущаяДата());
			ЗафиксироватьТранзакцию();
			
			Статус = "Получены";
			РезультатПолучения.Успех = Истина;
			РезультатПолучения.Комментарий = "Получено записей по прайсу: " + КолЗаписей; 
		Иначе
			Статус = "Ошибка";
			РезультатПолучения.Успех = Ложь;
			РезультатПолучения.Комментарий = "Не найдена касса на веб-сервисе с кодом " + Константы.Розница_КодКассы.Получить();;
		КонецЕсли;
	Исключение
		Если ТранзакцияАктивна() Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		Статус = "Ошибка";
		РезультатПолучения.Успех = Ложь;
		РезультатПолучения.Комментарий = "ОШИБКА, ОБРАТИТЕСЬ К АДМИНИСТРАТОРУ. Причина: " + ОписаниеОшибки();;
	КонецПопытки;
	ВремяПолучения = ОбщегоНазначения.ПреобразоватьСекунды(ТекущаяДата() - ВремяНачала);
	BAS_РОЗНИЦА_ЗаписатьВремяПолученияДанных("Прайс",Статус,РезультатПолучения.Комментарий + " (" + ВремяПолучения + ")");
	Возврат РезультатПолучения;
КонецФункции

//Мулько К.П.
Функция BAS_РОЗНИЦА_ПолучитьТекстыПредсказаний() Экспорт
	
	РезультатПолучения = Новый Структура("Успех,Комментарий");
	Попытка	
		ВремяНачала = ТекущаяДата();
		Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore",300);
		Если Прокси = Неопределено Тогда
			РезультатПолучения.Успех = Ложь;
			РезультатПолучения.Комментарий = "Недоступен сервер получения данных. Повторите попытку позже";
			Возврат РезультатПолучения;
		КонецЕсли;
	    ТекстыПредсказаний = Прокси.ПолучитьТекстыПредсказанийЧекаККМ();
		Если ТекстыПредсказаний.Результат Тогда
			НачатьТранзакцию();
			Если ТекстыПредсказаний = Неопределено Тогда
				Возврат РезультатПолучения;
			Иначе
				НаборЗаписей = РегистрыСведений.ТекстовоеСообщениеНаЧеке.СоздатьНаборЗаписей();
				НаборЗаписей.Записать();

				Для Каждого СтрокаТекстаПредсказаний Из ТекстыПредсказаний.ТаблицаСообщений.Получить() Цикл
					НоваяЗапись = НаборЗаписей.Добавить(); 
   					НоваяЗапись.НомСтроки			= СтрокаТекстаПредсказаний.НомСтроки; 
					НоваяЗапись.ЗаглавиеСообщения 	= СтрокаТекстаПредсказаний.ЗаглавиеСообщения; 
					НоваяЗапись.ТекстСообщения 		= СтрокаТекстаПредсказаний.ТекстСообщения; 
					НоваяЗапись.КонецСообщения 		= СтрокаТекстаПредсказаний.КонецСообщения; 
				КонецЦикла;
				
				НаборЗаписей.Записать();
			КонецЕсли;	
			РабочееМестоКассира.УстановитьГраницуПараметраКассыККМ(Перечисления.ВидыПараметровКассыККМ.ТекстыПредсказаний, ТекущаяДата());
			ЗафиксироватьТранзакцию();
			
			Статус = "Получены";
			РезультатПолучения.Успех = Истина;
			РезультатПолучения.Комментарий = "";
		Иначе
			Статус = "Ошибка";
			РезультатПолучения.Успех = Ложь;
			РезультатПолучения.Комментарий = "Не удалось загрузить тексты предсказаний для чека ККМ";
		КонецЕсли;
		
	Исключение
		
		Если ТранзакцияАктивна() Тогда
			ОтменитьТранзакцию();
		КонецЕсли;
		Статус = "Ошибка";
		РезультатПолучения.Успех = Ложь;
		РезультатПолучения.Комментарий = "ОШИБКА, ОБРАТИТЕСЬ К АДМИНИСТРАТОРУ. Причина: " + ОписаниеОшибки();
		
	КонецПопытки;
	
	ВремяПолучения = ОбщегоНазначения.ПреобразоватьСекунды(ТекущаяДата() - ВремяНачала);
	BAS_РОЗНИЦА_ЗаписатьВремяПолученияДанных("ТекстыПредсказаний",Статус,РезультатПолучения.Комментарий + " (" + ВремяПолучения + ")");
	
	Возврат РезультатПолучения;
		
КонецФункции	

Функция BAS_РОЗНИЦА_ПередатьДанныеОТерминале(НомерОбработки, СтрокаИнфо) Экспорт
	Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore");
	Возврат Прокси.ЗаписатьИнформациюОТерминале(Константы.Розница_КодКассы.Получить(), НомерОбработки, СтрокаИнфо);
КонецФункции	

Функция BAS_РОЗНИЦА_ПередатьДанныеОZОтчетахФР(КодКассы, ТЗЖурналZОтчетов) Экспорт
	
	Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore");
	Возврат Прокси.ЗаписатьЖурналZОтчетовФР(КодКассы, ТЗЖурналZОтчетов);
	
КонецФункции	

Функция BAS_РОЗНИЦА_ПередатьДанныеОZОтчетахТерминал(КодКассы, ТЗЖурналZОтчетов) Экспорт
	
	Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore");
	Возврат Прокси.ЗаписатьЖурналZОтчетовТерминал(КодКассы, ТЗЖурналZОтчетов);
	
КонецФункции	

Процедура BAS_РОЗНИЦА_ЗаписатьВремяПолученияДанных(ВидДанных,Статус,Комментарий = "")
	Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore");
	Прокси.ЗаписатьВремяПолученияДанных(Константы.Розница_КодКассы.Получить(),ВидДанных,Статус,Комментарий);
КонецПроцедуры

//Мулько 02.04.2020
Функция BAS_РОЗНИЦА_ПолучитьОстатокТовара(КодТовара) Экспорт
	
	Остаток = 0;
	
	//Попытка	
		Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore",300);
		Если Прокси = Неопределено Тогда
			Возврат Остаток;
		КонецЕсли;
	    Остаток = Прокси.ПолучитьОстатокТовара(КодТовара, Константы.Розница_КодКассы.Получить());
		Возврат Остаток;
	//Исключение
	//	Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Предупреждение, "BAS_РОЗНИЦА_ПолучитьОстатокТовара", "ОШИБКА: "+ОписаниеОшибки(), Неопределено, Неопределено, "ВебСервисыРТК");
	//	Возврат 0;
	//КонецПопытки;
	
КонецФункции	

#КонецОбласти

#Область ОтправкаЧеков

Процедура BAS_РОЗНИЦА_ОправитьSALE(ВсеЧекиЗаДень = Неопределено) Экспорт
	
	Запрос = Новый Запрос;
	Текст = "ВЫБРАТЬ ПЕРВЫЕ 30
        |   *,
   		|	ПРЕДСТАВЛЕНИЕ(ЧекККМ.АкционнаяСистема) КАК АкционнаяСистема,
		|	ПРЕДСТАВЛЕНИЕ(ЧекККМ.СостояниеЧекаККМ) КАК СостояниеЧекаККМ,
   		|	ПРЕДСТАВЛЕНИЕ(ЧекККМ.ВидОперацииЧекаККМ) КАК ВидОперацииЧекаККМ,
		|	ПРЕДСТАВЛЕНИЕ(ЧекККМ.FISHKA_СостояниеЧекаККМ) КАК FISHKA_СостояниеЧекаККМ,
   		|	ПРЕДСТАВЛЕНИЕ(ЧекККМ.BPMonline_СостояниеЧекаККМ) КАК BPMonline_СостояниеЧекаККМ
   		|ИЗ
   		|	Документ.ЧекККМ КАК ЧекККМ
   		|ГДЕ
   		|	ЧекККМ.Проведен
   		|	И НЕ ЧекККМ.ОтправленНаСервер
		|	И ЧекККМ.СостояниеЧекаККМ <> &СостояниеЧекаККМ";
				
	Если ВсеЧекиЗаДень = Истина Тогда 
		Текст = СтрЗаменить(Текст,"ПЕРВЫЕ 30","");
		Текст = Текст +	"
			|	И ЧекККМ.Дата МЕЖДУ &ДатаНачала И &ДатаОкончания"; 
	КонецЕсли;

	Текст = Текст +	"
			|	УПОРЯДОЧИТЬ ПО ЧекККМ.Дата
		    |";
	Запрос.УстановитьПараметр("ДатаНачала",НачалоДня(ТекущаяДата()));
	Запрос.УстановитьПараметр("ДатаОкончания",КонецДня(ТекущаяДата()));
	Запрос.УстановитьПараметр("СостояниеЧекаККМ", Перечисления.СостояниеЧека.Отложенный); //Мулько 01.04.2020
	
	Запрос.Текст = Текст;				
	РезультатЗапроса = Запрос.Выполнить();	
	ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	
	ТаблицаШапкаОбщая		= Новый ТаблицаЗначений;
	ТаблицаТоварыОбщая		= Новый ТаблицаЗначений;
	ТаблицаСкидкиОбщая		= Новый ТаблицаЗначений;
	ТаблицаДвижениеПСОбщая	= Новый ТаблицаЗначений;

	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		
		UUID = ВыборкаДетальныеЗаписи.Ссылка.UUID();
		
	  	ТаблицаШапка = ОбщегоНазначения.ПолучитьШапкаЧекаККМ_ОтправитьНаСервер(ВыборкаДетальныеЗаписи.Ссылка);
		ТаблицаШапка.Колонки.Добавить("UUID", Новый ОписаниеТипов("Строка",,,, Новый КвалификаторыСтроки(СтрДлина(Новый УникальныйИдентификатор()))));
	    ТаблицаШапка.ЗаполнитьЗначения(UUID, "UUID");
		
		Если ТаблицаШапкаОбщая.Количество() = 0 Тогда
			ТаблицаШапкаОбщая = ТаблицаШапка.Скопировать();
		Иначе
			ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаШапка, ТаблицаШапкаОбщая);
		КонецЕсли;	
		
		ТаблицаТовары = ОбщегоНазначения.ПолучитьТЧ_ТоварыЧекаККМ_ОтправитьНаСервер(ВыборкаДетальныеЗаписи.Ссылка);
		ТаблицаТовары.Колонки.Добавить("UUID", Новый ОписаниеТипов("Строка",,,, Новый КвалификаторыСтроки(СтрДлина(Новый УникальныйИдентификатор()))));
		//Дополним коды нулями
		Для Каждого СтрокаТовары ИЗ ТаблицаТовары Цикл
			СтрокаТовары.НоменклатураКод = ОбщегоНазначения.ДополнитьКодНулями(СтрокаТовары.НоменклатураКод);
		КонецЦикла;
		ТаблицаТовары.ЗаполнитьЗначения(UUID, "UUID");
		Если ТаблицаТоварыОбщая.Количество() = 0 Тогда
			ТаблицаТоварыОбщая = ТаблицаТовары.Скопировать();
		Иначе
			ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаТовары, ТаблицаТоварыОбщая);
		КонецЕсли;	
		
		ТаблицаСкидки = ОбщегоНазначения.ПолучитьТЧ_ЖурналСкидокЧекаККМ_ОтправитьНаСервер(ВыборкаДетальныеЗаписи.Ссылка);
		ТаблицаСкидки.Колонки.Добавить("UUID", Новый ОписаниеТипов("Строка",,,, Новый КвалификаторыСтроки(СтрДлина(Новый УникальныйИдентификатор()))));
		Для Каждого СтрокаСкидки ИЗ ТаблицаСкидки Цикл
			СтрокаСкидки.НоменклатураКод = ОбщегоНазначения.ДополнитьКодНулями(СтрокаСкидки.НоменклатураКод);
		КонецЦикла;
		ТаблицаСкидки.ЗаполнитьЗначения(UUID, "UUID");
		Если ТаблицаСкидкиОбщая.Количество() = 0 Тогда
			ТаблицаСкидкиОбщая = ТаблицаСкидки.Скопировать();
		Иначе
			ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаСкидки, ТаблицаСкидкиОбщая);
		КонецЕсли;	
		
		ТаблицаДвиженияПС = ОбщегоНазначения.ПолучитьТЧ_ДвиженияПСЧекаККМ_ОтправитьНаСервер(ВыборкаДетальныеЗаписи.Ссылка);
		ТаблицаДвиженияПС.Колонки.Добавить("UUID", Новый ОписаниеТипов("Строка",,,, Новый КвалификаторыСтроки(СтрДлина(Новый УникальныйИдентификатор()))));
		ТаблицаДвиженияПС.ЗаполнитьЗначения(UUID, "UUID");
		Если ТаблицаДвижениеПСОбщая.Количество() = 0 Тогда
			ТаблицаДвижениеПСОбщая = ТаблицаДвиженияПС.Скопировать();
		Иначе
			ОбщегоНазначения.ЗагрузитьВТаблицуЗначений(ТаблицаДвиженияПС, ТаблицаДвижениеПСОбщая);
		КонецЕсли;	
		
	КонецЦикла;	
	
	Если ТаблицаШапкаОбщая.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	Прокси = ОбщегоНазначения.ПолучитьПрокси(Константы.Розница_Сервер.Получить(),"Store","Webservice19","http://www.dataforstore.prostor.ua","DataForStore");
	ХранилищеШапка  	= Новый ХранилищеЗначения(ТаблицаШапкаОбщая, Новый СжатиеДанных(9));
	ХранилищеТовары 	= Новый ХранилищеЗначения(ТаблицаТоварыОбщая, Новый СжатиеДанных(9));
	ХранилищеСкидки 	= Новый ХранилищеЗначения(ТаблицаСкидкиОбщая, Новый СжатиеДанных(9));
	ХранилищеДвижениеПС = Новый ХранилищеЗначения(ТаблицаДвижениеПСОбщая, Новый СжатиеДанных(9));
	
	РезультатСервиса = Прокси.ЗаписатьДокументЧекККМ(ХранилищеШапка, ХранилищеТовары, ХранилищеСкидки, ХранилищеДвижениеПС);
	
	Если РезультатСервиса.Результат Тогда
		ТаблицаРезультат = РезультатСервиса.ТаблицаЗаписиЭлементов.Получить();
		Для Каждого СтрокаРезультат ИЗ ТаблицаРезультат Цикл
			
			UUID = Новый УникальныйИдентификатор(СтрокаРезультат.UUID);
			ЧекККМСсылка = Документы.ЧекККМ.ПолучитьСсылку(UUID);
			ОбъектЧекККМ = ЧекККМСсылка.ПолучитьОбъект();
			НовыйGUID = Новый УникальныйИдентификатор(СтрокаРезультат.UUID_ЧекаККМ_ИзРозница);
			ОбъектЧекККМ.UUID_ЧекаККМ_ИзРозница = НовыйGUID;
			ОбъектЧекККМ.ОтправленНаСервер = Истина;
			Попытка
				ОбъектЧекККМ.Записать(РежимЗаписиДокумента.Проведение);
			Исключение
				Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Предупреждение, "Запись чека", "Не перезаписан чек " + ВыборкаДетальныеЗаписи.Ссылка.НомерЧекаККМ + ". ОШИБКА: "+ОписаниеОшибки(), Неопределено, Неопределено, "ВебСервисыРТК");
			КонецПопытки;
			
		КонецЦикла;	
		Если СокрЛП(РезультатСервиса.ТекстСообщения) <> "" Тогда
			Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Ошибка, "Выгрузка чеков в РТК", "При выгрузке чеков в РТК были ошибки: " + СокрЛП(РезультатСервиса.ТекстСообщения), Неопределено, Неопределено, "ВебСервисыРТК");
		КонецЕсли;	
	Иначе	
		Сообщить(РезультатСервиса.ТекстСообщения);
	КонецЕсли;	

	
КонецПроцедуры

#КонецОбласти