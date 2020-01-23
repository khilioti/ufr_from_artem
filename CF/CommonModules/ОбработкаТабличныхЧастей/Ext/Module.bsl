﻿Процедура РассчитатьСуммуТабЧасти(СтрокаТабличнойЧасти, ДокументОбъект) Экспорт

	Сумма = СтрокаТабличнойЧасти.Цена * СтрокаТабличнойЧасти.Количество;
	
	СтрокаТабличнойЧасти.Сумма = Сумма - СтрокаТабличнойЧасти.СкидкаСумма;
	
	ПересчитатьСуммуДокумента(ДокументОбъект);

КонецПроцедуры // РассчитатьСуммуТабЧасти()

Процедура ПриИзмененииСуммыТабЧасти(СтрокаТабличнойЧасти, ДокументОбъект) Экспорт

	Если Не ЗначениеЗаполнено(СтрокаТабличнойЧасти.Количество) Тогда
		СтрокаТабличнойЧасти.Цена = 0;
	Иначе
		Если (СтрокаТабличнойЧасти.Цена = 0) Или (СтрокаТабличнойЧасти.Количество = 0) Тогда
			Если СтрокаТабличнойЧасти.Цена = 0 Тогда
				ОбщегоНазначения.СообщитьОбОшибке("Цена равна 0, после изменения суммы установлена нулевая скидка!");
			Иначе
				ОбщегоНазначения.СообщитьОбОшибке("Количество равно 0, после изменения суммы установлена нулевая скидка!");
			КонецЕсли;
		Иначе
			СуммаСоСкидками = СтрокаТабличнойЧасти.Сумма;
			СуммаБезСкидок  = СтрокаТабличнойЧасти.Цена * СтрокаТабличнойЧасти.Количество;
				
			СтрокаТабличнойЧасти.СкидкаСумма = СуммаБезСкидок - СуммаСоСкидками;
		КонецЕсли;
	КонецЕсли;
	
	ПересчитатьСуммуДокумента(ДокументОбъект);
	
КонецПроцедуры // ПриИзмененииСуммыТабЧасти()

Процедура СкидкаБЧПриИзменении(СтрокаТабличнойЧасти, ДокументОбъект) Экспорт
	
	Если СтрокаТабличнойЧасти.СкидкаБК >= СтрокаТабличнойЧасти.Сумма Тогда
		ОбщегоНазначения.СообщитьОбОшибке("Скидка по БК превышает сумму по строке!");
	КонецЕсли;	
	
	ПересчитатьСуммуДокумента(ДокументОбъект);

КонецПроцедуры //   СкидкаБЧПриИзменении

Процедура ПересчитатьСуммуДокумента(ДокументОбъект) Экспорт
	
	СуммаДок = 0;
	
	Для Каждого СтрокаТЧ ИЗ ДокументОбъект.ТЧ_Товары Цикл
		СуммаДок = СуммаДок + СтрокаТЧ.Сумма - СтрокаТЧ.СкидкаБК; 
	КонецЦикла;
	
	ДокументОбъект.СуммаПоЧекуККМ = СуммаДок - ДокументОбъект.СуммаОплаты_ПС - ДокументОбъект.СуммаОплаты_Ваучер; 
	
	Если ДокументОбъект.СуммаОплаты_БезНал = 0 Тогда
		ДокументОбъект.СуммаОплаты_Нал = ДокументОбъект.СуммаПоЧекуККМ;
	Иначе	
		ДокументОбъект.СуммаОплаты_БезНал = ДокументОбъект.СуммаПоЧекуККМ;
	КонецЕсли;	
	
КонецПроцедуры // 	ПересчитатьСуммуДокумента()

Процедура ОчиститьСкидкуВТЧ_Товары(СтрокаТабличнойЧасти, ДокументОбъект) Экспорт
	
	СтруктураОтбор = Новый Структура;
	СтруктураОтбор.Вставить("НомСтрокиЧекаККМ", СтрокаТабличнойЧасти.НомерСтроки);
	МассивНайденныйСтрок = ДокументОбъект.ТЧ_ЖурналСкидок.НайтиСтроки(СтруктураОтбор);
	
	Если МассивНайденныйСтрок <> Неопределено Тогда
		Для Каждого СтрокаМассива Из МассивНайденныйСтрок Цикл
			ДокументОбъект.ТЧ_ЖурналСкидок.Удалить(СтрокаМассива);
		КонецЦикла;
	КонецЕсли;	

