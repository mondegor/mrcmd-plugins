# Plugins for Mrcmd Tool Changelog
Все изменения в Plugins for Mrcmd будут документироваться на этой странице.

## 2023-11-12
### Added
- Добавлены переменные `MYSQL_DB_URL`, `MYSQL_DB_URL_JDBC`, `MONGO_DB_URL`, `MONGO_DB_URL_JDBC`;

### Changed
- Доработана библиотека `openapi-lib.sh` (добавлена поддержка headers, удалено понятие module);
- Условия if приведены к единому стилю;

## 2023-11-10
### Changed
- В `openapi-lib.sh` при формировании имени файла добавлено "-" после имени модуля;

## 2023-11-09
### Added
- Добавлена библиотека `openapi-lib.sh` для сборки OpenAPI документации из её фрагментов;

### Fixed
- Поправлено условие проверки индекса;

## 2023-10-18
### Added
- Для плагина `php-cli` добавлена `COMPOSER_SETUP_HASH` в которой должна содержаться актуальная hash сумма `composer-setup.php`;

### Fixed
- В плагине `php-cli` переименована  `JAVA_DOCKER_IMAGE` -> `PHP_CLI_DOCKER_IMAGE` для задания внешнего порта API;
- В плагине `php-cli` устранена ошибка возникающая при сборке образа: "Could not open input file: composer-setup.php", для этого добавлена `COMPOSER_SETUP_HASH` с актуальным hash;

## 2023-10-09
### Added
- Добавлена `MINIO_API_PUBLIC_PORT` для задания внешнего порта API;

### Changed
- `MINIO_WEB_ADMIN_USER` -> `MINIO_API_USER`;
- `MINIO_WEB_ADMIN_PASSWORD` -> `MINIO_API_PASSWORD`;

### Fixed
- Проброшен внешний порт `MINIO_API_PUBLIC_PORT` из порта 9000 в докере;

## 2023-09-20
### Added
- Добавлены `proxy_set_header` в `nginx` шаблоны;
- Добавлена команда `force` для плагина `go-migrate`;
- Для `minio` добавлен отдельный конфиг `nginx`, в первую очередь для работы сокетов;
- Для `minio` добавлен `healthcheck`;

## 2023-08-28
### Added
- Добавлен новый плагин: `rabbitmq`;
- В некоторые `Dockerfile` добавлены в виде комментариев порты, которые используют помещённые в них сервисы;

### Changed
- Обновлены версии некоторых плагинов;

## 2023-08-05
### Added
- Добавлены новые плагины: `kafka`, `zookeeper`, `kafka-ui`;
- Для плагина `minio` добавлены команды: `ng-into`, `ng-logs`;

### Changed
- Обновлены версии скачиваемых образов контейнеров используемых плагинами;
- Для плагина mvn изменена команда `mvn package` на `mvn clean package`;

### Fixed
- Поправлена помощь в некоторых плагинах;

### Removed
- Удалены лишние артефакты (файлы, ссылки);

## 2023-07-22
### Add
- В плагин `postgres` добавлена команда экспорта БД в виде sql файла; 

## 2023-07-16
### Fixed
- Теперь проверка, что `Docker Daemon` запущен работает и для Windows;
- В плагине `go-migrate` исправлен меппинг `/migrations`, чтобы он работал в Windows;

## 2023-07-14
### Added
- Добавлена глобальная переменная READONLY_*_DOCKER_HOST в которой хранится хост сервиса;

## 2023-06-17
### Added
- Добавлен плагин `ssh` с командами для генерации `SSH` ключей и регистрации их в `SSH Agent`;
- В плагин `mvn` добавлено удаление директории `target` при деинсталляции;

### Fixed
- Исправлено описание в примерах использования функций;

## 2023-06-16
### Added
- В плагин `docker` добавлена функция `mrcmd_plugins_docker_validate_daemon_required` для проверки того, что `docker daemon` запущен;

## 2023-06-14
### Fixed
- Исправлена ошибка монтирования директорий в Windows;

### Removed
- `mvn/docker-run-workdir.sh`

## 2023-06-13
### Fixed
- В плагине mvn, если отсутствует файл `pom.xml`, то инсталляция прерывается;
- Поправлена инструкция инсталляции утилиты;

