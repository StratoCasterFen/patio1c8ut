﻿
// ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ
Процедура ПриОткрытии()
	
	ЗаполнитьТаблицуГруппСопутствующихТоваров();
	
	ЗаполнитьДеревоГруппСопутствующихТоваров();
	
КонецПроцедуры

// Обработка выбора значения в подчиненной форме
Процедура ОбработкаВыбора(ЗначениеВыбора, Источник)
	
	Перем Команда, ВыбранноеЗначение;

	Если ТипЗнч(ЗначениеВыбора) = Тип("Структура") Тогда
		ЗначениеВыбора.Свойство("Команда", Команда);
		ЗначениеВыбора.Свойство("Номенклатура"    , ВыбранноеЗначение);
		
		Если Команда = "ПодборВТабличнуюЧастьТовары" И НЕ ПроверитьСписокНаЗадвоение(ВыбранноеЗначение, СписокТоваров) Тогда
			СписокТоваров.Добавить(ВыбранноеЗначение);
			
			ОбработкаДобавленияНоменклатуры(ВыбранноеЗначение, СписокТоваров);
			
		ИначеЕсли Команда = "ПодборВТабличнуюЧастьАксессуары" И НЕ ПроверитьСписокНаЗадвоение(ВыбранноеЗначение, СписокАксессуаров) Тогда
			СписокАксессуаров.Добавить(ВыбранноеЗначение);
			
			ОбработкаДобавленияНоменклатуры(ВыбранноеЗначение, СписокАксессуаров);
			
		КонецЕсли;
	КонецЕсли;

КонецПроцедуры

Процедура КоманднаяПанельОсновнаяОтображениеСлужебныхДанных(Кнопка)
	
	НаборДополнительныхКнопок = ЭлементыФормы.КоманднаяПанельОсновная.Кнопки.ОтображениеДополнительныхДанных;
	
	ВидимостьСлужебныхДанных = ЭлементыФормы.ПанельОбщая.Страницы.СлужебныеДанные.Видимость;
	
	ЭлементыФормы.ПанельОбщая.Страницы.СлужебныеДанные.Видимость = Не ВидимостьСлужебныхДанных;
	
	НаборДополнительныхКнопок.Кнопки.ОтображениеСлужебныхДанных.Текст = ?(ВидимостьСлужебныхДанных, "Показать служебные данные", "Скрыть служебные данные");
	
КонецПроцедуры

// Обработчики списка товаров
Процедура СписокТоваровПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования, Отказ)
	
	ВыбранноеЗначение = Элемент.ТекущиеДанные.Значение;

	Если Не ОтменаРедактирования Тогда
		// Проверим наличие товара в списке
		Если НЕ ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
			Сообщить("Товар не выбран !");
			
			Отказ = Истина;
		ИначеЕсли ПроверитьСписокНаЗадвоение(ВыбранноеЗначение, СписокТоваров) Тогда
			Отказ = Истина;
		Иначе
			ОбработкаДобавленияНоменклатуры(ВыбранноеЗначение, СписокТоваров);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура СписокТоваровПередНачаломИзменения(Элемент, Отказ)
	// Строки менять нельзя
	Отказ = Истина;
КонецПроцедуры

Процедура СписокТоваровПередУдалением(Элемент, Отказ)
	
	ВыбраннаяНоменклатура = Элемент.ТекущиеДанные.Значение;
	
	// Получим данные по иерархии товара, подчиненного выбрано позиции
	ТабЗначений = ПолучитьСписокНоменклатуры(ВыбраннаяНоменклатура);
	
	// Удалим позиции товаров из списков
	Для Каждого СтрТабЗначений Из ТабЗначений Цикл
		СтруктураОтбора = Новый Структура("Номенклатура");
		СтруктураОтбора.Вставить("Номенклатура", СтрТабЗначений.Номенклатура);
		
		// Чистим основную таблицу
		СуществующиеСтроки = ТаблицаСоответствий.НайтиСтроки(СтруктураОтбора);
		
		Для Каждого СуществующаяСтрока Из СуществующиеСтроки Цикл
			ТаблицаСоответствий.Удалить(СуществующаяСтрока);
		КонецЦикла;
		
		// Чистим таблицу данных
		СуществующиеСтроки = ТабличноеПолеДанные.НайтиСтроки(СтруктураОтбора);
		
		Для Каждого СуществующаяСтрока Из СуществующиеСтроки Цикл
			ТабличноеПолеДанные.Удалить(СуществующаяСтрока);
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры

// Обработчики списка аксессуаров
Процедура СписокАксессуаровПередОкончаниемРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования, Отказ)
	
	ВыбранноеЗначение = Элемент.ТекущиеДанные.Значение;

	Если Не ОтменаРедактирования Тогда
		// Проверим наличие аксессуара в списке
		Если НЕ ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
			Сообщить("Аксессуар не выбран !");
			Отказ = Истина;
		ИначеЕсли ПроверитьСписокНаЗадвоение(ВыбранноеЗначение, СписокАксессуаров) Тогда
			Отказ = Истина;
		Иначе
			ОбработкаДобавленияНоменклатуры(ВыбранноеЗначение, СписокАксессуаров, Ложь);
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