КонецПроцедуры // 	ОчиститьСкидкуВТЧ_Товары

Процедура ПриИзмененииКодаТабЧасти(СтрокаТабличнойЧасти, ДокументОбъект) Экспорт
	
	СтруктураОтбора = Новый Структура;
	Если ЗначениеЗаполнено(СтрокаТабличнойЧасти.Код) Тогда
		СтруктураОтбора.Вставить("CODE", ОбщегоНазначения.ДополнитьКодНулями(СтрокаТабличнойЧасти.Код));
	КонецЕсли;	
	Если ЗначениеЗаполнено(СтрокаТабличнойЧасти.ШК) Тогда
		СтруктураОтбора.Вставить("BAR", СтрокаТабличнойЧасти.ШК);
	КонецЕсли;	
	Если СтруктураОтбора.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ТаблицаДанных = РегистрыСведений.Прайс.СрезПоследних(ТекущаяДата(), СтруктураОтбора);
	
	Если ТаблицаДанных.Количество() = 0 Тогда
		ОбщегоНазначения.СообщитьОбОшибке("ОШИБКА: По выбранному ШК товар не найден в прайсе !!!");
		Возврат;
	ИначеЕсли ТаблицаДанных.Количество() >= 1 Тогда 
		СтрокаДанных = ТаблицаДанных[0];
		Если BPM.РаботаетАкционнаяСистемаБПМ() Тогда 
			Если СтрокаДанных.FULLPRICE = 0 Тогда 
				ОбщегоНазначения.СообщитьОбОшибке("Выбранному товару НЕ УСТАНОВЛЕНА РОЗНИЧНАЯ ЦЕНА !!! Продажа товара НЕ ВОЗМОЖНА !!!");
				Возврат;
			КонецЕсли;
			СтрокаТабличнойЧасти.Цена = Окр(СтрокаДанных.FULLPRICE, 2);
		Иначе 	
			Если СтрокаДанных.PRICE = 0 Тогда 
				ОбщегоНазначения.СообщитьОбОшибке("Выбранному товару НЕ УСТАНОВЛЕНА РОЗНИЧНАЯ ЦЕНА !!! Продажа товара НЕ ВОЗМОЖНА !!!");
				Возврат;
			КонецЕсли;
			СтрокаТабличнойЧасти.Цена = Окр(СтрокаДанных.PRICE, 2);
		КонецЕсли;
	КонецЕсли;	
	
	Если НЕ ЗначениеЗаполнено(СтрокаТабличнойЧасти.Код) Тогда
		СтрокаТабличнойЧасти.Код = СтрокаДанных.CODE;
	КонецЕсли;
	
	Если НЕ ЗначениеЗаполнено(СтрокаТабличнойЧасти.ШК) Тогда
		СтрокаТабличнойЧасти.ШК = СтрокаДанных.BAR;
	КонецЕсли;
	
	СтрокаТабличнойЧасти.Количество		= 1;
	СтрокаТабличнойЧасти.Акционный 		= СтрокаДанных.CODE_PREF;
	СтрокаТабличнойЧасти.Наименование 	= СтрокаДанных.NAME;
	//СтрокаТабличнойЧасти.Ответственный 	= глТекПользовательИБ;
	РаботаСЧеком.ЗаполнитьСтавкуНДСВСтроке(СтрокаТабличнойЧасти, СтрокаДанных);
	СтрокаТабличнойЧасти.ВидОперации 	= ДокументОбъект.ВидОперацииЧекаККМ;
	
	РассчитатьСуммуТабЧасти(СтрокаТабличнойЧасти, ДокументОбъект);
	ПересчитатьСуммуДокумента(ДокументОбъект);
		
КонецПроцедуры	