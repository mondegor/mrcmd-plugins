# Plugins for Mrcmd Tool Changelog
Все изменения в Plugins for Mrcmd будут документироваться на этой странице.

## 2023-06-14
### Fixed
- Исправлена ошибка монтирования директорий в Windows;

### Removed
- mvn/docker-run-workdir.sh

## 2023-06-13
### Fixed
- В плагине mvn, если отсутствует файл pom.xml, то инсталляция прерывается;
- Поправлена инструкция инсталляции утилиты;

## 2023-06-12
### Added
- Добавлена в плагин docker команда для того, чтобы узнать текущий ip адрес указанного контейнера;
- Доработан плагин keycloak, добавлены в него новые команды: conf, certs, realm-export;
- В плагин mvn добавлена переменная MVN_SETTINGS_PATH;
- Добавлена передача динамических параметров в docker-compose/command-exec-shell;
- Добавлено в README.md описание плагинов;

### Changed
- Вместо указания пути к докер файлу, во всех плагинах использующих докер добавлены:
  - переменная *_DOCKER_CONTEXT_DIR, для указания текущей директории при компиляции докер образа;
  - переменная *_DOCKER_DOCKERFILE, для явного указания докер файла, если это необходимо (по умолчанию докер файл должен находиться здесь: *_DOCKER_CONTEXT_DIR/Dockerfile);
- Заменены переменные MRCMD_PLUGINS_DIR используемые при инициализации плагинов на MRCMD_CURRENT_PLUGIN_DIR;
- Переменная GO_DOCKER_COMPOSE_CONFIG_DIR заменена на DOCKER_COMPOSE_CONFIG_FILE_LAST и теперь там хранится путь к yaml файлу, который, при формировании docker-composer-ом общего yaml файла проекта, применяется самым последним, для того чтобы была возможность переопределения базовых настроек; 

### Fixed
- В плагине go-dev исправлена ситуация, когда $GOPATH отсутствует;

### Removed
- Удалено копирование плагинов из pm;

## 2023-05-27
### Added
- Добавлены плагины cassandra, plantuml;
- Добавлены утилиты в go-dev для работы GRPC;
- Добавлена в плагине sentry проверка существования рабочей директории перед его деинсталляции;

### Changed
- REDIS_ROOT_PASSWORD -> REDIS_PASSWORD
- APP_BIND -> APPX_SERVICE_BIND
- APP_PORT -> APPX_SERVICE_PORT

### Fixed
- DOCKER_DEFAULT_SHELL перенесён из global в docker;
- добавлена зависимость docker-compose для плагина go-migrate (из-за общей сети);
- env.app -> .env.app

## 2023-05-21
### Added
- Добавлен флаг project-directory для docker composer, чтобы возможно было использовать относительные пути при привязке внешних директорий к докерам;
- Изменена логика подключения общей сети, добавлена переменная DOCKER_COMPOSE_USE_GENERAL_NETWORK для управления ею;
- Добавлены новые плагины: mvn, java, keycloak, vendor;
- Плагинам: go, java, php, nodejs добавлена возможность подключения собственного env-file.yaml;

### Changed
- Изменилась логика связанная с INSTALL_BASH после этого он был переименован в DEFAULT_SHELL;
- Изменился параметр поднятия сервиса с unless-stopped на always;
- APPX_NETWORK -> DOCKER_COMPOSE_LOCAL_NETWORK;
- docker-cli.sh -> docker-run.sh;
- Заменено у плагинов NAME -> CAPTION;
- Обновлены разделы help у многих плагинов;
- Внесено множество правок в существующие плагины, чтобы их управление было более похожим;
- Переработан плагин web-php, теперь он заменён на следующие плагины: php-alpine, php-cli, php-fpm;  

### Fixed
- Добавлен отсутствующий оператор function у некоторых методов;

### Removed
phive-install-tool.sh;

## 2023-05-12
### Added
- Добавлено создание log директории в go плагине;
- Добавлена команда отображения логов запущенного go приложения logs;
- GO_APP_MAIN_FILE;

### Changed
- MRCMD_AVAILABLE_PLUGIN_METHODS_ARRAY -> MRCMD_PLUGIN_RESERVED_METHODS_ARRAY;

## 2023-05-01
### Fixed
- pl -> pm;

## 2023-04-23
### Changed
- Произведён рефакторинг кода;
- Отлажены плагины: docker, docker-compose, go, go-migrate, postgres, mysql, redis;