Процедура СписокАксессуаровПередНачаломИзменения(Элемент, Отказ)
	// Строки менять нельзя
	Отказ = Истина;
КонецПроцедуры

Процедура СписокАксессуаровПередУдалением(Элемент, Отказ)
	
	ВыбраннаяНоменклатура = Элемент.ТекущиеДанные.Значение;
	
	// Получим данные по иерархии товара, подчиненного выбрано позиции
	ТабЗначений = ПолучитьСписокНоменклатуры(ВыбраннаяНоменклатура);

	Для Каждого СтрТабЗначений Из ТабЗначений Цикл
		СтруктураОтбора = Новый Структура("Аксессуар");
		СтруктураОтбора.Вставить("Аксессуар", СтрТабЗначений.Номенклатура);
		
		//// Чистим основную таблицу
		//СуществующиеСтроки = ТаблицаСоответствий.НайтиСтроки(СтруктураОтбора);
		//
		//Для Каждого СуществующаяСтрока Из СуществующиеСтроки Цикл
		//	ТаблицаСоответствий.Удалить(СуществующаяСтрока);
		//КонецЦикла;
		
		// Уберем ненужную колонку
		УдалитьКолонкуТаблицыДанных(СтрТабЗначений.Номенклатура);
	КонецЦикла;
	
КонецПроцедуры

// Обработчики таблицы данных
Процедура ТабличноеПолеДанныеПриИзмененииФлажка(Элемент, Колонка)
	
	// Добавим или удалим из результирующей таблицы данные
	ВыбранныйАксессуар	 = Справочники.Номенклатура.НайтиПоКоду(Сред(Колонка.Имя, 2));
	ВыбранныйТовар		 = Элемент.ТекущиеДанные["Номенклатура"];
	ВыполнитьПривязку	 = Элемент.ТекущиеДанные[Колонка.Имя];
	
	ОбработатьФлажок(ВыбранныйТовар, ВыбранныйАксессуар, ВыполнитьПривязку);
	
КонецПроцедуры

// ОБЩИЕ ПРОЦЕДУРЫ

// Процедура добавляет данные по привязкам в таблицу соответствий
Процедура ДополнитьТаблицуДаннымиРегистра(ВыбраннаяНоменклатура)
	
	НаборЗаписей = РегистрыСведений.НоменклатураИАксессуары.СоздатьНаборЗаписей();
	
	НаборЗаписей.Отбор.Номенклатура.Установить(ВыбраннаяНоменклатура);
	
	НаборЗаписей.Прочитать();
	
	СтруктураОтбора = Новый Структура("Номенклатура, Аксессуар");
	
	Для Каждого Запись Из НаборЗаписей Цикл
		СтруктураОтбора.Вставить("Номенклатура", Запись.Номенклатура);
		СтруктураОтбора.Вставить("Аксессуар", Запись.Аксессуар);
		
		СуществующиеСтроки = ТаблицаСоответствий.НайтиСтроки(СтруктураОтбора);
		
		Если НЕ СуществующиеСтроки.Количество() Тогда
			НоваяСтрока = ТаблицаСоответствий.Добавить();
			
			ЗаполнитьЗначенияСвойств(НоваяСтрока, Запись);
			
			НоваяСтрока.ИзРегистра = Истина;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Процедура проставляет данные по наличию добавленного аксессуара у товаров
Процедура ОбработкаДобавленияАксессуараВТаблицуДанных(ВыбранноеЗначение)
	
	СтруктураОтбораТовар	 = Новый Структура("Номенклатура");
	СтруктураОтбораАксесс	 = Новый Структура("Аксессуар", ВыбранноеЗначение);
	
	СуществующиеСтроки = ТаблицаСоответствий.НайтиСтроки(СтруктураОтбораАксесс);
	
	ИмяКолонки = СформироватьИмяКолонки(ВыбранноеЗначение);
	
	Для Каждого СуществующаяСтрока Из СуществующиеСтроки Цикл
		СтруктураОтбораТовар.Вставить("Номенклатура", СуществующаяСтрока.Номенклатура);
		
		СтрокиТовара = ТабличноеПолеДанные.НайтиСтроки(СтруктураОтбораТовар);
		
		Для Каждого СтрокаТовара Из СтрокиТовара Цикл
			СтрокаТовара[ИмяКолонки] = Истина;
		КонецЦикла;
	КонецЦикла;
	
КонецПроцедуры

// Обработка подборов
Процедура КоманднаяПанельСписокАксессуаровПодборАксессуаров(Кнопка)
	
	Команда = "ПодборВТабличнуюЧастьАксессуары";
	
	СписокВидовПодбора = Новый СписокЗначений();
	СписокВидовПодбора.Добавить(,"По справочнику");
	
	СтруктураПараметровПодбора = Новый Структура();
	СтруктураПараметровПодбора.Вставить("Команда"              , Команда);
	СтруктураПараметровПодбора.Вставить("СписокВидовПодбора"   , СписокВидовПодбора);
	СтруктураПараметровПодбора.Вставить("ДатаРасчетов"         , ТекущаяДата());
	СтруктураПараметровПодбора.Вставить("Заголовок", "Подбор аксессуаров");
	
	ОткрытьПодбор(СтруктураПараметровПодбора);

