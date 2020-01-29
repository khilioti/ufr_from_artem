﻿
// новая процедура обновления 
Процедура ВыполнитьОбновление() Экспорт
	Результат = ВебСервисыЧековаяСтатистика.РОЗНИЦА_ПолучитьОбновленияДляКонфигурацииУФР();
	
	Если НЕ Результат.УстановкаОбновлений Тогда
		Возврат;	
	КонецЕсли;
	
	МассивНомеровТекущейВерсии	= СтрРазделить(Метаданные.Версия,"."); 
	МассивНомеровНовойВерсии	= СтрРазделить(Результат.НомерНовойВерсии,"."); 	
	
	Если НеобходимостьОткатаВерсии(МассивНомеровТекущейВерсии, МассивНомеровНовойВерсии) Тогда
		ФайлБэкапа = КаталогИБ() + "backup$" + "\" + Результат.НомерНовойВерсии + ".cf";
		Если ФайлБэкапаСуществует(ФайлБэкапа) Тогда
			ЗагрузитьПредыдущуюВерсиюКонфигурации(ФайлБэкапа);
			Возврат;
		Иначе	
		     Предупреждение("Отсутствует файл обнолений!
							|Невозможно выполнить обновление до предыдущей версии!
			 				|Обратитесь к техническому специалисту!", 10, "ОШИБКА! Обратитесь к техническому специалисту!");
		КонецЕсли; 
	КонецЕсли; 
	
	Если Результат.ПодтверждениеКассира Тогда 	
		Режим = РежимДиалогаВопрос.ДаНет;
		Ответ = Вопрос("Доступны обновления для конфигурации 1С:УФР(" + Результат.НомерНовойВерсии + ")!!! Скачать обновления и установить ??? ",Режим,0,,"Доступны обновления для БД 1С:УФР !!! Текущая версия " + "v<" + Метаданные.Версия + ">");
		Если Ответ = КодВозвратаДиалога.Нет Тогда
			Возврат;	
		КонецЕсли;
	КонецЕсли;
	
	КаталогаБэкапа = КаталогИБ() + "backup$"; // НомерВерсииКонфы;
	ПодготовитьКаталогВыгрузкиБэкапов(КаталогаБэкапа);

	Попытка                                                                        
		шелл = Новый COMОбъект("WScript.Shell");
		Сообщить("Идет установка обновлений ...");
		// выгружаем CF для возможности отката
		шелл.Run(ПроверитьПараметрНаПробелы(КаталогПрограммы()+"1CV8.EXE")+ " CONFIG /F " + ПроверитьПараметрНаПробелы(КаталогИБ()) 
		+ " /N Программист /P developer13 /DumpCfg  " + КаталогаБэкапа + "\" + Метаданные.Версия + ".cf",1,1);
		
		шелл.Run(ПроверитьПараметрНаПробелы(КаталогПрограммы()+"1CV8.EXE")+ " CONFIG /F " + ПроверитьПараметрНаПробелы(КаталогИБ()) 
		+ " /N Программист /P developer13 /UpdateCfg " + ПроверитьПараметрНаПробелы(КаталогВременныхФайлов() + Результат.ИмяФайлаОбновлений),1,1);
		
		Если КонфигурацияИзменена() тогда
			//Константы.ПризнакНачалаУстановкиОбновлений.Установить(Истина);
			//Константы.НомерВерсииКонфигурации.Установить(МассивВерсий_Upd[ИндексСкаченогоОбнов].Версия);
			ОбновлениеКонфигурацииБД();
		Иначе 
			Предупреждение("ОШИБКА: Основная конфигурация не обновлена. Установка обновлений прервана !!! Сообщите системному администратору !")
		КонецЕсли;	
	Исключение
		Предупреждение("ОШИБКА: Основная конфигурация не обновлена. Установка обновлений прервана !!! Сообщите системному администратору !");
	КонецПопытки;
	
КонецПроцедуры	

Процедура ОбновлениеКонфигурацииБД() Экспорт 
				
		Сообщить("Идет установка обновлений конфигурации БД ...");
		
																						
		ТекстовыйФайл 															= Новый ТекстовыйДокумент;
		ТекстовыйФайл.ДобавитьСтроку("dim WshShell, WshExec_1, WshExec_2, my_status");
		ТекстовыйФайл.ДобавитьСтроку("my_status = true");

        ТекстовыйФайл.ДобавитьСтроку("Set WshShell = CreateObject(" + Символ(34) + "WScript.Shell" + Символ(34) +")");
		ТекстовыйФайл.ДобавитьСтроку("WshShell.Run " + ПроверитьПараметрНаПробелы(ПроверитьПараметрНаПробелы(КаталогВременныхФайлов()+"taskkill.exe",2)+" /f /IM 1CV8.EXE")+",0,1");
		ТекстовыйФайл.ДобавитьСтроку("Set WshExec_1 = WshShell.Exec (" + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() + "1CV8.EXE" + Символ(34) + Символ(34) +" CONFIG /F " + ПроверитьПараметрНаПробелы(КаталогИБ(),2) + " /N Программист /P developer13 /UpdateDBCfg "+ Символ(34)+")");
		ТекстовыйФайл.ДобавитьСтроку("Do");
        ТекстовыйФайл.ДобавитьСтроку("if WshExec_1.Status = 0 then");
		ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!!! НЕ ЗАПУСКАЙТЕ 1С НА КАССАХ !!!")+" & vbCrLf & vbCrLf & "+ПроверитьПараметрНаПробелы(" Идет установка обновлений   . . .")+",10," + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!! Идет установка обновлений...")+",0+48");
        ТекстовыйФайл.ДобавитьСтроку("else");
        ТекстовыйФайл.ДобавитьСтроку("exit do");
        ТекстовыйФайл.ДобавитьСтроку("end if");
        ТекстовыйФайл.ДобавитьСтроку("Loop While (my_status = true)");
		
        ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("Установка обновлений завершена !!!")+",10,"+ПроверитьПараметрНаПробелы("Установка обновлений завершена !!!")+",0+64");
		ТекстовыйФайл.ДобавитьСтроку("WshShell.Run " + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() + "1CV8.EXE" + Символ(34) + Символ(34) +" ENTERPRISE /F " + ПроверитьПараметрНаПробелы(КаталогИБ(),2) + Символ(34)+ ",1,1");
		ТекстовыйФайл.ДобавитьСтроку("WScript.Quit");
		ТекстовыйФайл.Записать(КаталогВременныхФайлов()+"ProStor_update.vbs",КодировкаТекста.ANSI);
		
		ПутьКФайлу																= КаталогВременныхФайлов()+"ProStor_update.vbe";
		
		Кодировщик																= ПолучитьОбщийМакет("ScriptEncoder");
		Кодировщик.Записать(КаталогВременныхФайлов()+"screnc.exe");
		
		Кодировщик																= ПолучитьОбщийМакет("Taskkill_shablon");
		Кодировщик.Записать(КаталогВременныхФайлов()+"taskkill.exe");

		Шелл																	= Новый COMОбъект("WScript.Shell");
		Шелл.Run(ПроверитьПараметрНаПробелы(КаталогВременныхФайлов()+"screnc.exe")+" "+ПроверитьПараметрНаПробелы(Лев(ПутьКФайлу,СтрДлина(ПутьКФайлу)-1)+"s")+" "+ПроверитьПараметрНаПробелы(ПутьКФайлу),0,1);
		
		//УдалитьФайлы(Лев(ПутьКФайлу,СтрДлина(ПутьКФайлу)-1)+"s");
		//УдалитьФайлы(КаталогВременныхФайлов()+"screnc.exe");

		Попытка
			// Включаем автономную работу всех касс 
			Константы.ПризнакАвтономнойРаботыУФР.Установить(Истина);
		Исключение
		КонецПопытки;	

		Попытка
			//Пока ПолучитьСоединенияИнформационнойБазы().Количество()>1 Цикл   
			Пока ПолучитьСеансыИнформационнойБазы().Количество()>1 Цикл 
				Предупреждение("ЗАКРОЙТЕ 1С НА СОСЕДНИХ КАССАХ !!! 
							|
							|ВАЖНО: Чтоб ПРОДОЛЖИТЬ установку обновлений необходим МОНОПОЛЬНЫЙ ДОСТУП к этой БД.
							|
							|Закройте все активные сеансы!!!
							|Количество активных сеансов(пользователей БД): " + ПолучитьСеансыИнформационнойБазы().Количество(),5,"ВНИМАНИЕ НЕ ЗАПУСКАЙТЕ 1С !!!");
			КонецЦикла;
						
			Константы.ПризнакАвтономнойРаботыУФР.Установить(Ложь);			
			ЗапуститьПриложение(Символ(34) + ПутьКФайлу + Символ(34));
			ПрекратитьРаботуСистемы();
		Исключение
			Предупреждение("ОШИБКА: Не удалось запустить обновления через внешний скрипт-файл !!!");
		КонецПопытки;	
		
КонецПроцедуры	

Функция КаталогИБ()
	СтрокаСоединенияСБД = СтрокаСоединенияИнформационнойБазы();
	// в зависимости от того файловый это вариант БД или нет,  по-разному отображается путь в БД 
	ПозицияПоиска = Найти(Врег(СтрокаСоединенияСБД), "FILE=");
	Если ПозицияПоиска = 1 тогда
		// Файловая	
		Возврат Сред(СтрокаСоединенияСБД,7,СтрДлина(СтрокаСоединенияСБД)-8)+"\";
	КонецЕсли; 
		 
	Возврат Константы.Путь.Получить();
	
КонецФункции  

Функция ПроверитьПараметрНаПробелы(Знач Параметр, КоличествоКавычек = 1)
	Если КоличествоКавычек = 2 тогда
		Возврат ?(Найти(Параметр," ")<>0,""""+""""+ Параметр+""""+"""",Параметр);	
	Иначе
		Возврат ?(Найти(Параметр," ")<>0,""""+Параметр+"""",Параметр);	
	КонецЕсли;	
	
КонецФункции

#Область ОткатОбновлений

Процедура ЗагрузитьПредыдущуюВерсиюКонфигурации(ФайлБэкапа)
	
	//НомерВерсииКонфы = Метаданные.Версия;
	//КаталогаБэкапа = КаталогИБ() + НомерВерсииКонфы;
	//СоздатьКаталог(КаталогаБэкапа);
	//КаталогВыгрузки = КаталогаБэкапа + "\" + НомерВерсииКонфы +".cf";
	//КаталогВыгрузки = "E:\CASH\serverkkm1\cashserv\2.0.0.485\2.0.0.485.cf";	
	
	ТекстовыйФайл = Новый ТекстовыйДокумент;
	ТекстовыйФайл.ДобавитьСтроку("dim WshShell, WshExec_1, WshExec_2, WshExec_LoadCfg, WshExec_UpdateDBCfg, my_status");
	ТекстовыйФайл.ДобавитьСтроку("my_status = true");
	// убиваем процессы 1CV8.EXE
	ТекстовыйФайл.ДобавитьСтроку("Set WshShell = CreateObject(" + Символ(34) + "WScript.Shell" + Символ(34) +")");
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Run " + ПроверитьПараметрНаПробелы(ПроверитьПараметрНаПробелы(КаталогВременныхФайлов()+"taskkill.exe",2)+" /f /IM 1CV8.EXE")+",0,1");
	
	// снимаем с поддержки
	ТекстовыйФайл.ДобавитьСтроку("Set WshExec_2 = WshShell.Exec (" + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() 
		+ "1CV8.EXE" + Символ(34) + Символ(34) +" CONFIG /F " + ПроверитьПараметрНаПробелы(КаталогИБ(),2) 
		+ " /N Программист /P developer13 /ManageCfgSupport -disableSupport -force " + Символ(34)+")");
	ТекстовыйФайл.ДобавитьСтроку("Do");
	ТекстовыйФайл.ДобавитьСтроку("if WshExec_2.Status = 0 then");
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!!! НЕ ЗАПУСКАЙТЕ 1С!")+" & vbCrLf & vbCrLf & "
		+ ПроверитьПараметрНаПробелы(" Снимаем с поддержки конфигурацию! Ничего не нажимать!") + ",10," 
		+ ПроверитьПараметрНаПробелы("ВНИМАНИЕ! Идет подготовка к обновлению...") + ",0+48");
	ТекстовыйФайл.ДобавитьСтроку("else");
	ТекстовыйФайл.ДобавитьСтроку("exit do");
	ТекстовыйФайл.ДобавитьСтроку("end if");
	ТекстовыйФайл.ДобавитьСтроку("Loop While (my_status = true)");
	
	// накатываем обновление
	ТекстовыйФайл.ДобавитьСтроку("Set WshExec_LoadCfg = WshShell.Exec (" + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() 
		+ "1CV8.EXE" + Символ(34) + Символ(34) +" CONFIG /F " + ПроверитьПараметрНаПробелы(КаталогИБ(),2) 
		+ " /N Программист /P developer13 /LoadCfg " + ПроверитьПараметрНаПробелы(ФайлБэкапа) + Символ(34)+")");
	ТекстовыйФайл.ДобавитьСтроку("Do");
	ТекстовыйФайл.ДобавитьСтроку("if WshExec_LoadCfg.Status = 0 then");
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!!! НЕ ЗАПУСКАЙТЕ 1С!")+" & vbCrLf & vbCrLf & "
		+ ПроверитьПараметрНаПробелы(" Снимаем с поддержки конфигурацию! Ничего не нажимать!") + ",10," 
		+ ПроверитьПараметрНаПробелы("ВНИМАНИЕ! Идет подготовка к обновлению...") + ",0+48");
	ТекстовыйФайл.ДобавитьСтроку("else");
	ТекстовыйФайл.ДобавитьСтроку("exit do");
	ТекстовыйФайл.ДобавитьСтроку("end if");
	ТекстовыйФайл.ДобавитьСтроку("Loop While (my_status = true)");

	// выполняем обновление
	ТекстовыйФайл.ДобавитьСтроку("Set WshExec_UpdateDBCfg = WshShell.Exec (" + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() 
		+ "1CV8.EXE" + Символ(34) + Символ(34) +" CONFIG /F " + ПроверитьПараметрНаПробелы(КаталогИБ(),2) 
		+ " /N Программист /P developer13 /UpdateDBCfg " + Символ(34)+")");
	ТекстовыйФайл.ДобавитьСтроку("Do");
	ТекстовыйФайл.ДобавитьСтроку("if WshExec_UpdateDBCfg.Status = 0 then");
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!!! НЕ ЗАПУСКАЙТЕ 1С!")+" & vbCrLf & vbCrLf & "
		+ ПроверитьПараметрНаПробелы(" Обновляем конфигурацию! Ничего не нажимать!") + ",10," 
		+ ПроверитьПараметрНаПробелы("ВНИМАНИЕ! Обновляем конфигурацию...") + ",0+48");
	ТекстовыйФайл.ДобавитьСтроку("else");
	ТекстовыйФайл.ДобавитьСтроку("exit do");
	ТекстовыйФайл.ДобавитьСтроку("end if");
	ТекстовыйФайл.ДобавитьСтроку("Loop While (my_status = true)");
	
	// завершение процедуры отката, запускаем 1С
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("Откат базы завершен!")+",10,"
	+ПроверитьПараметрНаПробелы("Откат базы завершен!")+",0+64");
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Run " + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() + "1CV8.EXE" 
			+ Символ(34) + Символ(34) +" ENTERPRISE /F " + ПроверитьПараметрНаПробелы(КаталогИБ(),2) + Символ(34)+ ",1,1");
	ТекстовыйФайл.ДобавитьСтроку("WScript.Quit");
	ТекстовыйФайл.Записать(КаталогВременныхФайлов()+"ProStor_backUP.vbs",КодировкаТекста.ANSI);
	
	ПутьКФайлу = КаталогВременныхФайлов() + "ProStor_backUP.vbe";
	
	Кодировщик = ПолучитьОбщийМакет("ScriptEncoder");
	Кодировщик.Записать(КаталогВременныхФайлов()+"screnc.exe");
	
	Кодировщик = ПолучитьОбщийМакет("Taskkill_shablon");
	Кодировщик.Записать(КаталогВременныхФайлов()+"taskkill.exe");
	
	Шелл = Новый COMОбъект("WScript.Shell");
	Шелл.Run(ПроверитьПараметрНаПробелы(КаталогВременныхФайлов()+"screnc.exe")+" "+ПроверитьПараметрНаПробелы(Лев(ПутьКФайлу,СтрДлина(ПутьКФайлу)-1)+"s")
			+" "+ПроверитьПараметрНаПробелы(ПутьКФайлу),0,1);
	
	
	ЗапуститьПриложение(Символ(34) + ПутьКФайлу + Символ(34));		
	
