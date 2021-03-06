﻿
&НаСервере
Процедура ИсточникСпискаПриИзмененииНаСервере()
	Объект.Материалы.Очистить();
	ТН = Объект.ИсточникСписка.ПолучитьОбъект();
	ТнМатериалы = ТН.Материалы.Выгрузить();
	
	Для каждого ТекСтрокаМатериалы из ТнМатериалы Цикл
		НоваяСтрока = Объект.Материалы.Добавить(); 
		НоваяСтрока.Номенклатура = ТекСтрокаМатериалы.Номенклатура;
		НоваяСтрока.Количество = ТекСтрокаМатериалы.Количество;
	КонецЦикла;
	
	
	//Запрос актуальных складов
	ЗапросСкладов = Новый Запрос;
	ЗапросСкладов.Текст = 
		"ВЫБРАТЬ
		|	Склады.Ссылка КАК Ссылка
		|ИЗ
		|	Справочник.Склады КАК Склады";
	
	РезультатЗапросаСкладов = ЗапросСкладов.Выполнить();
	
	ВыборкаСкладов = РезультатЗапросаСкладов.Выгрузить();
	//Добавление складов на форму. Если добавлены уже, то пропуск
	Если СкладыДобавлены = Ложь Тогда
		Для каждого СтрокаСклада из ВыборкаСкладов Цикл
			НаименованиеСклада = СтрокаСклада.Ссылка.Наименование;
			ДобавитьКолонкуНаСервере(НаименованиеСклада);
		КонецЦикла;
	Иначе
		РезультатЗапросаСкладов = ЗапросСкладов.Выполнить();
		ВыборкаСкладов = РезультатЗапросаСкладов.Выгрузить();
		Для каждого СтрокаСклада из ВыборкаСкладов Цикл
			НаименованиеСклада = СтрокаСклада.Ссылка.Наименование;
			ОтобразитьВсеКолонкиСкладов(НаименованиеСклада);
		КонецЦикла;
	КонецЕсли;
	СкладыДобавлены = Истина;
	
	
	
	//Заполнение кол-ва по складам и по номенклатуре
	Для каждого СтрокаТабличнойЧасти из объект.Материалы Цикл
		Для каждого СтрокаСклада из ВыборкаСкладов Цикл
			
			Запрос = Новый Запрос;
			Запрос.Текст = 
				"ВЫБРАТЬ
				|	ОстаткиНоменклатурыОстатки.Номенклатура КАК Номенклатура,
				|	ОстаткиНоменклатурыОстатки.Склад КАК Склад,
				|	ОстаткиНоменклатурыОстатки.КоличествоОстаток КАК КоличествоОстаток
				|ИЗ
				|	РегистрНакопления.ОстаткиНоменклатуры.Остатки(
				|			&Дата,
				|			Склад = &СкладТекущий
				|				И Номенклатура = &НоменклатураТекущая) КАК ОстаткиНоменклатурыОстатки";
			
			Запрос.УстановитьПараметр("Дата", Объект.Дата);
			Запрос.УстановитьПараметр("НоменклатураТекущая", СтрокаТабличнойЧасти.Номенклатура);
			Запрос.УстановитьПараметр("СкладТекущий", СтрокаСклада.Ссылка);
			
			РезультатЗапроса = Запрос.Выполнить();				
			ВыборкаДетальныеЗаписи = РезультатЗапроса.Выгрузить();	
			
			ОстатокТекущий = 0;
			
			Для каждого СтрокаОстатка из ВыборкаДетальныеЗаписи Цикл
				Если СтрокаОстатка.Номенклатура = СтрокаТабличнойЧасти.Номенклатура Тогда
					ОстатокТекущий = СтрокаОстатка.КоличествоОстаток;
				КонецЕсли;
			КонецЦикла;
			
			
			СкладТекущий = СтрокаСклада.Ссылка.Наименование;
			
			//Присвоение остатка складу в строке номенклатуры
			Выполнить("СтрокаТабличнойЧасти." + СкладТекущий + " = ОстатокТекущий");		
			
		КонецЦикла;
	КонецЦикла;
	
	//Скрытие неиспользуемых колонок
	Для каждого СтрокаСклада из ВыборкаСкладов Цикл
		УбратьНеиспользуемыеКолонкиСкладов(НаименованиеСклада);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ИсточникСпискаПриИзменении(Элемент)
	ИсточникСпискаПриИзмененииНаСервере();	
КонецПроцедуры

