﻿Перем НаборЗаписейЖурналРРО Экспорт; 
Перем ЕстьАварийныйЧектерминал Экспорт;

//**********************************************
#Область Авария

Функция ВосстановитьЧекККМ(ДокументЧекККМ, ОчищатьПараметрыЧекаККМ = Истина) Экспорт
	
	Если Продажа.Количество() <> 0 Тогда 										
		Возврат Ложь;	
	КонецЕсли;
	
	//Мулько 03.12.2019
	Если ДокументЧекККМ.Проведен Тогда
		Возврат Ложь;
	КонецЕсли;	
	
	Если НЕ ДокументЧекККМ.СостояниеЧекаККМ = Перечисления.СостояниеЧека.Новый
		//Мулько 15.10.2019
		И НЕ ДокументЧекККМ.СостояниеЧекаККМ = Перечисления.СостояниеЧека.Аварийный_ПробитТерминалНеПробитПоФР
		//Мулько 08.11.2019
		//-----------------
		И НЕ ДокументЧекККМ.СостояниеЧекаККМ = Перечисления.СостояниеЧека.Аварийный_НеПробитПоФР Тогда 
		
		//Предупреждение("Востановить чеки возможно только со статусами: <Новый> и <Аварийный_НеПробитПоФР>",2);
		Предупреждение("Востановить чеки возможно только со статусами: <Новый>, <Аварийный_ПробитТерминалНеПробитПоФР> и <Аварийный_НеПробитПоФР>",2);
		Возврат Ложь;	
	КонецЕсли; 
	
	Логирование.ДобавитьЗаписьЖурнала(,"ВосстановитьЧекККМ()", "НомерЧека: "+ДокументЧекККМ.НомерЧекаККМ+"; СТАТУС ЧЕКА: "+ДокументЧекККМ.СостояниеЧекаККМ, Неопределено, Неопределено, "Обработки.РМК.МодульОбъекта");
	
	РаботаСЧеком.ЗаполнитьПараметрыРМК(ЭтотОбъект, ДокументЧекККМ, ОчищатьПараметрыЧекаККМ);
	
КонецФункции	

Функция ОпределитьАварийныйЧекТерминал() Экспорт
	
	Если Константы.ТО_POSтерминал_ВидОбработки.Получить() = 0 Тогда
		Возврат Ложь;
	КонецЕсли;
	
	Выборка_ЧекККМ															= Документы.ЧекККМ.Выбрать(,,,"Дата убыв");
	Пока Выборка_ЧекККМ.Следующий() Цикл 
		Если Выборка_ЧекККМ.ПометкаУдаления Тогда
			Продолжить;
		ИначеЕсли Выборка_ЧекККМ.ВидОперацииЧекаККМ<>Перечисления.ВидыОперацийЧекККМ.Продажа Тогда
			Возврат Ложь;
		ИначеЕсли Выборка_ЧекККМ.СостояниеЧекаККМ=Перечисления.СостояниеЧека.Аварийный_ПробитТерминалНеПробитПоФР Тогда 
			Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Предупреждение, "ОпределитьАварийныйЧекТерминал()", "У чека №" + Выборка_ЧекККМ.НомерЧекаККМ + " состояние " + Строка(Перечисления.СостояниеЧека.Аварийный_ПробитТерминалНеПробитПоФР), Неопределено, Неопределено, "Обработки.РМК.Формы.Форма");
			Возврат Истина;
		Иначе
			Возврат Ложь;
		КонецЕсли;	
	КонецЦикла;	
	
	Возврат Ложь;
	
КонецФункции

