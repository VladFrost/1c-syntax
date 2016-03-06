#Использовать asserts
#Использовать cmdline
#Использовать logos

Перем Лог;
Перем ИмяКаталогаСборки;
Перем КаталогСборки;
Перем ПутьКБинарникамНод;

Процедура Инициализация()

	Лог = Логирование.ПолучитьЛог("1c-syntax.app.build");
	Лог.УстановитьУровень(УровниЛога.Информация);
	
	ИмяКаталогаСборки = "build";
	СоздатьКаталогиСборки();
	
	ПутьКБинарникамНод = ОбъединитьПути("node_modules", ".bin");
	
	КомандаЗапуска = "npm -v";
	ВыполнитьКоманду(КомандаЗапуска, "Ошибка проверки версии npm");
	
	КомандаЗапуска = "npm install";
	ВыполнитьКоманду(КомандаЗапуска, "Ошибка установки пакетов node.js");

КонецПроцедуры

Процедура СоздатьКаталогиСборки()

	ИмяКаталогаСборки = "build";
	
	КаталогСборки = ОбеспечитьКаталог(ТекущийКаталог(), ИмяКаталогаСборки);
	
	КаталогAtom = ОбеспечитьКаталог(КаталогСборки, "Atom");
	КаталогГрамматик = ОбеспечитьКаталог(КаталогAtom, "grammars");
	КаталогСниппетов = ОбеспечитьКаталог(КаталогAtom, "snippets");
	
	КаталогST = ОбеспечитьКаталог(КаталогСборки, "ST");
	КаталогСниппетов = ОбеспечитьКаталог(КаталогST, "snippets");
	
	КаталогVSC = ОбеспечитьКаталог(КаталогСборки, "VSC");
	КаталогГрамматик = ОбеспечитьКаталог(КаталогVSC, "syntaxes");
	КаталогСниппетов = ОбеспечитьКаталог(КаталогVSC, "snippets");

КонецПроцедуры

Функция ОбеспечитьКаталог(БазовыйКаталог, НовыйКаталог)
	
	ПутьКНовомуКаталогу = ОбъединитьПути(БазовыйКаталог, НовыйКаталог);
	НовыйКаталог_Файл = Новый Файл(ПутьКНовомуКаталогу);
	Если НЕ НовыйКаталог_Файл.Существует() Тогда
		СоздатьКаталог(ПутьКНовомуКаталогу);
	КонецЕсли;
	
	Возврат ПутьКНовомуКаталогу;
	
КонецФункции

Процедура ВыполнитьСкрипт()
	
	Парсер = Новый ПарсерАргументовКоманднойСтроки();
	Парсер.ДобавитьПараметрФлаг("-bsl");
	Парсер.ДобавитьПараметрФлаг("-sdbl");
	Парсер.ДобавитьПараметрФлаг("-snippets");
	Параметры = Парсер.Разобрать(АргументыКоманднойСтроки);
	
	СобратьBSL      = Ложь;
	СобратьSDBL     = Ложь;
	СобратьСниппеты = Истина;
	
	Если Параметры.Количество() = 0 Тогда
		СобратьBSL      = Истина;
		СобратьSDBL     = Истина;
		СобиратьСниппеты = Истина;
	Иначе
		
		Если Параметры["-bsl"] Тогда
			СобратьBSL = Истина;
		КонецЕсли;
		
		Если Параметры["-sdbl"] Тогда
			СобратьSDBL = Истина;
		КонецЕсли;
		
		Если Параметры["-snippets"] Тогда
			СобиратьСниппеты = Истина;
		КонецЕсли;

	КонецЕсли;
	
	Если СобратьBSL Тогда
		СобратьГрамматикуЯзыка("1c");
	КонецЕсли;
	
	Если СобратьSDBL Тогда
		СобратьГрамматикуЯзыка("1c-query");
	КонецЕсли;

	Если СобиратьСниппеты Тогда
		СобратьСниппеты();
	КонецЕсли;

КонецПроцедуры

