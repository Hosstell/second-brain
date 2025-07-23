## Переменная GOPATH

**GOPATH** — это путь(и) к “рабочему пространству” Go, где инструменты ищут исходники, хранят модули и складывают установленные бинарники.

- **Указывает корень рабочей директории(й)**  
    Раньше весь код должен был лежать в `$GOPATH/src/<import path>`. Сейчас можно работать где угодно, если есть `go.mod`.
- **Каталоги внутри GOPATH (по умолчанию `$HOME/go`):**
    - `bin/` — сюда попадают бинарники после `go install` (если не задан `GOBIN`).
    - `pkg/mod/` — кэш модулей (если не задан `GOMODCACHE`; по умолчанию он внутри GOPATH).
    - `pkg/` (устарело для модулей) — компилированные архивы пакетов в эпоху до модулей.
- **Поведение по умолчанию**  
    Если вы не зададите GOPATH, Go выставит его автоматически в `$HOME/go` (Unix) или `%USERPROFILE%\go` (Windows).
- **Когда вам всё ещё нужен GOPATH вручную**
    - Хотите хранить установленное из `go install` в другом месте.
    - Нужен отдельный модульный кэш (закрытая сеть, ограниченные права и т.п.).
    - Поддерживаете старые проекты без модулей.
- **Связанные переменные**
    - `GOBIN` — куда ставить бинарники (если задан, `bin/` внутри GOPATH не используется).
    - `GOMODCACHE` — где хранить кэш модулей (иначе `$GOPATH/pkg/mod`).
    - `GO111MODULE` (устаревшая, начиная с 1.17 всегда `on`) — переключала режим модулей.

> [!NOTE]  
> Нет, GOPATH **не** должен быть “корнем проекта”. 
> Это **один (или несколько) глобальных путей для рабочих данных Go**: кэша модулей и установленных бинарников. Все проекты обычно делят один GOPATH (по умолчанию `$HOME/go`).

## Переменная  GOTOOLPATH

Переменная окружения **GOTOOLDIR** определяет путь - каталог, куда устанавливаются
утилиты среды GoLang (например: /usr/lib/go-1.13/pkg/tool/linux_amd64)

> [!NOTE]
> **GOTOOLDIR** и **GOBIN**. Разница?
> - `GOTOOLDIR` — папка внутри **GOROOT** с внутренними инструментами компилятора Go.
> - `$HOME/go/bin` (или `$GOBIN`) — папка для **ваших** установленных утилит/CLI, собранных командой `go install`.

## Встроенная утилита для code style - **fmt**
Форматируем весь код во всех файлах в данной папке 
```bash
go fmt *.go 
```

## Общие модули(сторонние) и импортированные библиотеки
### Общие модули(сторонние)
Установка
```bash
go install github.com/username/pkg@version
```
Скаченный пакет сохраняется в `$GOPATH/bin`.
Файлы `go.mod` и `go.sum` **не меняются**.
### Импортированные библиотеки
Установка
```bash
go get github.com/username/pkg@version
```
Скаченный пакет сохраняется в `$GOPATH/pkg/mod`.
Файлы `go.mod` и `go.sum` **меняются**.

> [!NOTE]
> **Go не знает, откуда брать “просто `logger@v1.2.3`”**. Ему нужен **уникальный идентификатор модуля — его import path с доменом** (например, `github.com/user/logger`).
> 
> Для внешних модулей в Go стандарт — указывать полный import path (домен + путь) и версию.

Пример использования:
```bash
➜ go get github.com/astaxie/beego 
go: downloading github.com/astaxie/beego v1.12.3
go: downloading github.com/hashicorp/golang-lru v0.5.4
...
➜ awesomeProject git:(master) ✗ ll ~/go 
drwxrwxr-x - andrey 23 июл 14:17 pkg
➜ awesomeProject git:(master) ✗ ll ~/go/pkg 
drwxrwxr-x - andrey 23 июл 14:17 mod
drwxrwxr-x - andrey 23 июл 14:17 sumdb
➜ awesomeProject git:(master) ✗ ll ~/go/pkg/mod 
drwxrwxr-x - andrey 23 июл 14:17 cache
drwxrwxr-x - andrey 23 июл 14:17 github.com
drwxrwxr-x - andrey 23 июл 14:17 golang.org
drwxrwxr-x - andrey 23 июл 14:17 google.golang.org
drwxrwxr-x - andrey 23 июл 14:17 gopkg.in
➜ awesomeProject git:(master) ✗ ll ~/go/pkg/mod/github.com 
drwxrwxr-x - andrey 23 июл 14:17 astaxie
drwxrwxr-x - andrey 23 июл 14:17 beorn7
drwxrwxr-x - andrey 23 июл 14:17 cespare
drwxrwxr-x - andrey 23 июл 14:17 golang
drwxrwxr-x - andrey 23 июл 14:17 hashicorp
drwxrwxr-x - andrey 23 июл 14:17 matttproud
drwxrwxr-x - andrey 23 июл 14:17 prometheus
drwxrwxr-x - andrey 23 июл 14:17 shiena
➜ awesomeProject git:(master) ✗ ll ~/go/pkg/mod/github.com/astaxie 
dr-xr-xr-x - andrey 23 июл 14:17 beego@v1.12.3
➜ awesomeProject git:(master) ✗ ll ~/go/pkg/mod/github.com/astaxie/beego@v1.12.3 
.r--r--r--  13k andrey 23 июл 14:17 admin.go
.r--r--r-- 7,5k andrey 23 июл 14:17 admin_test.go
.r--r--r--  13k andrey 23 июл 14:17 adminui.go
...

```