КонецПроцедуры

Процедура КоманднаяПанельСписокТоваровПодборТоваров(Кнопка)
	
	Команда = "ПодборВТабличнуюЧастьТовары";
	
	СписокВидовПодбора = Новый СписокЗначений();
	СписокВидовПодбора.Добавить(,"По справочнику");
	
	СтруктураПараметровПодбора = Новый Структура();
	СтруктураПараметровПодбора.Вставить("Команда"              , Команда);
	СтруктураПараметровПодбора.Вставить("СписокВидовПодбора"   , СписокВидовПодбора);
	СтруктураПараметровПодбора.Вставить("ДатаРасчетов"         , ТекущаяДата());
	СтруктураПараметровПодбора.Вставить("Заголовок", "Подбор товаров");
	
	ОткрытьПодбор(СтруктураПараметровПодбора);

КонецПроцедуры

// Процедура обрабатывает добавление номенклатуры в списки
Процедура ОбработкаДобавленияНоменклатуры(ВыбраннаяНоменклатура, Таблица, ИзПодбора = Истина)
	
	ТабЗначений = ПолучитьСписокНоменклатуры(ВыбраннаяНоменклатура);
		
	Если Таблица = СписокТоваров Тогда
		Для Каждого СтрокаНоменклатура Из ТабЗначений Цикл
			ДобавитьТовар(СтрокаНоменклатура.Номенклатура);
		КонецЦикла;
	ИначеЕсли Таблица = СписокАксессуаров Тогда
		Если ИзПодбора Тогда
			Для Каждого СтрокаНоменклатура Из ТабЗначений Цикл
				ДобавитьАксессуар(СтрокаНоменклатура.Номенклатура);
			КонецЦикла;
		Иначе
			ДобавитьАксессуар(ВыбраннаяНоменклатура);	
		КонецЕсли;	
	КонецЕсли;
	
КонецПроцедуры

// Процедура добавления товара в список товаров
Процедура ДобавитьТовар(ВыбранноеЗначение)
	
	ДополнитьТаблицуДаннымиРегистра(ВыбранноеЗначение);
	ДобавитьСтрокуТаблицыДанных(ВыбранноеЗначение);
	
КонецПроцедуры

// Процедура добавления аксессуара в список аксессуаров
Процедура ДобавитьАксессуар(ВыбранноеЗначение)
	
	ДобавитьКолонкуТаблицыДанных(ВыбранноеЗначение);
	ОбработкаДобавленияАксессуараВТаблицуДанных(ВыбранноеЗначение);
	
КонецПроцедуры

// Процедура проставляет данные по наличию аксессуаров у добавленного товара
Процедура ОбработкаДобавленияТовараВТаблицуДанных(СтрокаТаблицы)
	
	ВыбранноеЗначение = СтрокаТаблицы.Номенклатура;
	
	СтруктураОтбораТовар = Новый Структура("Номенклатура", ВыбранноеЗначение);
	
	СуществующиеСтроки = ТаблицаСоответствий.НайтиСтроки(СтруктураОтбораТовар);
	
	Для Каждого СуществующаяСтрока Из СуществующиеСтроки Цикл
		ИмяКолонки = СформироватьИмяКолонки(СуществующаяСтрока.Аксессуар);
		
		Если НЕ ТабличноеПолеДанные.Колонки.Найти(ИмяКолонки) = Неопределено Тогда
			СтрокаТаблицы[ИмяКолонки] = Истина;
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры

// Процедуры обработки таблицы данных рабочей области
Процедура ДобавитьСтрокуТаблицыДанных(ВыбраннаяНоменклатура)
	
	СтруктураОтбора = Новый Структура("Номенклатура");
	СтруктураОтбора.Вставить("Номенклатура", ВыбраннаяНоменклатура);
	
	СуществующиеСтроки = ТабличноеПолеДанные.НайтиСтроки(СтруктураОтбора);
	
	Если НЕ СуществующиеСтроки.Количество() Тогда
		НоваяСтрока = ТабличноеПолеДанные.Добавить();
		НоваяСтрока.Номенклатура = ВыбраннаяНоменклатура;
		
		Для Каждого КолонкаТаблицыДанных Из ТабличноеПолеДанные.Колонки Цикл
			Если ТипЗнч(НоваяСтрока[КолонкаТаблицыДанных.Имя]) = Тип("Неопределено") Тогда
				НоваяСтрока[КолонкаТаблицыДанных.Имя] = Ложь;
			КонецЕсли;
		КонецЦикла;
		
		ОбработкаДобавленияТовараВТаблицуДанных(НоваяСтрока);
	КонецЕсли;
	
КонецПроцедуры

