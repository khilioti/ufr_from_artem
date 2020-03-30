﻿
Процедура ОбработкаПроведения(Отказ, Режим)
	
	// регистр ДвижениеПС
	Движения.ДвиженияПС.Записывать = Истина;
	Движения.Скарбничка.Записывать = Истина;
	
	Движения.Скарбничка.Очистить();
	Движения.ДвиженияПС.Очистить(); 
	
	Если СостояниеЧекаККМ=Перечисления.СостояниеЧека.Аварийный_ПробитПоФР ИЛИ СостояниеЧекаККМ=Перечисления.СостояниеЧека.Закрыт Тогда 
		                                                            
		Для Каждого ТекСтрокаТЧ_ДвиженияПС Из ТЧ_ДвиженияПС Цикл
			Движение = Движения.ДвиженияПС.Добавить();
			Движение.Период			= Дата;
			Движение.ШК_ПС			= ТекСтрокаТЧ_ДвиженияПС.ШК_ПС;
			Движение.НоминалПС		= ТекСтрокаТЧ_ДвиженияПС.НоминалПС;
			Движение.СтатусПС		= ТекСтрокаТЧ_ДвиженияПС.СтатусПС;
			Движение.Подразделение	= Подразделение;
			Движение.КассаККМ		= КассаККМ;
			Движение.НомерЧекаККМ	= НомерЧекаККМ;
			Движение.ЭлектронныйПС	= ТекСтрокаТЧ_ДвиженияПС.ЭлектронныйПС;
			Движение.ИнфоКарта_ШК 	= ТекСтрокаТЧ_ДвиженияПС.ИнфоКарта_ШК;
		КонецЦикла;
		
		Если BPMonline_Скарбничка>0 И НЕ ПустаяСтрока(BPMonline_ШК) Тогда 
		  	Движение = Движения.Скарбничка.Добавить();
			Движение.Период					= Дата;
			Движение.НомерЧекаНаBPM			= СокрЛП(КассаККМ)+"_"+СокрЛП(НомерЧекаККМ);
			Движение.ШК_БК					= BPMonline_ШК;
			Движение.СдачаНаБК				= BPMonline_Скарбничка;
			Движение.ОтправленНаBPMonline 	= BPMonline_СкарбничкаОтправленна;
	    КонецЕсли;
		
	КонецЕсли;
	
КонецПроцедуры

Процедура ПриУстановкеНовогоНомера(СтандартнаяОбработка, Префикс)
	НомерЧекаККМ_ТекущейСмены = РаботаСЧеком.ПолучитьНомерЧекаТекущейСмены(Ссылка, НомерZОтчета, ВидОперацииЧекаККМ);
КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)
	
	ТаблицаЗначенийТЧ = ТЧ_Товары.Выгрузить();
	ТаблицаЗначенийТЧ.Колонки.Добавить("Дубли");
    ТаблицаЗначенийТЧ.ЗаполнитьЗначения(1, "Дубли");
    ТаблицаЗначенийТЧ.Свернуть("Код, ШК","Дубли");
	Если ТаблицаЗначенийТЧ.Количество() < ТЧ_Товары.Количество() Тогда // дубли есть
		Для Каждого СтрокаТаблицаЗначенийТЧ Из ТаблицаЗначенийТЧ Цикл
			Если НЕ ОбщегоНазначения.ЭтоПодарочныйСертификат(СтрокаТаблицаЗначенийТЧ.Код) Тогда
				СтрокаТаблицаЗначенийТЧ.Дубли = 0;
			КонецЕсли;
		КонецЦикла;	
		Для Каждого СтрокаТаблицаЗначенийТЧ Из ТаблицаЗначенийТЧ Цикл
			Если СтрокаТаблицаЗначенийТЧ.Дубли > 1 Тогда
				Сообщить("Обнаружены повторяющиеся сертификаты! Штрихкод сертификата: " + СтрокаТаблицаЗначенийТЧ.ШК);
				Отказ = Истина;
			КонецЕсли;	
		КонецЦикла;	
	КонецЕсли;	
	
	//РабочееМестоКассира.УвеличитьГлобальныйСчетчикЧеков(Истина);
	
КонецПроцедуры

//Мулько 25.03.2020
Процедура ПриКопировании(ОбъектКопирования)
	
	Если ЭтоНовый() Тогда
		ОтправленНаСервер = Ложь;
		UUID_ЧекаККМ_ИзРозница = "";
		ВидОперацииЧекаККМ = ОбъектКопирования.ВидОперацииЧекаККМ;
		Подразделение = ОбъектКопирования.Подразделение;
		КассаККМ = ОбъектКопирования.КассаККМ;
		ФискальныйНомер_строка = Формат(Число(Константы.осн_КассаККМ.Получить().ФискальныйНомер), "ЧЦ=10; ЧВН=; ЧГ=0");
		НомерZОтчета	= Формат( Константы.осн_КассаККМ.Получить().НомерZОтчета, "ЧЦ=4; ЧВН=; ЧГ=0");
		НомерЧекаККМ = Константы.глСчетчикЧеков.Получить() + 1;
		НомерЧека = РаботаСЧеком.ПолучитьНомерЧекаТекущейСмены(Ссылка, НомерZОтчета, ВидОперацииЧекаККМ);
		НомерЧекаККМ_ТекущейСмены = Формат(НомерЧека, "ЧЦ=4; ЧВН=; ЧГ=0");
		
		Если ВидОперацииЧекаККМ = Перечисления.ВидыОперацийЧекККМ.Продажа Тогда 
			КодОперации	= 1;																	
		ИначеЕсли ВидОперацииЧекаККМ = Перечисления.ВидыОперацийЧекККМ.Возврат Тогда 
			КодОперации = 2;
	    КонецЕсли;

		УникальныйНомерЧекаККМ = ФискальныйНомер_строка + НомерZОтчета + КодОперации + НомерЧекаККМ_ТекущейСмены + "0";											
		
		глНомерПоследнегоЧека_VS = Константы.глСчетчикЧеков.Получить() + 1;
	КонецЕсли;	

КонецПроцедуры