Процедура ОпределитьСтатусАварийногоЧека() Экспорт
	
	Если глЭККР=Неопределено И НЕ Константы.ТестоваяКасса.Получить() Тогда 
		Если НЕ ЕстьАварийныйЧектерминал Тогда
			Возврат;
		КонецЕсли;	
	КонецЕсли;
	
	КоличествоЧеков = 0;
	Выборка_ЧекККМ = Документы.ЧекККМ.Выбрать(,,,"Дата убыв");
	Пока Выборка_ЧекККМ.Следующий() Цикл 
		
		Если Выборка_ЧекККМ.ПометкаУдаления Тогда
			Возврат;
		ИначеЕсли Выборка_ЧекККМ.Проведен Тогда
			Возврат;
		ИначеЕсли Выборка_ЧекККМ.Дата < НачалоДня(ТекущаяДата()) Тогда
			Возврат;
		ИначеЕсли (Выборка_ЧекККМ.СостояниеЧекаККМ = Перечисления.СостояниеЧека.Новый) И (Выборка_ЧекККМ.ВидОперацииЧекаККМ = Перечисления.ВидыОперацийЧекККМ.Продажа) Тогда 
			ВосстановитьЧекККМ(Выборка_ЧекККМ.Ссылка);
			Возврат;
		ИначеЕсли Выборка_ЧекККМ.ВидОперацииЧекаККМ <> Перечисления.ВидыОперацийЧекККМ.Продажа Тогда
			Возврат;
		КонецЕсли;
		
		КоличествоЧеков = КоличествоЧеков + 1;
		
		Прервать;
		
	КонецЦикла;	
	
	Если КоличествоЧеков = 0 Тогда 
		Возврат;
	КонецЕсли;
	
	//Если чек был пробит по терминалу и нет связи с ФР, то аннулируем чек по терминалу
	Если Выборка_ЧекККМ.СостояниеЧекаККМ = Перечисления.СостояниеЧека.Аварийный_ПробитТерминалНеПробитПоФР Тогда
		Если глЭККР = Неопределено И НЕ Константы.ТестоваяКасса.Получить() Тогда 
			Если Константы.ТО_POSтерминал_ВидОбработки.Получить() > 0 Тогда
				РаботаСЧеком.АннуллироватьЧекПоТерминалу(ЭтотОбъект, Выборка_ЧекККМ.Ссылка, ПараметрыЧекаККМ);		
				Возврат;
			Иначе
				Возврат;
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;	
	
	ВосстановитьЧекККМ(Выборка_ЧекККМ.Ссылка, Ложь);
	
	Если ПолучитьОбработкуТО().ПолучитьОборотыФР_АварийныйЧек(глЭККР, ПараметрыЧекаККМ) Тогда 
		
		ТекущиеОборотыФР = ПараметрыЧекаККМ.ФР_ОбротыПослеЧека;	
		
		ВыбокаФР_ОбротыДоЧека = Выборка_ЧекККМ.ФР_ОбротыДоЧека;
		Если ВыбокаФР_ОбротыДоЧека = Неопределено Тогда
			ВыбокаФР_ОбротыДоЧека = 0;
		КонецЕсли;	
		РазницаОборотовФР = ТекущиеОборотыФР - ВыбокаФР_ОбротыДоЧека;
		РазницаОборотовФР = ?(РазницаОборотовФР < 0, (-1) * РазницаОборотовФР, РазницаОборотовФР);
		
		Логирование.ДобавитьЗаписьЖурнала(,"ОпределитьСтатусАварийногоЧека()", "НомерЧека: "+Выборка_ЧекККМ.НомерЧекаККМ+"; СТАРЫЙ СТАТУС ЧЕКА: "+Выборка_ЧекККМ.СостояниеЧекаККМ, Неопределено, Неопределено, "Обработки.РМК.МодульОбъекта");
		Логирование.ДобавитьЗаписьЖурнала(,"ОпределитьСтатусАварийногоЧека()", "СуммаПоЧекуККМ: "+Выборка_ЧекККМ.СуммаПоЧекуККМ+"; РазницаОборотовФР: "+РазницаОборотовФР, Неопределено, Неопределено, "Обработки.РМК.МодульОбъекта");

		ОбъектЧекККМ = Выборка_ЧекККМ.ПолучитьОбъект();
		ОбъектЧекККМ.ОтправленНаСервер = Ложь;
		
		//Разница оборотов равна сумме чека - печатать на ФР не надо
		//проводим и коммитим транзакцию в BPM 
		Если РазницаОборотовФР = Выборка_ЧекККМ.СуммаПоЧекуККМ Тогда 
			ОбъектЧекККМ.СостояниеЧекаККМ 	= Перечисления.СостояниеЧека.Аварийный_ПробитПоФР;	
			ОбъектЧекККМ.ФР_ОбротыПослеЧека = ТекущиеОборотыФР;
			ОбъектЧекККМ.Записать(РежимЗаписиДокумента.Проведение);
			Если ПараметрыBPM7.BPMonline_СостояниеЧекаККМ = Перечисления.СостояниеBPMonline.Записан Тогда 
				Если НЕ BPM.BPM7_CommitPurchaseInfo() Тогда 
					Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Ошибка, "ВостановитьЧекККМ() BPM7_CommitPurchaseInfo", "Ошибка при подтверждении транзации в BPM7!", Неопределено, Неопределено, "Обработки.РМК.МодульОбработки");
				КонецЕсли;
			Иначе
				ОбъектЧекККМ.BPMonline_СостояниеЧекаККМ = Перечисления.СостояниеBPMonline.Проведен;
				ОбъектЧекККМ.Записать(РежимЗаписиДокумента.Проведение);
			КонецЕсли;
			Логирование.ДобавитьЗаписьЖурнала(, "ОпределитьСтатусАварийногоЧека()", "ЧЕК ПРОВЕДЕН И УСТАНОВЛЕН НОВЫЙ СТАТУС ЧЕКА: "+ОбъектЧекККМ.СостояниеЧекаККМ, Неопределено, Неопределено, "Обработки.РМК.Формы.Форма");
			Логирование.ДобавитьЗаписьЖурнала(, "ОпределитьСтатусАварийногоЧека().ВОССТАНОВЛЕН_БЫЛ_НАПЕЧАТАН_УСПЕШНО", 
											"ЧЕК_"+?(ПараметрыЧекаККМ.ЭтоЧекВозврата,"ВОЗВРАТА","ПРОДАЖИ")+"_№"+(глНомерПоследнегоЧека_VS+1)+"_НАПЕЧАТАН_УСПЕШНО"+
											";  Чек№: "+(глНомерПоследнегоЧека_VS+1)+
											";  СуммаЧека: "+ Формат(ПараметрыЧекаККМ.ФО_СуммаЧекаИтого, "ЧЦ=15; ЧДЦ=2; ЧГ=0")+
											";  ВидОплаты: "+ПараметрыЧекаККМ.ВидОплаты+
											";  ВидОперации: "+ПараметрыЧекаККМ.ВидОперации+
											";  "+Символы.Таб+"СостояниеЧека: "+ПараметрыЧекаККМ.СостояниеЧека+
											";  "+Символы.Таб+"BPMonline_СостояниеЧекаККМ: "+ПараметрыЧекаККМ.ДокЧекККМ.BPMonline_СостояниеЧекаККМ+
											";  "+Символы.Таб+"FISHKA_СостояниеЧекаККМ: "+	ПараметрыЧекаККМ.ДокЧекККМ.FISHKA_СостояниеЧекаККМ, Неопределено, Неопределено, "Обработки.РМК.Формы.Форма");
			ОткрытьФормуМодально("ОбщаяФорма.СообщениеЧекБылПробитНаФР");
			////ПрекратитьРаботуСистемы(Истина);
			ОчисткаРеквизитовПоЧеку();
        //Обороты до и после печати чека совпадают - печатать надо
		ИначеЕсли РазницаОборотовФР = 0 Тогда
		
		    //Если чек был пробит по терминалу и не пробит по ФР, то сформируем текст чека терминала
			Если ПараметрыЧекаККМ.СостояниеЧека = Перечисления.СостояниеЧека.Аварийный_ПробитТерминалНеПробитПоФР Тогда
				РаботаСЧеком.ПолучитьТекстПечатиТерминал(ПараметрыЧекаККМ);
			КонецЕсли;	
			
			Если РаботаСЧеком.Оплата(ЭтотОбъект) Тогда
				ОбъектЧекККМ.СостояниеЧекаККМ = Перечисления.СостояниеЧека.Аварийный_ПробитПоФР;//изменим статус до проверки оборотов по ФР
				РаботаСЧеком.ПровестиДокументЧекККМ(ЭтотОбъект);
				
				Если ПараметрыBPM7.BPMonline_СостояниеЧекаККМ = Перечисления.СостояниеBPMonline.Записан Тогда 
					//Подтвердим транзакцию в BPM
					Если НЕ BPM.BPM7_CommitPurchaseInfo() Тогда 
						Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Ошибка, "ВостановитьЧекККМ() BPM7_CommitPurchaseInfo", "Ошибка при подтверждении транзации в BPM7!", Неопределено, Неопределено, "Обработки.РМК.МодульОбработки");
					Иначе
						ПараметрыBPM7.BPMonline_СостояниеЧекаККМ = Перечисления.СостояниеBPMonline.Проведен;
						РаботаСЧеком.ПровестиДокументЧекККМ(ЭтотОбъект);	
					КонецЕсли;
				КонецЕсли;
				Логирование.ДобавитьЗаписьЖурнала(,"ОпределитьСтатусАварийногоЧека()", "ЧЕК ПРОВЕДЕН И УСТАНОВЛЕН НОВЫЙ СТАТУС ЧЕКА: "+ОбъектЧекККМ.СостояниеЧекаККМ, Неопределено, Неопределено, "Обработки.РМК.Формы.Форма");
				ОткрытьФормуМодально("ОбщаяФорма.СообщениеПробитЧекФР", , ЭтотОбъект);
				ОчисткаРеквизитовПоЧеку();
			КонецЕсли;	
		//Самый сложный случай - обороты не совпадают на сумму, не равную сумме чека
		//делаем чек аварийным и выдаем сообщение
		ИначеЕсли РазницаОборотовФР <> Выборка_ЧекККМ.СуммаПоЧекуККМ Тогда 
			ОбъектЧекККМ.СостояниеЧекаККМ 	= Перечисления.СостояниеЧека.Аварийный_НеПробитПоФР;
			ОбъектЧекККМ.ФР_ОбротыПослеЧека = ТекущиеОборотыФР;
			ОбъектЧекККМ.Записать(РежимЗаписиДокумента.Проведение);
			Логирование.ДобавитьЗаписьЖурнала(,"ОпределитьСтатусАварийногоЧека()", "ЧЕК ПРОВЕДЕН И СТАТУС ЧЕКА НЕ ИЗМЕНЕН", Неопределено, Неопределено, "Обработки.РМК.Формы.Форма");
			//ОткрытьФормуМодально("Обработка.РМК.Форма.СообщениеАварийный_НеПробитНаФР");
			ОткрытьФормуМодально("ОбщаяФорма.СообщениеАварийный_НеПробитНаФР");
		КонецЕсли;
	КонецЕсли;	
	
	//ПолучитьФорму("СообщениеАварийныйЧек1").ОткрытьМодально();

	//Форма_СписокЧековККМ = ПолучитьФорму("Форма_СписокЧековККМ");
	//Форма_СписокЧековККМ.ОтборСписокЧековККМ.Добавить(Выборка_ЧекККМ.Ссылка);
	////Мулько 03.12.2019
	////Форма_СписокЧековККМ.ЭлементыФормы.КоманднаяПанель_ТЗФ_СписокЧекиККМ.Доступность	= Ложь;
	//Форма_СписокЧековККМ.ОткрытьМодально();
	
	//Если ОбъектЧекККМ.СостояниеЧекаККМ=Перечисления.СостояниеЧека.Аварийный_НеПробитПоФР Тогда 
	//	ВостановитьЧекККМ(Выборка_ЧекККМ.Ссылка);		
	//КонецЕсли;	
	