Процедура СобратьГрамматикуЯзыка(Знач ИмяФайлаЯзыка)
	
	Лог.Информация("Собираю грамматику по файлу " + ИмяФайлаЯзыка);
	
	Ожидаем.Что(Новый Файл(ИмяФайлаЯзыка + ".YAML-tmLanguage").Существует(), "Ожидаем, что файл языка существует").ЭтоИстина();
		
	КомандаЗапуска = "%1\yaml2json --pretty %3.YAML-tmLanguage > %2\%3.json";
	КомандаЗапуска = СтрШаблон(КомандаЗапуска, ПутьКБинарникамНод, КаталогСборки, ИмяФайлаЯзыка);
	ВыполнитьКоманду(КомандаЗапуска, "Ошибка компиляции YAML -> JSON");
	
	КомандаЗапуска = "%1\json2cson %2\%3.json > %2\%3.cson";
	КомандаЗапуска = СтрШаблон(КомандаЗапуска, ПутьКБинарникамНод, КаталогСборки, ИмяФайлаЯзыка);
	ВыполнитьКоманду(КомандаЗапуска, "Ошибка компиляции JSON -> CSON");
	
	ИмяВременногоФайла = ОбъединитьПути(КаталогСборки, "build_tmLanguage.js");
	
	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	
	ТекстСкрипта =
	"var plist = require('plist');
	|var fs = require('fs');
	|
	|var jsonString = fs.readFileSync('./%1/%2.json', 'utf8');
	|var jsonObject = JSON.parse(jsonString);
	|var plistString = plist.build(jsonObject);
	|
	|fs.writeFileSync('./%1/%2.tmLanguage', plistString);";
	
	ТекстСкрипта = СтрШаблон(ТекстСкрипта, ИмяКаталогаСборки, ИмяФайлаЯзыка);
	
	ТекстовыйДокумент.УстановитьТекст(ТекстСкрипта);
	ТекстовыйДокумент.Записать(ИмяВременногоФайла);
	
	КомандаЗапуска = "node " + ИмяВременногоФайла;
	ВыполнитьКоманду(КомандаЗапуска, "Ошибка компиляции JSON -> tmLanguage");
	
	УдалитьФайлы(ИмяВременногоФайла);
	УдалитьФайлы(ОбъединитьПути(КаталогСборки, ИмяФайлаЯзыка + ".json"));
	
КонецПроцедуры

Процедура СобратьСниппеты()
	
	Лог.Информация("Собираю сниппеты");
	
	ИмяФайлаСниппетов = "snippets";
	Ожидаем.Что(Новый Файл("snippets.yml").Существует(), "Ожидаем, что файл сниппетов существует").ЭтоИстина();
		
	КомандаЗапуска = "node build_st_snippets.js";
	ВыполнитьКоманду(КомандаЗапуска, "Ошибка сбора сниппетов для ST");
	
	КомандаЗапуска = "node build_vsc_snippets.js";
	ВыполнитьКоманду(КомандаЗапуска, "Ошибка сбора сниппетов для VSC");
	
	КомандаЗапуска = "node build_atom_snippets.js";
	ВыполнитьКоманду(КомандаЗапуска, "Ошибка сбора сниппетов для Atom");
		
КонецПроцедуры
	
Функция ОбернутьВКавычки(Знач Строка)
	Возврат """" + Строка + """";
КонецФункции

Процедура ВыполнитьКоманду(Знач КомандаЗапуска, Знач ТекстОшибки = "", Знач РабочийКаталог = "")

	Лог.Информация("Выполняю команду: " + КомандаЗапуска);

	Процесс = СоздатьПроцесс("cmd.exe /C " + ОбернутьВКавычки(КомандаЗапуска), РабочийКаталог, Истина, , КодировкаТекста.UTF8);
	Процесс.Запустить();
	
	Процесс.ОжидатьЗавершения();
	
	Пока НЕ Процесс.Завершен ИЛИ Процесс.ПотокВывода.ЕстьДанные Цикл
		СтрокаВывода = Процесс.ПотокВывода.ПрочитатьСтроку();
		Сообщить(СтрокаВывода);
	КонецЦикла;
	
	Если Процесс.КодВозврата <> 0 Тогда
		Лог.Ошибка("Код возврата: " + Процесс.КодВозврата);
		ВызватьИсключение ТекстОшибки + Символы.ПС + Процесс.ПотокОшибок.Прочитать();
	КонецЕсли;

КонецПроцедуры

Инициализация();
ВыполнитьСкрипт();