Процедура ДобавитьКолонкуТаблицыДанных(ВыбранноеЗначение)
	
	КолонкиТаблицыДанных = ТабличноеПолеДанные.Колонки;
	
	// Добавим колонку
	КолонкаТаблицыДанных = КолонкиТаблицыДанных.Добавить();
	
	ИмяКолонки = СформироватьИмяКолонки(ВыбранноеЗначение);
	
	КолонкаТаблицыДанных.Имя			 = ИмяКолонки;
	КолонкаТаблицыДанных.Заголовок		 = Строка(ВыбранноеЗначение);
	
	// Настроим форму
	КолонкаТаблицыФормы = ЭлементыФормы.ТабличноеПолеДанные.Колонки.Добавить(ИмяКолонки, Строка(ВыбранноеЗначение));
	
	КолонкаТаблицыФормы.РежимРедактирования				 = РежимРедактированияКолонки.Непосредственно;
	КолонкаТаблицыФормы.ГоризонтальноеПоложениеВКолонке	 = ГоризонтальноеПоложение.Центр;
	КолонкаТаблицыФормы.ДанныеФлажка					 = ИмяКолонки;
	
	КолонкаТаблицыФормы.УстановитьЭлементУправления(Тип("Флажок"));
	
	// Проставим значения в добавленой колонке
	ТабличноеПолеДанные.ЗаполнитьЗначения(Ложь, ИмяКолонки);
	
КонецПроцедуры

Процедура УдалитьКолонкуТаблицыДанных(ВыбранноеЗначение)
	
	Если НЕ ЗначениеЗаполнено(ВыбранноеЗначение) Тогда
		Возврат;
	КонецЕсли;
	
	ИмяКолонки = СформироватьИмяКолонки(ВыбранноеЗначение);
	
	КолонкиТаблицыДанных = ТабличноеПолеДанные.Колонки;
	КолонкиТаблицыФормы	 = ЭлементыФормы.ТабличноеПолеДанные.Колонки;
	
	КолонкиТаблицыДанных.Удалить(КолонкиТаблицыДанных.Найти(ИмяКолонки));
	КолонкиТаблицыФормы.Удалить(КолонкиТаблицыФормы.Найти(ИмяКолонки));
	
КонецПроцедуры

// Процедуры обработки ячеек
Процедура КоманднаяПанельТаблицаДанныхВыбратьВсюКолонку(Кнопка)
	УстановитьЗначенияФлажков(Истина, Ложь);
КонецПроцедуры

Процедура КоманднаяПанельТаблицаДанныхОтменитьВыборВсейКолонки(Кнопка)
	УстановитьЗначенияФлажков(Ложь, Ложь);
КонецПроцедуры

Процедура КоманднаяПанельТаблицаДанныхВыбратьВсеЯчейки(Кнопка)
	УстановитьЗначенияФлажков(Истина, Истина);
КонецПроцедуры

Процедура КоманднаяПанельТаблицаДанныхОтменитьВыборВсехЯчеек(Кнопка)
	УстановитьЗначенияФлажков(Ложь, Истина);
КонецПроцедуры

// Процедура устанавливает значение флажков в ячейках
Процедура УстановитьЗначенияФлажков(ЗначениеФлажка = Истина, ПоВсейТаблице = Ложь)
	
	Если ПоВсейТаблице Тогда
		Для Каждого КолонкаТаблицыДанных Из ТабличноеПолеДанные.Колонки Цикл
			Если НЕ КолонкаТаблицыДанных.Имя = "Номенклатура" Тогда
				ТабличноеПолеДанные.ЗаполнитьЗначения(ЗначениеФлажка, КолонкаТаблицыДанных.Имя);
				
				Для Каждого СтрокаТаблицыДанных Из ТабличноеПолеДанные Цикл
					ОбработатьФлажок(СтрокаТаблицыДанных["Номенклатура"], ПолучитьНоменклатуруПоИмениКолонки(КолонкаТаблицыДанных.Имя), ЗначениеФлажка)
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
	Иначе
		// Получим список выделенных ячеек
		ВыделенныеСтроки	 = ЭлементыФормы.ТабличноеПолеДанные.ВыделенныеСтроки;
		ИмяВыделеннойКолонки = ЭлементыФормы.ТабличноеПолеДанные.ТекущаяКолонка.Имя;
		
		Для Каждого ВыделеннаяСтрока Из ВыделенныеСтроки Цикл
			ВыделеннаяСтрока[ИмяВыделеннойКолонки] = ЗначениеФлажка;
			
			ОбработатьФлажок(ВыделеннаяСтрока["Номенклатура"], ПолучитьНоменклатуруПоИмениКолонки(ИмяВыделеннойКолонки), ЗначениеФлажка)
		КонецЦикла;
	КонецЕсли;
	
КонецПроцедуры

// Процедура работы с подбором номенклатуры
Процедура ОткрытьПодбор(СтруктураПараметров)
	
	// Открываем форму подбора.
	ФормаПодбора = Обработки.ПодборНоменклатуры.ПолучитьФорму("ОсновнаяФорма", ЭтаФорма, ЭтаФорма);
	ФормаПодбора.ОбработкаОбъект.СтруктураИсходныхПараметров = СтруктураПараметров;
	ФормаПодбора.Открыть();
	