## 2023-06-12
### Added
- В плагин `docker` добавлена команда для того, чтобы узнать текущий ip адрес указанного контейнера;
- Доработан плагин `keycloak`, добавлены в него новые команды: `conf`, `certs`, `realm-export`;
- В плагин `mvn` добавлена переменная MVN_SETTINGS_PATH;
- Добавлена передача динамических параметров в `docker-compose/command-exec-shell`;
- Добавлено в README.md описание плагинов;

### Changed
- Вместо указания пути к докер файлу, во всех плагинах использующих `docker` добавлены:
  - переменная *_DOCKER_CONTEXT_DIR, для указания текущей директории при компиляции докер образа;
  - переменная *_DOCKER_DOCKERFILE, для явного указания докер файла, если это необходимо (по умолчанию докер файл должен находиться здесь: `*_DOCKER_CONTEXT_DIR/Dockerfile`);
- Заменены переменные MRCMD_PLUGINS_DIR используемые при инициализации плагинов на MRCMD_CURRENT_PLUGIN_DIR;
- Переменная GO_DOCKER_COMPOSE_CONFIG_DIR заменена на DOCKER_COMPOSE_CONFIG_FILE_LAST и теперь там хранится путь к `yaml` файлу, который, при формировании `docker-compose` общего `yaml` файла проекта, применяется самым последним, для того чтобы была возможность переопределения базовых настроек; 

### Fixed
- В плагине `go-dev` исправлена ситуация, когда `$GOPATH` отсутствует;

### Removed
- Удалено копирование плагинов из `pm`;

## 2023-05-27
### Added
- Добавлены плагины `cassandra`, `plantuml`;
- Добавлены утилиты в `go-dev` для работы с `GRPC`;
- Добавлена в плагине `sentry` проверка существования рабочей директории перед его деинсталляции;

### Changed
- REDIS_ROOT_PASSWORD -> REDIS_PASSWORD
- APP_BIND -> APPX_SERVICE_BIND
- APP_PORT -> APPX_SERVICE_PORT

### Fixed
- DOCKER_DEFAULT_SHELL перенесён из `global` в `docker`;
- добавлена зависимость docker-compose для плагина `go-migrate` (из-за общей сети);
- `env.app` -> `.env.app`

## 2023-05-21
### Added
- Добавлен флаг `project-directory` для `docker-compose`, чтобы возможно было использовать относительные пути при привязке внешних директорий к докерам;
- Изменена логика подключения общей сети, добавлена переменная DOCKER_COMPOSE_USE_GENERAL_NETWORK для управления ею;
- Добавлены новые плагины: `mvn`, `java`, `keycloak`, `vendor`;
- Плагинам: `go`, `java`, `php`, `nodejs` добавлена возможность подключения собственного `env-file.yaml`;

### Changed
- Изменилась логика связанная с INSTALL_BASH после этого он был переименован в DEFAULT_SHELL;
- Изменился параметр поднятия сервиса с `unless-stopped` на `always`;
- APPX_NETWORK -> DOCKER_COMPOSE_LOCAL_NETWORK;
- `docker-cli.sh` -> `docker-run.sh`;
- Заменено у плагинов NAME -> CAPTION;
- Обновлены разделы `help` у многих плагинов;
- Внесено множество правок в существующие плагины, чтобы их управление было более похожим;
- Переработан плагин `web-php`, теперь он заменён на следующие плагины: `php-alpine`, `php-cli`, `php-fpm`;  

### Fixed
- Добавлен отсутствующий оператор `function` у некоторых методов;

### Removed
- `phive-install-tool.sh`;

## 2023-05-12
### Added
- Добавлено создание `log` директории в `go` плагине;
- Добавлена команда отображения логов запущенного `go` приложения `logs`;
- GO_APP_MAIN_FILE;

### Changed
- MRCMD_AVAILABLE_PLUGIN_METHODS_ARRAY -> MRCMD_PLUGIN_RESERVED_METHODS_ARRAY;

## 2023-05-01
### Fixed
- `pl` -> `pm`;

## 2023-04-23
### Changed
- Произведён рефакторинг кода;
- Отлажены плагины: `docker`, `docker-compose`, `go`, `go-migrate`, `postgres`, `mysql`, `redis`;