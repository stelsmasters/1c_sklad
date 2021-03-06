﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Не ЗначениеЗаполнено(Объект.Дата) Тогда
	Объект.Дата = ТекущаяДата();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура ПриОткрытииНаСервере()
	Объект.Наименование = Объект.Владелец.Наименование + " от " + Объект.Дата;
	УпорядочитьТаблицуПоТипам();
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ПриОткрытииНаСервере();
КонецПроцедуры

Процедура УпорядочитьТаблицуПоТипам()
	Тб=Объект.Материалы.Выгрузить();
	Тб.Колонки.Добавить("Порядок");
	Для Каждого Стр из Тб Цикл
		Стр.Порядок=0+Стр.Номенклатура.Тип.ПорядокОтображения;
	КонецЦикла;
	Тб.Сортировать("Порядок ВОЗР");
	Объект.Материалы.Загрузить(Тб);
КонецПроцедуры