КонецПроцедуры

// Дополняет список аксессуаров по данными из списка товаров
Процедура КоманднаяПанельСписокТоваровЗаполнитьПоТоварам(Кнопка)
	
	ЗапросДанных = Новый Запрос;
	
	ЗапросДанных.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	                     |	НоменклатураИАксессуары.Аксессуар
	                     |ИЗ
	                     |	РегистрСведений.НоменклатураИАксессуары КАК НоменклатураИАксессуары
	                     |ГДЕ
	                     |	НоменклатураИАксессуары.Номенклатура В ИЕРАРХИИ(&СписокНоменклатуры)";
						 
	ЗапросДанных.УстановитьПараметр("СписокНоменклатуры", СписокТоваров);
	
	РезультатЗапроса = ЗапросДанных.Выполнить().Выгрузить();
	
	// Дозаполним список
	Для Каждого СтрокаРезультата Из РезультатЗапроса Цикл
		Если НЕ ПроверитьСписокНаЗадвоение(СтрокаРезультата.Аксессуар, СписокАксессуаров, Ложь) Тогда
			СписокАксессуаров.Добавить(СтрокаРезультата.Аксессуар);
			
			ОбработкаДобавленияНоменклатуры(СтрокаРезультата.Аксессуар, СписокАксессуаров);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Дополняет список товаров по данными из списка аксессуаров
Процедура КоманднаяПанельСписокАксессуаровЗаполнитьПоАксессуарам(Кнопка)
	
	ЗапросДанных = Новый Запрос;
	
	ЗапросДанных.Текст = "ВЫБРАТЬ РАЗЛИЧНЫЕ
	                     |	НоменклатураИАксессуары.Номенклатура КАК Товар
	                     |ИЗ
	                     |	РегистрСведений.НоменклатураИАксессуары КАК НоменклатураИАксессуары
	                     |ГДЕ
	                     |	НоменклатураИАксессуары.Аксессуар В ИЕРАРХИИ(&СписокАксессуаров)";
						 
	ЗапросДанных.УстановитьПараметр("СписокАксессуаров", СписокАксессуаров);
	
	РезультатЗапроса = ЗапросДанных.Выполнить().Выгрузить();
	
	// Дозаполним список
	Для Каждого СтрокаРезультата Из РезультатЗапроса Цикл
		Если НЕ ПроверитьСписокНаЗадвоение(СтрокаРезультата.Товар, СписокТоваров, Ложь) Тогда
			СписокТоваров.Добавить(СтрокаРезультата.Товар);
			
			ОбработкаДобавленияНоменклатуры(СтрокаРезультата.Товар, СписокТоваров);
		КонецЕсли;
		
	КонецЦикла;
	
КонецПроцедуры

// Процедура обрабатывает установку флажка
Процедура ОбработатьФлажок(ВыбранныйТовар, ВыбранныйАксессуар, ВыполнитьПривязку)
	
	СтруктураОтбора = Новый Структура("Номенклатура, Аксессуар", ВыбранныйТовар, ВыбранныйАксессуар);
	
	СуществующиеСтроки = ТаблицаСоответствий.НайтиСтроки(СтруктураОтбора);
	
	// В зависимости от значения флажка проведем действия над таблицей
	Если НЕ СуществующиеСтроки.Количество() И ВыполнитьПривязку Тогда
		НоваяСтрока = ТаблицаСоответствий.Добавить();
		
		НоваяСтрока.Номенклатура = ВыбранныйТовар;
		НоваяСтрока.Аксессуар	 = ВыбранныйАксессуар;
		НоваяСтрока.ИзРегистра	 = Ложь;
	ИначеЕсли СуществующиеСтроки.Количество() И НЕ ВыполнитьПривязку Тогда
	КонецЕсли;
	
КонецПроцедуры

// Заполняет таблицу соответствий групп сопутствующих товаров
Процедура ЗаполнитьТаблицуГруппСопутствующихТоваров()
	
	// Получим данные хранилища
	ДанныеБазы = Справочники.ХранилищеДополнительнойИнформации.НайтиПоНаименованию("ГруппировкаСопутствующихТоваров");
	
	ДанныеХранилища = ДанныеБазы.Хранилище.Получить();
	
	Если ТипЗнч(ДанныеХранилища) = Тип("ТаблицаЗначений") Тогда
		ТаблицаГруппСопутствующихТоваров.Загрузить(ДанныеХранилища);
	КонецЕсли;
	
КонецПроцедуры