&НаСервере
Процедура ДобавитьКолонкуНаСервере(НаименованиеСклада)	
		нРеквизиты = Новый Массив;
	    нРеквизиты.Добавить(Новый РеквизитФормы(НаименованиеСклада, Новый ОписаниеТипов("Число"), "Объект.Материалы", НаименованиеСклада, Истина));
	    ИзменитьРеквизиты(нРеквизиты);
	 
	    нЭлемент = Элементы.Добавить(НаименованиеСклада, Тип("ПолеФормы"), Элементы.Материалы); 
	    нЭлемент.Вид = ВидПоляФормы.ПолеВвода; 
	    Путик = "Объект.Материалы." + НаименованиеСклада; 
	    нЭлемент.ПутьКДанным = Путик;
	    нЭлемент.ТолькоПросмотр = Истина;
КонецПроцедуры

&НаСервере
Процедура УбратьНеиспользуемыеКолонкиСкладов(НаименованиеСклада)	
	Если Объект.Материалы.Итог(НаименованиеСклада) = 0 Тогда
		Выполнить("Элементы.Материалы.ПодчиненныеЭлементы." + НаименованиеСклада + ".Видимость = Ложь");
	КонецЕсли;	
КонецПроцедуры

&НаСервере
Процедура ОтобразитьВсеКолонкиСкладов(НаименованиеСклада)	
		Выполнить("Элементы.Материалы.ПодчиненныеЭлементы." + НаименованиеСклада + ".Видимость = Истина");	
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)

	ПопыткаУдалась = Ложь;
	
	//Проверка на открытие из документа "требование-накладная"
	Попытка
        ЗначениеЗаполнено(Параметры.ДокСсылка); 
        ПопыткаУдалась = Истина;
    Исключение
        ПопыткаУдалась = Ложь;
    КонецПопытки;
	Объект.Дата = ТекущаяДата();
	Если ПопыткаУдалась = Истина Тогда
		Документ = Параметры.ДокСсылка;
		Объект.ИсточникСписка = Документ;
		СкладыДобавлены = Ложь;
		Объект.Дата = Документ.Дата;
		ИсточникСпискаПриИзмененииНаСервере();
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура СоздатьПеремещение(Док,Номенклатура,Склад,Количество)
	Док.Дата=Объект.Дата - 1;
	Док.Отправитель = Справочники.Склады.НайтиПоНаименованию(Склад);		
	Стр=Док.Товары.Добавить();
	Стр.Номенклатура = Номенклатура;
	Стр.Количество = Количество;
КонецПроцедуры

&НаКлиенте
Процедура Передать(Команда)
	ТекСтрока = ЭтаФорма.ТекущийЭлемент.ТекущиеДанные;
	Номенклатура = ТекСтрока.Номенклатура;
	Склад = ТекущийЭлемент.ТекущийЭлемент.Имя;
	Количество = Элементы.Материалы.ТекущиеДанные[Склад];
	Форма=ПолучитьФорму("Документ.ПеремещениеТоваров.ФормаОбъекта",,ЭтаФорма);
	Док=Форма.Объект;
	СоздатьПеремещение(Док, Номенклатура, Склад, Количество);
	КопироватьДанныеФормы(Док, Форма.Объект);
	Форма.Открыть();
КонецПроцедуры

&НаКлиенте
Процедура Обновить(Команда)
	ИсточникСпискаПриИзмененииНаСервере();
КонецПроцедуры

&НаСервере
Процедура СоздатьПриходНаСервере(Док,Номенклатура,Количество, Склад)
	Док.Дата=Объект.Дата - 1;
	Док.Склад = Справочники.Склады.НайтиПоНаименованию(Склад);		
	Стр=Док.Товары.Добавить();
	Стр.Номенклатура = Номенклатура;
	Стр.Количество = Количество;

КонецПроцедуры

&НаКлиенте
Процедура СоздатьПриход(Команда)
	ТекСтрока = ЭтаФорма.ТекущийЭлемент.ТекущиеДанные;
	Номенклатура = ТекСтрока.Номенклатура;
	Склад = ТекущийЭлемент.ТекущийЭлемент.Имя;
	Количество = ТекСтрока.Количество;
	Форма=ПолучитьФорму("Документ.ПриходнаяНакладная.ФормаОбъекта",,ЭтаФорма);
	Док=Форма.Объект;
	СоздатьПриходНаСервере(Док, Номенклатура, Количество, Склад);
	КопироватьДанныеФормы(Док, Форма.Объект);
	Форма.Открыть();
КонецПроцедуры