КонецПроцедуры

Функция НеобходимостьОткатаВерсии(МассивНомеровТекущейВерсии, МассивНомеровНовойВерсии) 
	
	Результат = Ложь;
	Для Сч = 0 По МассивНомеровТекущейВерсии.ВГраница() Цикл
		Если МассивНомеровТекущейВерсии[Сч] > МассивНомеровНовойВерсии[Сч] Тогда
			Результат = Истина;
			Возврат Результат;		
		КонецЕсли; 
	КонецЦикла; 	
	Возврат Результат;
	
КонецФункции	

Функция ФайлБэкапаСуществует(ИмяФайлаБэкапа)
	
	рез = Ложь;
	ФайлБэкапа = Новый Файл(ИмяФайлаБэкапа);
	Если ФайлБэкапа.Существует() Тогда
		рез = Истина;
	КонецЕсли; 
	Возврат рез;
	
КонецФункции

Процедура ПодготовитьКаталогВыгрузкиБэкапов(КаталогаБэкапа)
	ПапкаБэкапов = Новый Файл(КаталогаБэкапа);
	Если  ПапкаБэкапов.Существует() Тогда
		НайденныеФайлы = НайтиФайлы(КаталогаБэкапа,"*.*");
		Попытка
			
			УдалитьФайлы(КаталогаБэкапа,"*.*");
			Сообщить("Удалено :" + НайденныеФайлы.Количество() + " файлов");
			
		Исключение
			Сообщить("Ошибка удаления файлов!" + ОписаниеОшибки());
		КонецПопытки;
		
	Иначе 
		СоздатьКаталог(КаталогаБэкапа);
	КонецЕсли;
	