// Заполняет дерево соответствий групп сопутствующих товаров
Процедура ЗаполнитьДеревоГруппСопутствующихТоваров()
	
	// Отсортируем таблицу
	ТаблицаГруппСопутствующихТоваров.Сортировать("ГруппаТовар");
	
	ТекущаяГруппа = "";
	Для Каждого СтрокаТаблицыГрупп Из ТаблицаГруппСопутствующихТоваров Цикл
		Если Не ТекущаяГруппа = СтрокаТаблицыГрупп.ГруппаТовар Тогда
			ТекущийУзел = ГруппыСопутствующихТоваров.Строки.Добавить();
			
			ТекущийУзел.ГруппаТовар					 = СтрокаТаблицыГрупп.ГруппаТовар;
			ТекущийУзел.ПредставлениеГруппыТовар	 = СтрокаТаблицыГрупп.ПредставлениеГруппыТовар;
			
			ТекущаяГруппа = СтрокаТаблицыГрупп.ГруппаТовар;
		КонецЕсли;
		
		ПодчиненныйУзел = ТекущийУзел.Строки.Добавить();
		
		ПодчиненныйУзел.НомерСтрокиОсновнойТаблицы	 = СтрокаТаблицыГрупп.НомерСтроки;
		ПодчиненныйУзел.ГруппаТовар					 = СтрокаТаблицыГрупп.ГруппаТовар;
		ПодчиненныйУзел.ПредставлениеГруппыТовар	 = СтрокаТаблицыГрупп.ПредставлениеГруппыТовар;
		ПодчиненныйУзел.ГруппаАксессуар				 = СтрокаТаблицыГрупп.ГруппаАксессуар;
		ПодчиненныйУзел.ПредставлениеГруппыАксессуар = СтрокаТаблицыГрупп.ПредставлениеГруппыАксессуар;
		
	КонецЦикла;
	
КонецПроцедуры

// ОБЩИЕ ФУНКЦИИ

Функция СформироватьИмяКолонки(Значение)
	
	Префикс = "К";
	
	Если НЕ ЗначениеЗаполнено(Значение) Тогда
		Возврат Префикс;
	КонецЕсли;
	
	Возврат Префикс + СокрЛП(Значение.Код);
	
КонецФункции

Функция ПолучитьНоменклатуруПоИмениКолонки(ИмяКолонки)
	
	Результат = Справочники.Номенклатура.ПустаяСсылка();
	
	Если ЗначениеЗаполнено(ИмяКолонки) Тогда
		Результат = Справочники.Номенклатура.НайтиПоКоду(Сред(ИмяКолонки, 2));
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Функция проверяет список на наличие в нем добавляемого элемента
Функция ПроверитьСписокНаЗадвоение(ВыбранноеЗначение, Список, ВыводитьСообщение = Истина)
	
	ТабЗначений = ПолучитьСписокНоменклатуры(ВыбранноеЗначение);
	
	Если Список = СписокТоваров Тогда
		Для Каждого СтрТабЗначений Из ТабЗначений Цикл
			СтруктураОтбора = Новый Структура("Номенклатура", СтрТабЗначений.Номенклатура);
			
			СуществующиеСтроки = ТабличноеПолеДанные.НайтиСтроки(СтруктураОтбора);
			
			Результат = ?(СуществующиеСтроки.Количество() > 0, Истина, Ложь);
			
			Если Результат Тогда
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если Результат И ВыводитьСообщение Тогда
			Предупреждение("Выбраный товар (или товары из выбраной группы) уже есть в списке !");
		КонецЕсли;
	Иначе
		Для Каждого СтрТабЗначений Из ТабЗначений Цикл
			ИмяКолонки = СформироватьИмяКолонки(СтрТабЗначений.Номенклатура);
			
			Результат = ?(ТабличноеПолеДанные.Колонки.Найти(ИмяКолонки) = Неопределено, Ложь, Истина);
			
			Если Результат Тогда
				Прервать;
			КонецЕсли;
		КонецЦикла;
		
		Если Результат И ВыводитьСообщение Тогда
			Предупреждение("Выбраный аксессуар (или аксессуары из выбраной группы) уже есть в списке !");
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

// Возвращает список номенклатуры из соответствующей группы
Функция ПолучитьСписокНоменклатуры(Позиция)
	
	Перем ТабЗначений;
	
	Если Позиция.ЭтоГруппа Тогда
		ЗапросДанных = Новый Запрос;
		
		ЗапросДанных.Текст = "ВЫБРАТЬ
		                     |	Номенклатура.Ссылка КАК Номенклатура
		                     |ИЗ
		                     |	Справочник.Номенклатура КАК Номенклатура
		                     |ГДЕ
		                     |	Номенклатура.Ссылка В ИЕРАРХИИ(&ГруппаНоменклатуры)
		                     |	И НЕ Номенклатура.ЭтоГруппа
		                     |	И НЕ Номенклатура.ПометкаУдаления";
							 
		ЗапросДанных.УстановитьПараметр("ГруппаНоменклатуры", Позиция);
		
		ТабЗначений = ЗапросДанных.Выполнить().Выгрузить();
		
	Иначе
		ТабЗначений = Новый ТаблицаЗначений;
		
		ТабЗначений.Колонки.Добавить("Номенклатура");
		
		НоваяСтрока = ТабЗначений.Добавить();
		НоваяСтрока.Номенклатура = Позиция;
		
	КонецЕсли;
	
	Возврат ТабЗначений;
	
КонецФункции