КонецПроцедуры	

#КонецОбласти

#Область ЖурналРРО

Процедура ЖурналРРО_УвеличитьОборотыНаСуммуЧека() Экспорт
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	// 06.10.2014 Запишем обороты ФР в регистр Журнал РРО
	НаборЗаписейЖурналРРО.Прочитать();  
	ТаблицаЖурналаРРО			= НаборЗаписейЖурналРРО.Выгрузить(); 
	ТаблицаЖурналаРРО[0].Время 	= ПараметрыЧекаККМ.ДатаОперации;  	
	
	ТаблицаПродажиПоСтавкаНДС = Продажа.Выгрузить().Скопировать(Новый Структура("ВидОперации", ПараметрыЧекаККМ.ВидОперации) ,"СтавкаНДС, Количество, Сумма, СкидкаСумма, СкидкаПС, СкидкаБК");
	ТаблицаПродажиПоСтавкаНДС.Свернуть("СтавкаНДС", "Количество, Сумма, СкидкаСумма, СкидкаПС, СкидкаБК");
	
	Для Каждого СтрокаТЧ Из ТаблицаПродажиПоСтавкаНДС Цикл 
		Если НЕ РежимВозвратаЧека Тогда
			ТаблицаЖурналаРРО[0].ОборотПродаж_А				= ?(СтрокаТЧ.СтавкаНДС=Перечисления.СтавкиНДС.НДС20, 	ТаблицаЖурналаРРО[0].ОборотПродаж_А + СтрокаТЧ.Сумма - СтрокаТЧ.СкидкаБК, ТаблицаЖурналаРРО[0].ОборотПродаж_А);
			ТаблицаЖурналаРРО[0].ОборотПродаж_Б				= ?(СтрокаТЧ.СтавкаНДС=Перечисления.СтавкиНДС.БезНДС, 	ТаблицаЖурналаРРО[0].ОборотПродаж_Б + СтрокаТЧ.Сумма - СтрокаТЧ.СкидкаБК, ТаблицаЖурналаРРО[0].ОборотПродаж_Б);
			ТаблицаЖурналаРРО[0].ОборотПродаж_В				= ?(СтрокаТЧ.СтавкаНДС=Перечисления.СтавкиНДС.НДС7, 	ТаблицаЖурналаРРО[0].ОборотПродаж_В + СтрокаТЧ.Сумма - СтрокаТЧ.СкидкаБК, ТаблицаЖурналаРРО[0].ОборотПродаж_В);
		Иначе
			ТаблицаЖурналаРРО[0].ОборотВозврат_А			= ?(СтрокаТЧ.СтавкаНДС=Перечисления.СтавкиНДС.НДС20, 	ТаблицаЖурналаРРО[0].ОборотВозврат_А + СтрокаТЧ.Сумма - СтрокаТЧ.СкидкаБК, ТаблицаЖурналаРРО[0].ОборотВозврат_А);
			ТаблицаЖурналаРРО[0].ОборотВозврат_Б			= ?(СтрокаТЧ.СтавкаНДС=Перечисления.СтавкиНДС.БезНДС, 	ТаблицаЖурналаРРО[0].ОборотВозврат_Б + СтрокаТЧ.Сумма - СтрокаТЧ.СкидкаБК, ТаблицаЖурналаРРО[0].ОборотВозврат_Б);
			ТаблицаЖурналаРРО[0].ОборотВозврат_В			= ?(СтрокаТЧ.СтавкаНДС=Перечисления.СтавкиНДС.НДС7, 	ТаблицаЖурналаРРО[0].ОборотВозврат_В + СтрокаТЧ.Сумма - СтрокаТЧ.СкидкаБК, ТаблицаЖурналаРРО[0].ОборотВозврат_В);
		КонецЕсли;
	КонецЦикла;	
	
	Если ПараметрыЧекаККМ.ЭтоЧекПродажи Тогда
		ТаблицаЖурналаРРО[0].ОборотПродаж_Наличка			= ТаблицаЖурналаРРО[0].ОборотПродаж_Наличка + ПараметрыЧекаККМ.ФО_СуммаНалички;
		ТаблицаЖурналаРРО[0].ОборотПродаж_Картка			= ТаблицаЖурналаРРО[0].ОборотПродаж_Картка 	+ ПараметрыЧекаККМ.ФО_СуммаПоКарте;
		ТаблицаЖурналаРРО[0].ОборотПродаж_ПС				= ТаблицаЖурналаРРО[0].ОборотПродаж_ПС 		+ ПараметрыЧекаККМ.ФО_СуммаСертификатом;
		ТаблицаЖурналаРРО[0].ОборотПродаж_СуммаСкидки		= ТаблицаЖурналаРРО[0].ОборотПродаж_СуммаСкидки + Продажа.Итог("СкидкаСумма")+Продажа.Итог("СкидкаБК");
		ТаблицаЖурналаРРО[0].КолЧековПродаж					= ТаблицаЖурналаРРО[0].КолЧековПродаж+1;
	Иначе 	
		ТаблицаЖурналаРРО[0].ОборотВозврат_Наличка			= ТаблицаЖурналаРРО[0].ОборотВозврат_Наличка + ПараметрыЧекаККМ.ФО_СуммаНалички;
		ТаблицаЖурналаРРО[0].ОборотВозврат_Картка			= ТаблицаЖурналаРРО[0].ОборотВозврат_Картка + ПараметрыЧекаККМ.ФО_СуммаПоКарте;
		ТаблицаЖурналаРРО[0].ОборотВозврат_СуммаСкидки		= ТаблицаЖурналаРРО[0].ОборотВозврат_СуммаСкидки + Продажа.Итог("СкидкаСумма")+Продажа.Итог("СкидкаБК");
		ТаблицаЖурналаРРО[0].КолЧековВозврата				= ТаблицаЖурналаРРО[0].КолЧековВозврата+1;
	КонецЕсли;
	
	ТаблицаЖурналаРРО[0].стр								= Число(ПараметрыФР.ФР_НомерZОтчета);
    ТаблицаЖурналаРРО[0].НомерZОтчета						= Число(ПараметрыФР.ФР_НомерZОтчета);
	
	Если ПараметрыЧекаККМ.ЭтоЧекПродажи Тогда
		ТаблицаЖурналаРРО[0].ОборотПродаж               	= ТаблицаЖурналаРРО[0].ОборотПродаж + ПараметрыЧекаККМ.ФО_СуммаЧекаИтого;
	Иначе 	
		ТаблицаЖурналаРРО[0].ОборотВозврат              	= ТаблицаЖурналаРРО[0].ОборотВозврат + ПараметрыЧекаККМ.ФО_СуммаЧекаИтого;
	КонецЕсли;
	
	
	НаборЗаписейЖурналРРО.Загрузить(ТаблицаЖурналаРРО);
	НаборЗаписейЖурналРРО.Записать(Истина);
	
	Логирование.ДобавитьЗаписьЖурнала(, "ЖурналРРО_УвеличитьОборотыНаСуммуЧека()", "ДополненЖурналРРОЧеком"+?(ПараметрыЧекаККМ.ЭтоЧекПродажи,"Продажа","Возврат")+ПараметрыЧекаККМ.ВидОплаты+"№"+(глНомерПоследнегоЧека_VS+1), Неопределено, Неопределено, "Обработки.РМК.Формы.Форма");	
