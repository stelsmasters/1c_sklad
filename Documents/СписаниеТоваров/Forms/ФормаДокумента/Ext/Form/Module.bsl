﻿
&НаСервере
Процедура УбратьДругиеТипыНаСервере()
	ТЗ = Объект.Товары.Выгрузить();
	ТЗ.Колонки.Добавить("ТипНоменклатуры");
	Для каждого СтрокаТЗ из ТЗ Цикл
		СтрокаТЗ.ТипНоменклатуры = СтрокаТЗ.Номенклатура.Тип;
	КонецЦикла;
	ПараметрыОтбора = Новый Структура("ТипНоменклатуры",Объект.ТипНоменклатуры);    
    ТЗНов = ТЗ.Скопировать(ПараметрыОтбора); 
	ТЗНов.Колонки.Удалить("ТипНоменклатуры");
	Объект.Товары.Очистить();
	Объект.Товары.Загрузить(ТЗНов);

КонецПроцедуры

&НаКлиенте
Процедура УбратьДругиеТипы(Команда)
	УбратьДругиеТипыНаСервере();
КонецПроцедуры
