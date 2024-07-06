## Переменные плагина PlantUML
- `PLANTUML_DOCKER_CONTEXT_DIR` - директория на хостовой машине, которая докером будет считаться корневой;
- `PLANTUML_DOCKER_DOCKERFILE` - путь к docker файлу;
- `PLANTUML_DOCKER_IMAGE` - локальное название образа докера;
- `PLANTUML_DOCKER_IMAGE_FROM` - название источника образа докера из которого будет собираться локальный образ;
- `PLANTUML_SOURCE_DIR` - корневая директория, где хранятся файлы `.puml`;
- `PLANTUML_OUTPUT_IN_DOCKER_DIR` - относительная от `PLANTUML_SOURCE_DIR` директория,
  куда будут сохраняться изображения;
- `PLANTUML_OUTPUT_FORMAT` - выходной формат изображения (png или svg);  

## Примеры диаграмм для PlantUML
- [C4 диаграммы](https://github.com/plantuml-stdlib/C4-PlantUML/blob/master/samples/C4CoreDiagrams.md)

## Работа с документацией проекта: Markdown + PlantUML

### Настройка редактора Visual Studio Code
В редакторе Visual Studio Code необходимо установить плагин `VSCode PlantUML`.

Далее нужно открыть настройки `VSCode PlantUML`:
File -> Preferences -> Settings -> Extensions -> PlantUML configuration -> Edit in `settings.json`
и добавить (или поправить) следующие параметры:

```json
{
    "plantuml.exportFormat": "svg",
    "plantuml.render": "PlantUMLServer",
    "plantuml.server": "https://www.plantuml.com/plantuml",
    "plantuml.urlFormat": "svg",
    "plantuml.includepaths": [
      "{PROJECT_DOC_DIR1}"
    ]
}
```
где `{PROJECT_DOC_DIR1}` - абсолютный путь к директории, в которой лежит документация проекта (например: `/home/work/project/doc`).

Параметр `plantuml.includepaths` необходим, для того чтобы в файлах `.puml` можно было использовать следующие относительные пути:
`!include components/c4/infrastructure/db_abstract.iuml`

### Команды редактора Visual Studio Code
- `Alt + D` - предварительный просмотр диаграммы при нахождении в PlantUML (в `.puml` файле);
- `Ctrl + Shift + V` - предварительный просмотр документа при нахождении в Markdown (в `.md` файле);

### Сборка изображений для их подключения в Markdown
`make plantuml build-all`
Данная команда ищет в директории `{PLANTUML_SOURCE_DIR}` все файлы с расширением `.puml`,
из них генерирует файлы изображений (png, svg) и складывает их
в директорию `{PROJECT_DOC_DIR1}/{PLANTUML_OUTPUT_IN_DOCKER_DIR}` с теми же названиями и относительными путями.