КонецПроцедуры	

#КонецОбласти

Процедура ОчисткаРеквизитовПоЧеку() Экспорт
	
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	// ОЧИЩАЕМ ВСЕ РЕКВИЗИТЫ ПО ЧЕКУ  /////////////////////////////////////////////////////////////////////////     
	
	Если ПараметрыЧекаККМ.СостояниеЧека=Перечисления.СостояниеЧека.Закрыт Тогда 
		Логирование.ДобавитьЗаписьЖурнала(, "ПечатьЧека().НАПЕЧАТАН_УСПЕШНО", 
											"ЧЕК_"+?(ПараметрыЧекаККМ.ЭтоЧекВозврата,"ВОЗВРАТА","ПРОДАЖИ")+"_№"+(глНомерПоследнегоЧека_VS+1)+"_НАПЕЧАТАН_УСПЕШНО"+
											";  Чек№: "+(глНомерПоследнегоЧека_VS+1)+
											";  СуммаЧека: "+ Формат(ПараметрыЧекаККМ.ФО_СуммаЧекаИтого, "ЧЦ=15; ЧДЦ=2; ЧГ=0")+
											";  ВидОплаты: "+ПараметрыЧекаККМ.ВидОплаты+
											";  ВидОперации: "+ПараметрыЧекаККМ.ВидОперации+
											";  "+Символы.Таб+"СостояниеЧека: "+ПараметрыЧекаККМ.СостояниеЧека+
											";  "+Символы.Таб+"BPMonline_СостояниеЧекаККМ: "+ПараметрыЧекаККМ.ДокЧекККМ.BPMonline_СостояниеЧекаККМ+
											";  "+Символы.Таб+"FISHKA_СостояниеЧекаККМ: "+	ПараметрыЧекаККМ.ДокЧекККМ.FISHKA_СостояниеЧекаККМ, Неопределено, Неопределено, "Обработки.РМК.Формы.Форма");
	КонецЕсли;

	//МодульTRASSIR.ТRASSIR_ЗАКРЫТЬ_ЧЕК(WS, Продажа);
	/////Дьяченко А. 120319 вывод инфо о товаре на индикатор покупателя ИП
 	ПолучитьОбработкуТО().ДисплейВерхВниз(глЭККР, " P R O S T O R ", "НАСТУПН.ПОКУПЕЦЬ");
	////Дьяченко А. 120319 вывод инфо о товаре на индикатор покупателя ИП
	
	Продажа.Очистить(); 
	Скидки.Очистить();
	ТЧ_ЖурналСкидок.Очистить();
	ТЧ_ДвиженияПС.Очистить();

	глНомерПоследнегоЧека_VS = РабочееМестоКассира.УвеличитьГлобальныйСчетчикЧеков();
	
	//Кудря 22.07.19 Единый чек
	//ОшибкаОплатыТерминала = ПараметрыЧекаККМ.ОшибкаОплатыТерминала;
	//ЧекДляВозврата = ПараметрыЧекаККМ.ДокЧекККМ;
	//Кудря
	// Дьяченко тестовая касса Фишка
	Если ПараметрыFISHKA.FISHKA_placeCode = "DEFAULT" Тогда 
		Fishka.ОтменитьПредыдущиеПопытки();
	КонецЕсли;	
	ПараметрыBPM7.BPMonline_НеудачнаяРегистрацияКлиента = Ложь;
	ПараметрыBPM7.BPMonline_КартаЗарегистрирована = Ложь;
	
	РаботаСЧеком.ПараметрыЧекаККМ_Очистить();
	BPM.ПараметрыBPM7_Очистить();
	Fishka.ИнициализироватьПараметры(Ложь);
	
	//Кудря 22.07.19 Единый чек
	//Если ОшибкаОплатыТерминала Тогда
	//	СделатьВозвратныйЧекПриОшибкеОплатыПоТерминалу(ЧекДляВозврата);
	//	НеудачнаяРегистрацияКлиента = Ложь;
	//	ЭлементыФормы.НадписьАвтономныйРежим.Значение = ""; 
	//	Обработки.РМК.ПараметрыЧекаККМ_Очистить(ПараметрыЧекаККМ);
	//	Обработки.РМК.ПараметрыBPMonline_Очистить(ПараметрыBPMonline);
	//	Обработки.РМК.ПараметрыBPM7_Очистить(ПараметрыBPM7);
	//	Fishka.ИнициализироватьПараметры(ПараметрыFISHKA, Ложь);
	//КонецЕсли;
	//Кудря