КонецПроцедуры	

#КонецОбласти


#Область ДополнительныеВозможности

// дополнительные возможности
Процедура ПровестиТестированиеИИсправлениеБД() Экспорт 
	
	ТекстовыйФайл 															= Новый ТекстовыйДокумент;
	ТекстовыйФайл.ДобавитьСтроку("Set WshShell = CreateObject(" + Символ(34) + "WScript.Shell" + Символ(34) +")");
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Run " + ПроверитьПараметрНаПробелы(ПроверитьПараметрНаПробелы(КаталогВременныхФайлов()+"taskkill.exe",2)+" /f /IM 1CV8.EXE")+",0,1");
	
	ТекстовыйФайл.ДобавитьСтроку("Set WshExec_1 = WshShell.Exec (" + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() + "1CV8.EXE" + Символ(34) + Символ(34) +" CONFIG /F " + КаталогИБ() + " /N Программист /P developer13 /DumpIB "+КаталогИБ()+Формат(ТекущаяДата(),"ДФ=yyyyMMddhhmmss")+"_copyDB.dt"+Символ(34)+")");
	ТекстовыйФайл.ДобавитьСтроку("Do");
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!!! НЕ ЗАПУСКАЙТЕ 1С !!!")+" & vbCrLf & vbCrLf & "+ПроверитьПараметрНаПробелы(" Идет архивация БД  . . .")+",5," + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!! Идет архивация БД ...")+",0+48");
   	ТекстовыйФайл.ДобавитьСтроку("Loop While (WshExec_1.Status = 0)");
	
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Run " + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() + "1CV8.EXE" + Символ(34) + Символ(34) +" CONFIG /F " + КаталогИБ() + " /N Программист /P developer13 /Out """"C:\log.txt"""" -NoTruncate /IBCheckAndRepair -ReIndex -LogAndRefsIntegrity -RecalcTotals -IBCompression -Rebuild -BadRefClear -BadDataDelete /Visible /DisableStartupMessages"+Символ(34)+",1,1");
	
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("Тестирование и исправления БД завершено !!!")+",60,"+ПроверитьПараметрНаПробелы("Тестирование и исправления БД завершено !!!")+",0+64");
		
	
	ТекстовыйФайл.ДобавитьСтроку("WScript.Quit");
	ТекстовыйФайл.Записать(КаталогВременныхФайлов()+"ProStor_TestDB.vbs",КодировкаТекста.ANSI);
		
		
	ПутьКФайлу																= КаталогВременныхФайлов()+"ProStor_TestDB.vbe";
	
	Кодировщик																= ПолучитьОбщийМакет("ScriptEncoder");
	Кодировщик.Записать(КаталогВременныхФайлов()+"screnc.exe");
	
	Кодировщик																= ПолучитьОбщийМакет("Taskkill_shablon");
	Кодировщик.Записать(КаталогВременныхФайлов()+"taskkill.exe");
    	
	Шелл																	= Новый COMОбъект("WScript.Shell");
	Шелл.Run(ПроверитьПараметрНаПробелы(КаталогВременныхФайлов()+"screnc.exe")+" "+ПроверитьПараметрНаПробелы(Лев(ПутьКФайлу,СтрДлина(ПутьКФайлу)-1)+"s")+" "+ПроверитьПараметрНаПробелы(ПутьКФайлу),0,1);

	УдалитьФайлы(Лев(ПутьКФайлу,СтрДлина(ПутьКФайлу)-1)+"s");
	УдалитьФайлы(КаталогВременныхФайлов()+"screnc.exe");

	КопироватьФайл(ПутьКФайлу, "c:\cashserv\ProStor_TestDB.vbe");

	Попытка
		Пока ПолучитьСеансыИнформационнойБазы().Количество()>1 Цикл   
			ОбработкаПрерыванияПользователя();
			Константы.ПризнакАвтономнойРаботыУФР.Установить(Истина);
			
			Предупреждение("ЗАКРОЙТЕ 1С НА СОСЕДНИХ КАССАХ !!! 
						|
						|ВАЖНО: Чтоб ПРОДОЛЖИТЬ работу в 1С необходим МОНОПОЛЬНЫЙ ДОСТУП к этой БД.
						|
						|Закройте все активные подключения!!!
						|Количество активных подключений(пользователей): " + ПолучитьСеансыИнформационнойБазы().Количество(),5,"ВНИМАНИЕ НЕ ЗАПУСКАЙТЕ 1С !!!");
		КонецЦикла;
        		
		ЗапуститьПриложение(Символ(34) + ПутьКФайлу + Символ(34));
		ПрекратитьРаботуСистемы();
	Исключение
		Предупреждение("ОШИБКА: Не удалось запустить внешний скрипт-файл !!!");
	КонецПопытки;	
КонецПроцедуры

Процедура ПровестиАрхивациюБД_И_ЖурналаРегистрацииБД() Экспорт 
	
	ТекстовыйФайл 															= Новый ТекстовыйДокумент;
	ТекстовыйФайл.ДобавитьСтроку("Set WshShell = CreateObject(" + Символ(34) + "WScript.Shell" + Символ(34) +")");
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Run " + ПроверитьПараметрНаПробелы(ПроверитьПараметрНаПробелы(КаталогВременныхФайлов()+"taskkill.exe",2)+" /f /IM 1CV8.EXE")+",0,1");
	
	ТекстовыйФайл.ДобавитьСтроку("Set WshExec_1 = WshShell.Exec (" + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() + "1CV8.EXE" + Символ(34) + Символ(34) +" CONFIG /F " + КаталогИБ() + " /N Программист /P developer13 /DumpIB "+КаталогИБ()+Формат(ТекущаяДата(),"ДФ=yyyyMMddhhmmss")+"_copyDB.dt"+Символ(34)+")");
	ТекстовыйФайл.ДобавитьСтроку("Do");
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!!! НЕ ЗАПУСКАЙТЕ 1С !!!")+" & vbCrLf & vbCrLf & "+ПроверитьПараметрНаПробелы(" Идет архивация БД  . . .")+",5," + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!! Идет архивация БД ...")+",0+48");
   	ТекстовыйФайл.ДобавитьСтроку("Loop While (WshExec_1.Status = 0)");
	
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Run " + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() + "1CV8.EXE" + Символ(34) + Символ(34) +" CONFIG /F " + КаталогИБ() + " /N Программист /P developer13 /Out """"C:\log.txt"""" -NoTruncate /IBCheckAndRepair -ReIndex -LogAndRefsIntegrity -RecalcTotals -IBCompression -Rebuild -BadRefClear -BadDataDelete /Visible /DisableStartupMessages"+Символ(34)+",1,1");
	
	ТекстовыйФайл.ДобавитьСтроку("Set WshExec_2 = WshShell.Exec (" + Символ(34)+Символ(34)+Символ(34)+ КаталогПрограммы() + "1CV8.EXE" + Символ(34) + Символ(34) +" CONFIG /F " + КаталогИБ() + " /N Программист /P developer13 /ReduceEventLogSize "+Формат(КонецДня(ТекущаяДата()),"ДФ=yyyy-MM-dd")+" -saveAs "+КаталогИБ()+"LogFile\Delete_LOG_"+Формат(ТекущаяДата(),"ДФ=yyyyMMddhhmmss")+".elf"+Символ(34)+")");
	ТекстовыйФайл.ДобавитьСтроку("Do");
	ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!!! НЕ ЗАПУСКАЙТЕ 1С !!!")+" & vbCrLf & vbCrLf & "+ПроверитьПараметрНаПробелы(" Идет архивация журнала регистрации событий в БД  . . .")+",5," + ПроверитьПараметрНаПробелы("ВНИМАНИЕ !!! Идет архивация журнала регистрации событий в БД ...")+",0+48");
   	ТекстовыйФайл.ДобавитьСтроку("Loop While (WshExec_2.Status = 0)");

	ТекстовыйФайл.ДобавитьСтроку("WshShell.Popup " + ПроверитьПараметрНаПробелы("Архивация БД завершена !!!")+",60,"+ПроверитьПараметрНаПробелы("Архивация БД завершена !!!")+",0+64");
		
	
	ТекстовыйФайл.ДобавитьСтроку("WScript.Quit");
	ТекстовыйФайл.Записать(КаталогВременныхФайлов()+"ProStor_TestDB.vbs",КодировкаТекста.ANSI);
		
		
	ПутьКФайлу																= КаталогВременныхФайлов()+"ProStor_TestDB.vbe";
	
	Кодировщик																= ПолучитьОбщийМакет("ScriptEncoder");
	Кодировщик.Записать(КаталогВременныхФайлов()+"screnc.exe");
	
	Кодировщик																= ПолучитьОбщийМакет("Taskkill_shablon");
	Кодировщик.Записать(КаталогВременныхФайлов()+"taskkill.exe");
    	
	Шелл																	= Новый COMОбъект("WScript.Shell");
	Шелл.Run(ПроверитьПараметрНаПробелы(КаталогВременныхФайлов()+"screnc.exe")+" "+ПроверитьПараметрНаПробелы(Лев(ПутьКФайлу,СтрДлина(ПутьКФайлу)-1)+"s")+" "+ПроверитьПараметрНаПробелы(ПутьКФайлу),0,1);

	//УдалитьФайлы(Лев(ПутьКФайлу,СтрДлина(ПутьКФайлу)-1)+"s");
	//УдалитьФайлы(КаталогВременныхФайлов()+"screnc.exe");

	КопироватьФайл(ПутьКФайлу, "c:\cashserv\ProStor_TestDB.vbe");

	Попытка
		Пока ПолучитьСеансыИнформационнойБазы().Количество()>1 Цикл   
			ОбработкаПрерыванияПользователя();
			Константы.ПризнакАвтономнойРаботыУФР.Установить(Истина);
			
			Предупреждение("ЗАКРОЙТЕ 1С НА СОСЕДНИХ КАССАХ !!! 
						|
						|ВАЖНО: Чтоб ПРОДОЛЖИТЬ работу в 1С необходим МОНОПОЛЬНЫЙ ДОСТУП к этой БД.
						|
						|Закройте все активные подключения!!!
						|Количество активных подключений(пользователей): " + ПолучитьСеансыИнформационнойБазы().Количество(),5,"ВНИМАНИЕ НЕ ЗАПУСКАЙТЕ 1С !!!");
		КонецЦикла;
        		
		ЗапуститьПриложение(Символ(34) + ПутьКФайлу + Символ(34));
		ПрекратитьРаботуСистемы();
	Исключение
		Предупреждение("ОШИБКА: Не удалось запустить внешний скрипт-файл !!!");
	КонецПопытки;	
КонецПроцедуры

#КонецОбласти

#Область СтарыеПроцедурыОбновлений
// старая процедура
Процедура УстановкаОбновлений () Экспорт 
	
	СерверHTTP				= Метаданные.АдресКаталогаОбновлений;
	АдрHTTP_version			= СерверHTTP + "/version.xml";
	АдрЛокальный_version 	= КаталогВременныхФайлов() + "version.xml";
	//АдрHTTP_version			= СерверHTTP + "/123.xml";
	//АдрЛокальный_version 	= КаталогВременныхФайлов() + "123.xml";
   	ТекущаяВерсияКонф		= Метаданные.Версия;
	
	НомерМагазина			= Константы.осн_КассаККМ.Получить().НомерМагазина;
	
	МассивВерсий_Upd		= Новый Массив;
	СтрокаДоступныеВерсии	= "";
	
	Попытка
		ВходящийФайл 		= Новый Файл(АдрЛокальный_version);
		Логирование.ДобавитьЗаписьЖурнала(, "УстановкаОбновлений()", "Был ли создан файл "+АдрЛокальный_version+" в предыдущем запуске 1С => "+ВходящийФайл.Существует() , Неопределено, Неопределено, "ОбщиеМодули.ОбновлениеБД");
		
		Если ВходящийФайл.Существует() Тогда
			Сообщить("Копируем файл обновлений ...  "+АдрЛокальный_version+" из "+АдрHTTP_version);
			Сообщить("Если 1С ЗАВИСЛА болеее чем на 10 минут, то НЕОБХОДИМО СНЯТЬ ЗАДАЧУ 1С через диспечере задач(Cntr+Alt+Del)");
			Сообщить("При следующем запуске 1С копирование файла VERSION.xml ВЫПОЛНЯТЬСЯ НЕ БУДЕТ !!!");
			
			УдалитьФайлы(АдрЛокальный_version);
			КопироватьФайл(АдрHTTP_version, АдрЛокальный_version);
			
			Логирование.ДобавитьЗаписьЖурнала(, "УстановкаОбновлений()", "ФАЙЛ скопирован !!! "+АдрЛокальный_version, Неопределено, Неопределено, "ОбщиеМодули.ОбновлениеБД");
			ОчиститьСообщения(); 
		Иначе
			ТекстовыйФайл 		= Новый ТекстовыйДокумент;
			ТекстовыйФайл.Записать(АдрЛокальный_version, КодировкаТекста.ANSI);
			
			Логирование.ДобавитьЗаписьЖурнала(, "УстановкаОбновлений()", "ФАЙЛ создан вручню(пустышка) !!! "+АдрЛокальный_version, Неопределено, Неопределено, "ОбщиеМодули.ОбновлениеБД");
			
			Предупреждение("ВНИМАНИЕ!!! Касса работает в АВАРИЙНОМ РЕЖИМЕ !!!"+ Символы.ПС + Символы.ПС
			+"1С не скачала установочный файл "+АдрЛокальный_version+ " !!!"+ Символы.ПС+ Символы.ПС
			+"Сообщите системному администратору. Установка обновлений ЗАБЛОКИРОВАННА...",,"ВНИМАНИЕ!!! Касса работает в АВАРИЙНОМ РЕЖИМЕ !!!");
		КонецЕсли;	
		//Сообщить("Файл скопирован !!! => version.xml");
	Исключение
		Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Ошибка, "УстановкаОбновлений()", "ОШИБКА при копировании файла "+АдрЛокальный_version+" из "+АдрHTTP_version, Неопределено, Неопределено, "ОбщиеМодули.ОбновлениеБД");
		
		//УдалитьФайлы(АдрЛокальный_version);
		//Сообщить("ОШИБКА КОПИРОВАНИЯ (version.xml): " +ОписаниеОшибки());
	КонецПопытки;
	
	Если ВходящийФайл.Существует() тогда
		ТекстовыйФайл 		= Новый ТекстовыйДокумент;
		ТекстовыйФайл.Прочитать(АдрЛокальный_version);
		Текст = ТекстовыйФайл.ПолучитьТекст();
		
		Если Текст <> ""  Тогда
			Для й = 1 По СтрЧислоСтрок(Текст) Цикл 
				СтрокаTXT 	= СтрПолучитьСтроку(Текст, й);	 
				
				Если Найти(СтрокаTXT,"'")<>0 Тогда  	
					Продолжить;	
				КонецЕсли;	
                				                				
				Если Найти(СтрокаTXT,"LoadingPrediction<0000>")<>0 Или Найти(СтрокаTXT,"LoadingPrediction<"+СокрЛП(НомерМагазина)+">")<>0  Тогда
					глСкачатьПредсказания 	       			= Истина;
				КонецЕсли;
				
				Если Найти(СтрокаTXT,"AskErorrCheck<0000>")<>0 Или Найти(СтрокаTXT,"AskErorrCheck<"+СокрЛП(НомерМагазина)+">")<>0  Тогда
					глВыгрузитьФайлНаFTP_АварийныеРС 	       	= Истина;
				КонецЕсли;

				Если Найти(СтрокаTXT,"mag<0000>")=0 И Найти(СтрокаTXT,"mag<"+СокрЛП(НомерМагазина)+">")=0 Тогда  	
					Продолжить;	
				КонецЕсли;	
				
				Если Найти(СтрокаTXT,"v<" + ТекущаяВерсияКонф + ">")=0 Тогда  	
					Продолжить;	
				КонецЕсли;	
				
				Если Найти(СтрокаTXT,"Date<00000000>")=0 И Найти(СтрокаTXT,"Date<")=0  Тогда 
					Продолжить;
				КонецЕсли;
				
				Попытка
					Если Дата(Сред(СтрокаTXT, Найти(СтрокаTXT,"Date<")+5, 8)) > ТекущаяДата() Тогда 
						Продолжить;
					КонецЕсли;	
				Исключение
					// ошибка при считывании строки: не найдена дата начала доступности обновлений на сервере (http:\\update.prostor.ua)  
				КонецПопытки;	
									
				Пока Найти(СтрокаTXT,">;")<>0 Цикл
					ТегНачала 				= Найти(СтрокаTXT,"upd<");
					ТегКонца 				= Найти(СтрокаTXT,">;");
					Версия_Upd				= Сред(СтрокаTXT,ТегНачала+4,ТегКонца-ТегНачала-4);
					СтрокаTXT 				= СтрЗаменить(СтрокаTXT, "upd<"+Версия_Upd+">;", "");
					
					Структура				= Новый Структура;
					Структура.Вставить("Версия", Версия_Upd);
					Структура.Вставить("Версия_", СтрЗаменить(Версия_Upd,".","_"));
					МассивВерсий_Upd.Добавить(Структура);
				КонецЦикла;	
				СтрокаДоступныеВерсии	= СтрПолучитьСтроку(Текст, й); 
				NotAsk = Истина;
				Если Найти(СтрокаДоступныеВерсии,"NotAsk<1>")<>0 Тогда 
					NotAsk = Ложь;	
				КонецЕсли;	
                СтрокаДоступныеВерсии	= СокрЛП(Прав(СтрокаДоступныеВерсии, СтрДлина(СтрокаДоступныеВерсии)-Найти(СтрокаДоступныеВерсии,"=>")-1));
				СтрокаДоступныеВерсии	= СтрЗаменить(СтрокаДоступныеВерсии,";"," ");
				СтрокаДоступныеВерсии	= СокрЛП(СтрЗаменить(СтрокаДоступныеВерсии,"upd",""));
				Прервать;
			КонецЦикла;	
		КонецЕсли;	
		
		Если МассивВерсий_Upd.Количество()= 0 тогда			
			 Возврат;
		КонецЕсли;
		
		Если NotAsk Тогда 
			Режим = РежимДиалогаВопрос.ДаНет;
			Ответ = Вопрос("Доступны обновления для конфигурации 1С:УФР(" + СтрокаДоступныеВерсии + ")!!! Скачать обновления и установить ??? ",Режим,0,,"Доступны обновления для БД 1С:УФР !!! Текущая версия конфигурации " + "v<" + ТекущаяВерсияКонф + ">");
			Если Ответ = КодВозвратаДиалога.Нет Тогда
		    	Возврат;
			КонецЕсли;
		КонецЕсли;	

		й	= 0;
		ИндексСкаченогоОбнов	= -1;	
		Пока й < МассивВерсий_Upd.Количество() Цикл 
			ЭлементМассива = МассивВерсий_Upd[й];
			
			АдрHTTP_cfu    			= СерверHTTP 				+ "/" + ЭлементМассива.Версия + "/" + ЭлементМассива.Версия_+".cfu";
			АдрЛокальный_cfu  	  	= КаталогВременныхФайлов() 	+ "/" + ЭлементМассива.Версия + "/" + ЭлементМассива.Версия_+".cfu";
			Попытка
				Логирование.ДобавитьЗаписьЖурнала(, "УстановкаОбновлений()","Копируем дистрибутив обновлений (v." + ЭлементМассива.Версия + ")", Неопределено, Неопределено, "ОбщиеМодули.ОбновлениеБД");
		       				
				Сообщить("На сервере доступны обновления 1С:УФР !!! Текущая версия v." + ТекущаяВерсияКонф);
				Сообщить("Копируем дистрибутив обновлений (v." + ЭлементМассива.Версия + ")");
				СоздатьКаталог(КаталогВременныхФайлов()+ "/" + ЭлементМассива.Версия);
				ВходящийФайл 					= Новый Файл(АдрЛокальный_cfu);
				КопироватьФайл(АдрHTTP_cfu, АдрЛокальный_cfu);
				Сообщить("Файл скопирован !!!" + " => " + ЭлементМассива.Версия_ + ".cfu");
				ИндексСкаченогоОбнов		= й;
				Прервать;							
			Исключение
				УдалитьФайлы(АдрЛокальный_cfu);
				Сообщить(АдрHTTP_cfu + " => " + "Ошибка:"+ОписаниеОшибки());
				й = й+1;
				
				Логирование.ДобавитьЗаписьЖурнала(УровеньЖурналаРегистрации.Ошибка, "УстановкаОбновлений()","Копируем дистрибутив обновлений (v." + ЭлементМассива.Версия + ")", Неопределено, Неопределено, "ОбщиеМодули.ОбновлениеБД");
			КонецПопытки;	                                      
		КонецЦикла;
		
		Если ИндексСкаченогоОбнов <0 Тогда 
			Сообщить("ОШИБКА: Файлы обновлений не загружены !!! Сообщите системному администратору !");
			Возврат;
		КонецЕсли;
		
    		
		Попытка                                                                        
			шелл = Новый COMОбъект("WScript.Shell");
			Сообщить("Идет установка обновлений ...");                                   
			шелл.Run(ПроверитьПараметрНаПробелы(КаталогПрограммы()+"1CV8.EXE")+ " CONFIG /F " + ПроверитьПараметрНаПробелы(КаталогИБ()) + " /N Программист /P developer13 /UpdateCfg " + ПроверитьПараметрНаПробелы(КаталогВременныхФайлов() + МассивВерсий_Upd[ИндексСкаченогоОбнов].Версия + "\" + МассивВерсий_Upd[ИндексСкаченогоОбнов].Версия_ + ".cfu"),1,1);
			Если КонфигурацияИзменена() тогда
				Константы.ПризнакНачалаУстановкиОбновлений.Установить(Истина);
				Константы.НомерВерсииКонфигурации.Установить(МассивВерсий_Upd[ИндексСкаченогоОбнов].Версия);
				ОбновлениеКонфигурацииБД();
			Иначе 
				Предупреждение("ОШИБКА: Основная конфигурация не обновлена. Установка обновлений прервана !!! Сообщите системному администратору !")
			КонецЕсли;	
		Исключение
			Предупреждение("ОШИБКА: Основная конфигурация не обновлена. Установка обновлений прервана !!! Сообщите системному администратору !");
		КонецПопытки;
		
		
    КонецЕсли;
КонецПроцедуры	

Функция ПроверкаНаличияОбновления () Экспорт 
	СерверHTTP				= Метаданные.АдресКаталогаОбновлений;
	АдрHTTP_version			= СерверHTTP + "/version.xml";
	АдрЛокальный_version 	= КаталогВременныхФайлов() + "version.xml";
	ТекущаяВерсияКонф		= Метаданные.Версия;

	МассивВерсий_Upd		= Новый Массив;


	Попытка
		ВходящийФайл 		= Новый Файл(АдрЛокальный_version);
		КопироватьФайл(АдрHTTP_version, АдрЛокальный_version);
		//Сообщить( "Файл скопирован !!!" + " => " + АдрHTTP_version);
	Исключение
		//УдалитьФайлы(АдрЛокальный_version);
		//Сообщить("ОШИБКА КОПИРОВАНИЯ(version.xml): " +ОписаниеОшибки());
	КонецПопытки;

	Если ВходящийФайл.Существует() тогда
		ТекстовыйФайл 		= Новый ТекстовыйДокумент;
		ТекстовыйФайл.Прочитать(АдрЛокальный_version);
		Текст = ТекстовыйФайл.ПолучитьТекст();

		Если Текст <> ""  Тогда
			Для й = 1 По СтрЧислоСтрок(Текст) Цикл 
				СтрокаTXT 	= СтрПолучитьСтроку(Текст, й);
				Если Найти(СтрокаTXT,"v<" + ТекущаяВерсияКонф + ">")=0 Тогда  
					Продолжить;
				КонецЕсли;	
				
				Возврат	Истина // есть обновления						
				
			КонецЦикла;	
		КонецЕсли;	
	КонецЕсли;	
	
	Возврат Ложь; // нет обновлений
КонецФункции	

#КонецОбласти