Процедура КоманднаяПанельГруппыСопутствующихТоваровСохранитьДанные(Кнопка)
	
	// Получим данные хранилища
	ДанныеБазы = Справочники.ХранилищеДополнительнойИнформации.НайтиПоНаименованию("ГруппировкаСопутствующихТоваров");
	
	ДанныеБазыОбъект = ДанныеБазы.ПолучитьОбъект();
	
	ДанныеБазыОбъект.Хранилище = Новый ХранилищеЗначения(ТаблицаГруппСопутствующихТоваров.Выгрузить());
	
	ДанныеБазыОбъект.Записать();
	
КонецПроцедуры

Процедура КоманднаяПанельГруппыСопутствующихТоваровДобавитьГруппуТоваров(Кнопка)
	
	ГруппыСопутствующихТоваров.Строки.Добавить();
	
КонецПроцедуры

Процедура ГруппыСопутствующихТоваровПриОкончанииРедактирования(Элемент, НоваяСтрока, ОтменаРедактирования)
	
	// Ищем данные в таблице. Если нет - добавляем
	Если НЕ Элемент.ТекущиеДанные.Родитель = Неопределено Тогда
		Если НЕ НоваяСтрока Тогда
			СтрокаТаблицыГрупп = ТаблицаГруппСопутствующихТоваров.Получить(Число(Элемент.ТекущиеДанные.НомерСтрокиОсновнойТаблицы) - 1);
		Иначе
			СтрокаТаблицыГрупп = ТаблицаГруппСопутствующихТоваров.Добавить();
			
			Элемент.ТекущиеДанные.НомерСтрокиОсновнойТаблицы = СтрокаТаблицыГрупп.НомерСтроки;
		КонецЕсли;
		
		СтрокаТаблицыГрупп.ГруппаТовар					 = Элемент.ТекущиеДанные.ГруппаТовар;
		СтрокаТаблицыГрупп.ПредставлениеГруппыТовар		 = Элемент.ТекущиеДанные.ПредставлениеГруппыТовар;
		СтрокаТаблицыГрупп.ГруппаАксессуар				 = Элемент.ТекущиеДанные.ГруппаАксессуар;
		СтрокаТаблицыГрупп.ПредставлениеГруппыАксессуар	 = Элемент.ТекущиеДанные.ПредставлениеГруппыАксессуар;
	КонецЕсли;
	
КонецПроцедуры

Процедура ГруппыСопутствующихТоваровПередНачаломИзменения(Элемент, Отказ)
	
	Отказ = Истина;
	
	Если Элемент.ТекущиеДанные.Родитель = Неопределено Тогда
		// Верхний уровень
		Отказ = НЕ (Элемент.ТекущаяКолонка.Имя = "ГруппаТовар" ИЛИ Элемент.ТекущаяКолонка.Имя = "ПредставлениеГруппыТовар");
	Иначе
		// Нижний уровень
		Отказ = НЕ (Элемент.ТекущаяКолонка.Имя = "ГруппаАксессуар" ИЛИ Элемент.ТекущаяКолонка.Имя = "ПредставлениеГруппыАксессуар");
	КонецЕсли;
	
КонецПроцедуры

Процедура ГруппыСопутствующихТоваровПередНачаломДобавления(Элемент, Отказ, Копирование, Родитель)
	
	// Добавлять можно только к основному узлу
	Если НЕ Элемент.ТекущиеДанные.Родитель = Неопределено Тогда
		Отказ = Истина;
	КонецЕсли;
		
КонецПроцедуры

Процедура ГруппыСопутствующихТоваровПередУдалением(Элемент, Отказ)
	
	// Удалим строку или группу строк
	Если Элемент.ТекущиеДанные.Родитель = Неопределено Тогда
		СтруктураПоиска	 = Новый Структура("ГруппаТовар", Элемент.ТекущиеДанные.ГруппаТовар);
		НайденыеСтроки	 = ТаблицаГруппСопутствующихТоваров.НайтиСтроки(СтруктураПоиска);
		
		Для Каждого НайденаяСтрока Из НайденыеСтроки Цикл
			ТаблицаГруппСопутствующихТоваров.Удалить(НайденаяСтрока);
		КонецЦикла;
	Иначе
		ТаблицаГруппСопутствующихТоваров.Удалить(Число(Элемент.ТекущиеДанные.НомерСтрокиОсновнойТаблицы) - 1);
	КонецЕсли;
	
КонецПроцедуры

Процедура ГруппыСопутствующихТоваровПриНачалеРедактирования(Элемент, НоваяСтрока, Копирование)
	
	Если НЕ Элемент.ТекущиеДанные.Родитель = Неопределено Тогда
		Элемент.ТекущиеДанные.ГруппаТовар = Элемент.ТекущиеДанные.Родитель.ГруппаТовар;
		Элемент.ТекущиеДанные.ПредставлениеГруппыТовар = Элемент.ТекущиеДанные.Родитель.ПредставлениеГруппыТовар;
	КонецЕсли;
	
КонецПроцедуры