КонецПроцедуры		

Функция ПроверитьДатуЗагрузкиПараметраКассы(ПараметрКассы, РазностьДат) Экспорт
	РазностьДат = 0;
	Запрос = Новый Запрос;
	Запрос.Текст = 
			"ВЫБРАТЬ
			|	ГраницыПараметровКассыККМСрезПоследних.Граница КАК Граница
			|ИЗ
			|	РегистрСведений.ГраницыПараметровКассыККМ.СрезПоследних(, ВидПараметра = &ВидПараметра) КАК ГраницыПараметровКассыККМСрезПоследних";
			
			
	Запрос.УстановитьПараметр("ВидПараметра",ПараметрКассы);
	
	РезультатЗапроса = Запрос.Выполнить();
	
	Если РезультатЗапроса.Пустой() Тогда 
		Возврат РазностьДат;
	КонецЕсли;
	
	Выборка = РезультатЗапроса.Выбрать();
	ДатаПолученияПрайса = Дата('20190101');	
	Если Выборка.Следующий() Тогда 
		ДатаПолученияПрайса = Выборка.Граница;
	КонецЕсли;	
	ВремяСПоследнейЗагрузкиПрайса = (ТекущаяДата() - ДатаПолученияПрайса)/60;
	
	Если ВремяСПоследнейЗагрузкиПрайса < 60 Тогда 
		РазностьДат = 60 - Окр(ВремяСПоследнейЗагрузкиПрайса); // Формат(ВремяСПоследнейЗагрузкиПрайса, "ЧДЦ=; ЧН=");
	КонецЕсли;	
	Возврат	РазностьДат;
КонецФункции

//************************ ОБЩИЕ ПРОЦЕДУРЫ **************************************************************************************************

// Дьяченко перенос акций в BPM
Процедура ПересчитатьЦеныДляАкцийПростор() Экспорт 
	
	Если РежимВозвратаЧека Тогда
		Возврат;
	КонецЕсли;
	ТЧ_ЖурналСкидок.Очистить();																		
	Скидки.Очистить();
	
	ТЗ_Буффер = ТЧ_ДвиженияПС.Выгрузить().Скопировать(Новый Структура("СтатусПС", "Продан"));
	ТЧ_ДвиженияПС.Загрузить(ТЗ_Буффер);

	Для Каждого СтрокаТЧ Из Продажа Цикл
		СтрокаТЧ.СкидкаБК		= 0;
		СтрокаТЧ.НомерАкции  	= 0;
		СтрокаТЧ.СкидкаСумма 	= 0;
		СтруктураОтбора = Новый Структура;
		СтруктураОтбора.Вставить("CODE", СтрокаТЧ.Код);
		СтруктураОтбора.Вставить("BAR", СтрокаТЧ.Штрихкод);
		ТаблицаДанных = РегистрыСведений.Прайс.СрезПоследних(ТекущаяДата(), СтруктураОтбора);

		СтрокаТЧ.Цена = ТаблицаДанных[0].PRICE; 
        СтрокаТЧ.Сумма 		 	= СтрокаТЧ.Количество*СтрокаТЧ.Цена;
		СтрокаТЧ.СуммаБезСкидки = СтрокаТЧ.Количество*СтрокаТЧ.Цена;
		СтрокаТЧ.СуммаНДС 		= 0;
		
		СтрокаТЧ.ШК_ДКО = "";
		СтрокаТЧ.ШК_ДКД = "";
	КонецЦикла; 
	
