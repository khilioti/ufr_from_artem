﻿Процедура ПроверитьПодарочныйСертификат(ШК, ШтрихКод_ПС, ФормаРМК, Отказ) Экспорт
	
	Рез_ПолучитьСтатусПС = ПолучитьСтатусПС(ШК);
	//Мулько 05.03.2020
	АкцииДоступны = Ложь;
	Если ФормаРМК = Неопределено Тогда
		АкцииДоступны = Истина;
	Иначе
		АкцииДоступны = ФормаРМК.ЭлементыФормы.Акции.Доступность;
	КонецЕсли;	
	Если Рез_ПолучитьСтатусПС.НайденПС И АкцииДоступны И СокрЛП(Рез_ПолучитьСтатусПС.СтатусПС)="Активирован" Тогда
		
		Запрос = Новый Запрос;
		Запрос.Текст = "ВЫБРАТЬ
						|	Прайс.CODE,
						|	Прайс.BAR
						|ИЗ
						|	РегистрСведений.Прайс КАК Прайс
						|ГДЕ
						|	Прайс.PRICE = &PRICE
						|	И Прайс.CODE_PREF = 9";
		Запрос.УстановитьПараметр("PRICE", Рез_ПолучитьСтатусПС.НоминалПС);	
		РезультатЗапроса = Запрос.Выполнить().Выбрать();
		Если РезультатЗапроса.Следующий() Тогда 
			ШтрихКод_ПС = ШК;
			ШК 			= СокрЛП(РезультатЗапроса.BAR);
		КонецЕсли;	
		
	// Ошибка при сканировании ПС
	ИначеЕсли Рез_ПолучитьСтатусПС.НайденПС Тогда 
		
		Если ФормаРМК <> Неопределено Тогда //Мулько 05.03.2020
			РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "ШК: "+ШК);
			РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "ТекущийСтатусПС: "+Рез_ПолучитьСтатусПС.СтатусПС);
			Если СокрЛП(Рез_ПолучитьСтатусПС.СтатусПС) 		= "Продан" Тогда 
				РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "*** Откройте ОКНО ОПЛАТЫ чека ***");
				РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "Данный ПС можно только ОТОВАРИТЬ !!!");
			ИначеЕсли СокрЛП(Рез_ПолучитьСтатусПС.СтатусПС) = "Активирован" Тогда 
				РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "Данный ПС можно только ПРОДАТЬ !!!");
			ИначеЕсли СокрЛП(Рез_ПолучитьСтатусПС.СтатусПС) = "Отоварен" Тогда	
				РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "Данный ПС уже был ОТОВАРЕН ранее !!!");
			ИначеЕсли СокрЛП(Рез_ПолучитьСтатусПС.СтатусПС) = "Деактивирован" Тогда 
				РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "Данный ПС ДЕАКТИВИРОВАН !!!");
				РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "Продажа и Отоваривание этого ПС ЗАБЛОКИРОВАНА!!!");
			Иначе 
				РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "ОШИБКА!!! Не установлен статус для этого ПС !!!");
				РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "Сообщите об этой ошибке в офис !!!");
			КонецЕсли;	
			
			РабочееМестоКассира.ВывестиТекстНаДоскуСообщений(ФормаРМК, "-");
		КонецЕсли;	
		Отказ = Истина;
	КонецЕсли;
	
КонецПроцедуры	

Функция ПолучитьСтатусПС(ШК_ПС) Экспорт 
	
	СостояниеПС_СрезПоследних = РегистрыСведений.СостояниеПС.СрезПоследних(ТекущаяДата(), Новый Структура("ШК_ПС", ШК_ПС)); 
	ДвиженияПС_СрезПоследних  = РегистрыСведений.ДвиженияПС.СрезПоследних(ТекущаяДата(), Новый Структура("ШК_ПС", ШК_ПС));
	
	Результат = Новый Структура;
	Результат.Вставить("НайденПС", 	Ложь);
	Результат.Вставить("Период", 	Дата(1,1,1));
	Результат.Вставить("СтатусПС", 	"");
	Результат.Вставить("НоминалПС", 0);
		
	Если СостояниеПС_СрезПоследних.Количество() = 1 И ДвиженияПС_СрезПоследних.Количество() = 1 Тогда		
		Если  СостояниеПС_СрезПоследних[0].Период>ДвиженияПС_СрезПоследних[0].Период Тогда 
			Результат.НайденПС 	= Истина;
			Результат.СтатусПС 	= СокрЛП(СостояниеПС_СрезПоследних[0].СтатусПС);
			Результат.НоминалПС = СостояниеПС_СрезПоследних[0].НоминалПС;
			Результат.Период 	= СостояниеПС_СрезПоследних[0].Период;
		Иначе 
			Результат.НайденПС  = Истина;
			Результат.СтатусПС	= СокрЛП(ДвиженияПС_СрезПоследних[0].СтатусПС);
			Результат.НоминалПС	= ДвиженияПС_СрезПоследних[0].НоминалПС;
			Результат.Период	= ДвиженияПС_СрезПоследних[0].Период;
		КонецЕсли;	
	ИначеЕсли СостояниеПС_СрезПоследних.Количество() = 1 Тогда 
		Результат.НайденПС	= Истина;
		Результат.СтатусПС	= СокрЛП(СостояниеПС_СрезПоследних[0].СтатусПС);
		Результат.НоминалПС	= СостояниеПС_СрезПоследних[0].НоминалПС;
		Результат.Период	= СостояниеПС_СрезПоследних[0].Период;
	ИначеЕсли ДвиженияПС_СрезПоследних.Количество() = 1 Тогда 
		Результат.НайденПС	= Истина;
		Результат.СтатусПС	= СокрЛП(ДвиженияПС_СрезПоследних[0].СтатусПС);
		Результат.НоминалПС	= ДвиженияПС_СрезПоследних[0].НоминалПС;
		Результат.Период	= ДвиженияПС_СрезПоследних[0].Период;
	КонецЕсли;	
	
	ДвиженияПС_ВебСервис = ВебСервисыЧековаяСтатистика.РОЗНИЦА_ПолучитьТекущийСтатусПС(ШК_ПС);
	Если НЕ ПустаяСтрока(ДвиженияПС_ВебСервис.СтатусПС) Тогда 
		Если ДвиженияПС_ВебСервис.Период>Результат.Период Тогда 
			Результат.НайденПС 	= Истина;
			Результат.СтатусПС 	= СокрЛП(ДвиженияПС_ВебСервис.СтатусПС);
			Результат.НоминалПС = ДвиженияПС_ВебСервис.НоминалПС;
			Результат.Период	= ДвиженияПС_ВебСервис.Период;
		КонецЕсли;	
	КонецЕсли;	
	
	Возврат Результат;
	
КонецФункции
	