// ------------------------------------------------------------
// Сохраняет данные в регистр сведений
Процедура СохранитьДанные()
	
	// Откроем форму прогресса
	ФормаПрогресса = ЭтотОбъект.ПолучитьФорму("ФормаПрогресс");
	Индикатор = ФормаПрогресса.ЭлементыФормы.ИндикаторЗаписи;
	
	Индикатор.МинимальноеЗначение	 = 0;
	Индикатор.МаксимальноеЗначение	 = ТабличноеПолеДанные.Количество();
	
	ФормаПрогресса.Открыть();
	
	Для Каждого СтрокаТовар Из ТабличноеПолеДанные Цикл
		Для Каждого СтрокаАксессуар Из ТабличноеПолеДанные.Колонки Цикл
			// Отбросим первую колонку
			Если СтрокаАксессуар.Имя = "Номенклатура" Тогда
				Продолжить;
			КонецЕсли;
			
			СтруктураОтбора = Новый Структура("Номенклатура, Аксессуар", СтрокаТовар.Номенклатура, ПолучитьНоменклатуруПоИмениКолонки(СтрокаАксессуар.Имя));
			
			// Смотрим, что есть в регистре
			ДанныеРегистра = РегистрыСведений.НоменклатураИАксессуары.СоздатьНаборЗаписей();
			
			ДанныеРегистра.Отбор.Номенклатура.Установить(СтруктураОтбора["Номенклатура"]);
			ДанныеРегистра.Отбор.Аксессуар.Установить(СтруктураОтбора["Аксессуар"]);
			
			ДанныеРегистра.Прочитать();
			
			// Проверяем наличие привязки
			ЕстьПривязка = СтрокаТовар[СтрокаАксессуар.Имя];
			
			// Обрабатываем данные регистра
			Если ЕстьПривязка И ДанныеРегистра.Количество() Тогда				// Есть и там, и там
				// Ничего не делаем
			ИначеЕсли ЕстьПривязка И НЕ ДанныеРегистра.Количество() Тогда		// Добавили соответствие
				// Добавляем данные	
				НоваяЗапись = ДанныеРегистра.Добавить();
				
				ЗаполнитьЗначенияСвойств(НоваяЗапись, СтруктураОтбора);
				
				ДанныеРегистра.Записать();
				
				// Проставим значения в таблице соответствий
				СтрокиСоответсвий = ТаблицаСоответствий.НайтиСтроки(СтруктураОтбора);
				
				Для Каждого СтрокаСоответствий Из СтрокиСоответсвий Цикл
					СтрокаСоответствий.ИзРегистра = Истина;
				КонецЦикла;
				
			ИначеЕсли НЕ ЕстьПривязка И ДанныеРегистра.Количество() Тогда		// Удалили соответствие
				// Удаляем данные
				ДанныеРегистра.Очистить();
				
				ДанныеРегистра.Записать();
				
				// Проставим значения в таблице соответствий
				СтрокиСоответсвий = ТаблицаСоответствий.НайтиСтроки(СтруктураОтбора);
				
				Для Каждого СтрокаСоответствий Из СтрокиСоответсвий Цикл
					ТаблицаСоответствий.Удалить(СтрокаСоответствий);
				КонецЦикла;
			КонецЕсли;
		КонецЦикла;
		
		Индикатор.Значение = ТабличноеПолеДанные.Индекс(СтрокаТовар);
		
	КонецЦикла;
	
	// Вычистим все, что не попало в регистр
	СтрокиНаУдаление = ТаблицаСоответствий.НайтиСтроки(Новый Структура("ИзРегистра", Ложь));
	
	Для Каждого СтрокаНаУдаление Из СтрокиНаУдаление Цикл
		ТаблицаСоответствий.Удалить(СтрокаНаУдаление);
	КонецЦикла;
	
	// Закроем окно прогресса и сообщим о сохранении данных
	ФормаПрогресса.Закрыть();
	
	Предупреждение("Данные сохранены.");
	
КонецПроцедуры

Процедура ПанельОбщаяПриСменеСтраницы(Элемент, ТекущаяСтраница)
	
	Если Элемент.ТекущаяСтраница.Имя = "СвязиГруппТоваров" Тогда
		ЭлементыФормы.ОсновныеДействияФормы.Кнопки.ОсновныеДействияФормыВыполнить.Доступность = Ложь;
	Иначе
		ЭлементыФормы.ОсновныеДействияФормы.Кнопки.ОсновныеДействияФормыВыполнить.Доступность = Истина;
	КонецЕсли;
	
КонецПроцедуры

Процедура КоманднаяПанельОсновнаяОтображениеСвязейГруппТоваров(Кнопка)
	
	НаборДополнительныхКнопок = ЭлементыФормы.КоманднаяПанельОсновная.Кнопки.ОтображениеДополнительныхДанных;
	
	ВидимостьСвязейГруппТоваров = ЭлементыФормы.ПанельОбщая.Страницы.СвязиГруппТоваров.Видимость;
	
	ЭлементыФормы.ПанельОбщая.Страницы.СвязиГруппТоваров.Видимость = Не ВидимостьСвязейГруппТоваров;
	
	НаборДополнительныхКнопок.Кнопки.ОтображениеСвязейГруппТоваров.Текст = ?(ВидимостьСвязейГруппТоваров, "Показать связи групп товаров", "Скрыть связи групп товаров");

КонецПроцедуры