КонецПроцедуры	

Функция ПодготовитьОбработкуРМККЗапуску() Экспорт
	
	осн_КассаККМ 	= Константы.осн_КассаККМ.Получить();
	ШК_Ануляции 	= Константы.ШК_Ануляции.Получить();
	ШК_Возврата 	= Константы.ШК_Возврата.Получить();
	СрокХранения 	= Константы.СрокХраненияЖурналовПродаж.Получить();
	Если СрокХранения = 0 Тогда
		Константы.СрокХраненияЖурналовПродаж.Установить(31);
		СрокХранения = 31;
	КонецЕсли;
	
	Если ПустаяСтрока(ШК_Ануляции) Тогда
		Предупреждение("ЭЛЕКТРОННЫЙ КЛЮЧ АННУЛЯЦИИ НЕ ЗАРЕГИСТРИРОВАН В СИСТЕМЕ!
					   |ЗАРЕГИСТРИРУЙТЕ ЭЛЕКТРОННЫЙ КЛЮЧ (С ПРАВАМИ АДМИНИСТРАТОРА ККМ)
					   |ИЛИ ОБРАТИТЕСЬ К ВАШЕМУ АДМИНИСТРАТОРУ СИСТЕМЫ ЗА ПОМОЩЬЮ",,"КРИТИЧЕСКАЯ ОШИБКА!!!");
		Возврат Ложь;
	КонецЕсли;
		
	Если ПустаяСтрока(ШК_Возврата) Тогда
		Предупреждение("ЭЛЕКТРОННЫЙ КЛЮЧ ВОЗВРАТОВ НЕ ЗАРЕГИСТРИРОВАН В СИСТЕМЕ!
					   |ЗАРЕГИСТРИРУЙТЕ ЭЛЕКТРОННЫЙ КЛЮЧ (С ПРАВАМИ АДМИНИСТРАТОРА ККМ)
					   |ИЛИ ОБРАТИТЕСЬ К ВАШЕМУ АДМИНИСТРАТОРУ СИСТЕМЫ ЗА ПОМОЩЬЮ",,"КРИТИЧЕСКАЯ ОШИБКА!!!");
		Возврат Ложь;
	КонецЕсли;
	
	Если ШК_Ануляции = ШК_Возврата Тогда
		Предупреждение("СОВПАДАЮТ ЭЛЕКТРОННЫЕ КЛЮЧИ АННУЛЯЦИИ И ВОЗВРАТОВ ЗАРЕГИСТРИРОВАННЫЕ В СИСТЕМЕ!
					   |ЗАРЕГИСТРИРУЙТЕ РАЗЛИЧНЫЕ КЛЮЧИ (С ПРАВАМИ АДМИНИСТРАТОРА ККМ)
					   |ИЛИ ОБРАТИТЕСЬ К ВАШЕМУ АДМИНИСТРАТОРУ СИСТЕМЫ ЗА ПОМОЩЬЮ
					   |
					   |ВНИМАНИЕ! РАБОТА С ОДИНАКОВЫМИ ЗНАЧЕНИЯМИ КЛЮЧЕЙ *ПРИНЦИПИАЛЬНО* НЕВОЗМОЖНА!",,"КРИТИЧЕСКАЯ ОШИБКА!!!");
		Возврат Ложь;
	КонецЕсли;
	
	Если осн_КассаККМ.Пустая() ИЛИ ПустаяСтрока(осн_КассаККМ.НомерМагазина) ИЛИ осн_КассаККМ.Код = "00001" Тогда
		Предупреждение("ФИСКАЛЬНЫЙ РЕГИСТРАТОР (КАССА ККМ) НЕ ЗАРЕГИСТРИРОВАН В СИСТЕМЕ!
					   |ЗАРЕГИСТРИРУЙТЕ ФИСКАЛЬНЫЙ РЕГИСТРАТОР (С ПРАВАМИ АДМИНИСТРАТОРА ККМ)
					   |ИЛИ ОБРАТИТЕСЬ К ВАШЕМУ АДМИНИСТРАТОРУ СИСТЕМЫ ЗА ПОМОЩЬЮ
					   |
					   |ВНИМАНИЕ! РАБОТА С НЕОПРЕДЕЛЕННЫМ ФИСКАЛЬНЫМ РЕГИСТРАТОРОМ *ПРИНЦИПИАЛЬНО* НЕВОЗМОЖНА!",,"КРИТИЧЕСКАЯ ОШИБКА!!!");
		Возврат Ложь;
	КонецЕсли;
	
	НаборЗаписейЖурналРРО = РегистрыСведений.ЖурналРРО.СоздатьНаборЗаписей();
	НаборЗаписейЖурналРРО.Прочитать();  
	ТаблицаЖурналаРРО	=	НаборЗаписейЖурналРРО.Выгрузить(); 
	
	Если ТаблицаЖурналаРРО.Количество()=0 Тогда 
		Если Вопрос("Внимание! Не сделан 0 чек! Продолжить работу?",режимдиалогавопрос.ДаНет)=КодВозвратаДиалога.Нет Тогда Возврат Ложь; КонецЕсли;
	КонецЕсли;
	
	Возврат Истина;

КонецФункции

//Мулько К.П.
Процедура ЗакрытьЧекПослеАннуляции(РезультатАвторизации) Экспорт

	ТЧ_ДвиженияПС.Очистить();
	ТЧ_ЖурналСкидок.Очистить();
	
	ПараметрыЧекаККМ.СостояниеЧека = Перечисления.СостояниеЧека.Закрыт;
	РаботаСЧеком.ПараметрыЧекаККМ_ВидОперацииУстановить(РезультатАвторизации.ВидАнуляции);
	РаботаСЧеком.ПараметрыЧекаККМ_СгенерироватьУникальныйНомерЧекаККМ();
	РаботаСЧеком.Отредактировать_Записать_ДокументЧекККМ(ПараметрыЧекаККМ, ПараметрыBPM7, ПараметрыFISHKA, ЭтотОбъект);
	РаботаСЧеком.ПровестиДокументЧекККМ(ЭтотОбъект);
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	      
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	МассивНефискальногоТекста = Новый Массив;
	МассивНефискальногоТекста.Добавить("!!! АНУЛЯЦІЯ !!!");
	МассивНефискальногоТекста.Добавить(" ");
    МассивНефискальногоТекста.Добавить("Відповідальный:");
	МассивНефискальногоТекста.Добавить("   " + РезультатАвторизации.пПользователь);
	МассивНефискальногоТекста.Добавить("Чек "+?(РежимВозвратаЧека, "повернення", "продажу"));
	МассивНефискальногоТекста.Добавить("№ " + СокрЛП(глНомерПоследнегоЧека_VS+1));
	МассивНефискальногоТекста.Добавить("----------------------");
	
	ТЗ_Продажа = Продажа.Выгрузить().Скопировать();
	ТЗ_Продажа.Свернуть("DATASTR2, Цена", "Количество");
	Для Каждого Строка Из ТЗ_Продажа Цикл
    	ДлинаСуммы = СтрДлина(СокрЛП(Строка.Цена));
		МассивНефискальногоТекста.Добавить(" Кол-во:"+Строка.Количество+" Цена:"+ СокрЛП(Строка.Цена));
		МассивНефискальногоТекста.Добавить(Лев(Строка.DATASTR2,23-ДлинаСуммы));
	КонецЦикла; 
    МассивНефискальногоТекста.Добавить("----------------------");
	
	Попытка	
   		ПолучитьОбработкуТО().ОткрытьЗакрытьНефискальныйЧек(глЭККР, Истина);
		ПолучитьОбработкуТО().НапечататьСтроки(глЭККР, МассивНефискальногоТекста, 34);
		ПолучитьОбработкуТО().ОткрытьЗакрытьНефискальныйЧек(глЭККР, Ложь);
	Исключение
		Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Ошибка, "КнопкаАннуляцияЧекаНажатие()", "Ошибка при печати чека аннуляции !!! "+Строка(ОписаниеОшибки()), Неопределено, Неопределено, "Обработки.РМК.Формы.Форма");
		ПолучитьОбработкуТО().АннулироватьЧек(глЭККР);
	КонецПопытки;	

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	//МодульTRASSIR.ТRASSIR_АННУЛЯЦИЯ_ВСЕГО_ЧЕКА(WS);

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	Логирование.ДобавитьЗаписьЖурнала(, "КнопкаАннуляцияЧекаНажатие().ТоварАннулирован", "АННУЛЯЦИЯ ВСЕГО ЧЕКА ЗАВЕРШЕНА !!!", Неопределено, Продажа, "Обработки.РМК.Формы.Форма");
	
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

	глНомерПоследнегоЧека_VS = РабочееМестоКассира.УвеличитьГлобальныйСчетчикЧеков();
	
	РаботаСЧеком.ПараметрыЧекаККМ_Очистить();
	Fishka.ИнициализироватьПараметры(Ложь);
	BPM.ПараметрыBPM7_Очистить();
	
	Продажа.Очистить();
	ОстаткиСитемыЛоялности.Очистить();
	ТЧ_ДвиженияПС.Очистить();
	
	//ОчиститьДанныеПоБК();
	
КонецПроцедуры

//Мулько 15.11.2019
Процедура АннулироватьСтрокуПоШтрихкоду(ШК, РезультатФункцииАннуляцияСтроки) Экспорт
	
	Если РезультатФункцииАннуляцияСтроки = Неопределено Тогда
		РезультатФункцииАннуляцияСтроки = ВывестиОкноАвторизацииОтветсвенного(Ложь);
	КонецЕсли;	
	
	СтруктураОтбора = Новый Структура;		
	СтруктураОтбора.Вставить("Ануляция", Ложь);
	Если РаботаСПС.ЭтоПодарочныйСертификат(ШК) Тогда
		СтруктураОтбора.Вставить("Код", ШК);
	Иначе	
		СтруктураОтбора.Вставить("Штрихкод", ШК);
	КонецЕсли;	
	
	МассивСтрок = Продажа.НайтиСтроки(СтруктураОтбора);
	Если МассивСтрок.Количество() > 0 Тогда
		
		СтрокаТЧ = МассивСтрок[0];
		СтрокаТЧ.Ануляция 				= Истина;
		СтрокаТЧ.Ответственный 			= РезультатФункцииАннуляцияСтроки.пПользователь;
		СтрокаТЧ.ВидОперации			= РезультатФункцииАннуляцияСтроки.ВидАнуляции;
		СтрокаТЧ.КоличествоДоАннуляции 	= СтрокаТЧ.Количество;
		СтрокаТЧ.Количество				= 0;
		СтрокаТЧ.СкидкаСумма			= 0;
		СтрокаТЧ.СкидкаБК				= 0;
		СтрокаТЧ.Сумма					= 0;
		СтрокаТЧ.СуммаБезСкидки			= 0;
		СтрокаТЧ.Кассир					= глТекущийПользователь;
		
		Если РаботаСПС.ЭтоПодарочныйСертификат(СтрокаТЧ.Код) Тогда
			НайденаяСтрока= ТЧ_ДвиженияПС.Найти(СтрокаТЧ.Штрихкод, "ШК_ПС");
			Если НайденаяСтрока<>Неопределено Тогда 
				ТЧ_ДвиженияПС.Удалить(НайденаяСтрока);
			КонецЕсли;	
		КонецЕсли;	
	
		Логирование.ДобавитьЗаписьЖурнала(, "АннулироватьСтрокуПоШтрихкоду()", "АННУЛЯЦИЯ СТРОКИ ЧЕКА ЗАВЕРШЕНА !!!", СтрокаТЧ, Неопределено, "Обработки.РМК.Формы.Форма");
	
		//МодульTRASSIR.ТRASSIR_АННУЛЯЦИЯ_СТРОКИ_ЧЕКА(WS, СтрокаТЧ);
		
		//если аннулировали весь чек, то выполним закрытие чека
		Если РаботаСЧеком.ПроверкаАннулированВесьЧек(ЭтотОбъект) Тогда
			Логирование.ДобавитьЗаписьЖурнала(, "АннулироватьСтрокуПоШтрихкоду()", "АННУЛИРОВАН ВЕСЬ ЧЕК !!!", СтрокаТЧ, Неопределено, "Обработки.РМК.Формы.Форма");
			Для Каждого СтрокаТЧ Из Продажа Цикл
				СтрокаТЧ.Количество	= СтрокаТЧ.КоличествоДоАннуляции;
			КонецЦикла;	
				
			ЗакрытьЧекПослеАннуляции(РезультатФункцииАннуляцияСтроки);
		КонецЕсли;	
		
		Возврат;
		
	Иначе
		Логирование.ДобавитьЗаписьЖурнала(,"АннулироватьСтрокуПоШтрихкоду()","отсутствует в чеке или уже был отсканирован"
							 + ";  ШК: " + ШК, Неопределено, Неопределено, "Обработки.РМК.Формы.ФормаВозврат");	
		Предупреждение("Товар со штрикодом " + ШК + " отсутствует в чеке или уже был отсканирован !!!", 5 ,"ВНИМАНИЕ !!!");
	КонецЕсли;
	
КонецПроцедуры	

Функция ВывестиОкноАвторизацииОтветсвенного(ВызванаАнуляцияВсегоЧека) Экспорт
	
	//	
	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
				  |	УсловияПоАкции.ТипАкции,
				  |	УсловияПоАкции.НомерАкции
				  |ИЗ
				  |	РегистрСведений.УсловияПоАкции КАК УсловияПоАкции
				  |ГДЕ
				  |	УсловияПоАкции.ДатаНачала МЕЖДУ &НачПериода И &КонПериода";
	Запрос.УстановитьПараметр("НачПериода", НачалоДня(ТекущаяДата()));
	Запрос.УстановитьПараметр("КонПериода", КонецДня(ТекущаяДата()));
	РезльтатЗапроса = Запрос.Выполнить().Выбрать();
	ДоступнаКнопка_АнуляцияТестАкции = Ложь;
	Если ВызванаАнуляцияВсегоЧека Тогда 
		ДоступнаКнопка_АнуляцияТестАкции = РезльтатЗапроса.Следующий();
	КонецЕсли;	
	
	//Если у текущего пользователя установленна роль Управлящий, то никакой авторизации ненужно
	Если РольДоступна("УправляющийМагазином") И НЕ ДоступнаКнопка_АнуляцияТестАкции ИЛИ РольДоступна("Программист") Тогда 
		Логирование.ДобавитьЗаписьЖурнала(, "ВывестиОкноАвторизацииОтветсвенного()", "АВТОРИЗАЦИЯ ПОЛЬЗОВАТЕЛЯ ПРОШЛА УСПЕШНО !!! Ответственный: "+глТекущийПользователь, Неопределено, Неопределено,  "Обработки.РМК.Формы.Форма");
   		Возврат (Новый Структура("АвторизацияПройдена, пПользователь, ВидАнуляции", Истина, глТекущийПользователь, Перечисления.ВидыОперацийЧекККМ.Аннуляция));
	КонецЕсли;
		
	ФормаОткрыть = ПолучитьОбщуюФорму("АвторизацияПользователя");
	ФормаОткрыть.ВыводПользователей_Управляющие 	= Истина;
	ФормаОткрыть.ДоступнаКнопка_АнуляцияТестАкции 	= ДоступнаКнопка_АнуляцияТестАкции;
	Если РольДоступна("УправляющийМагазином") И ДоступнаКнопка_АнуляцияТестАкции Тогда 
		ФормаОткрыть.Пользователь = глТекущийПользователь;
		ФормаОткрыть.Пароль = "любойпароль";
		ФормаОткрыть.ЭлементыФормы.Пользователь.Доступность = Ложь;
		ФормаОткрыть.ЭлементыФормы.Пароль.Доступность 		= Ложь;
	КонецЕсли;	
	ФормаОткрыть.ОткрытьМодально();
	Если (НЕ ФормаОткрыть.РезультатАвторизации) Тогда 
		
		//МодульTRASSIR.ТRASSIR_POSNG_COMMENT(WS, "ОТМЕНА! Доп.АВТОРИЗАЦИЯ НЕ ПРОЙДЕНА !!!");
		
		Предупреждение("Авторизация ответственного НЕ ПРОЙДЕНА !!! Отмена действия !!!",2);
		Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Предупреждение, "ВывестиОкноАвторизацииОтветсвенного()", "Авторизация ответственного НЕ ПРОЙДЕНА !!! Отмена действия !!!", Неопределено, Неопределено,  "Обработки.РМК.Формы.Форма");
        Возврат (Новый Структура("АвторизацияПройдена, пПользователь, ВидАнуляции", Ложь, "", Перечисления.ВидыОперацийЧекККМ.Аннуляция));	
	КонецЕсли;	
	
	Логирование.ДобавитьЗаписьЖурнала(,"ВывестиОкноАвторизацииОтветсвенного()", "АВТОРИЗАЦИЯ ПОЛЬЗОВАТЕЛЯ ПРОШЛА УСПЕШНО !!! Ответственный: "+ФормаОткрыть.Пользователь, Неопределено, Неопределено,  "Обработки.РМК.Формы.Форма");
	
	ВидАнуляции = ?(ФормаОткрыть.РежимТестовойАнуляции, Перечисления.ВидыОперацийЧекККМ.Аннуляция_ТестАкций, Перечисления.ВидыОперацийЧекККМ.Аннуляция);
    Возврат (Новый Структура("АвторизацияПройдена, пПользователь, ВидАнуляции", Истина, ФормаОткрыть.Пользователь, ВидАнуляции));
		
КонецФункции	