## Введение

На мой взгляд, сетевое программирование в Linux, особенно программирование сокетов, не так уж и сложно. Однако изучение этой темы самостоятельно может быть сложным, потому что многие онлайн-ресурсы неясны, а примеры кода часто охватывают только основы. Вы можете не знать, что делать дальше. Именно поэтому я создал этот учебник. Его цель — дать вам четкие рекомендации и множество примеров, чтобы помочь вам лучше понять.

Сетевое программирование в Linux связано с взаимодействием между процессами с использованием сетевых интерфейсов. Оно обеспечивает межпроцессовое взаимодействие (IPC), позволяя обмениваться данными между процессами, работающими на одном и том же компьютере или на разных компьютерах, подключенных к сети.

Основой сетевого программирования в Linux является использование сокетов — универсального API, предназначенного для межпроцессового взаимодействия. Сокеты появились в BSD Unix в 1983 году и позже были стандартизированы POSIX, что сделало их краеугольным камнем современных сетей.

## Сокеты

Сокет — это конечная точка для связи. Представьте его как дверь, через которую данные входят и выходят из процесса. Процессы используют сокеты для отправки и получения сообщений, обеспечивая бесшовное межпроцессовое взаимодействие (IPC).

Изначально сокеты поддерживали два домена:

**Домен Unix (Unix)**: Используется для связи между процессами в пределах одной и той же операционной системы.

**Интернет-домен (INET)**: Используется для связи между процессами на разных системах, подключенных через сеть TCP/IP.

Сокеты домена Unix используются для межпроцессового взаимодействия в пределах одной и той же операционной системы. Они работают быстрее, чем сокеты INET, потому что не требуют сетевого протокола. Вместо IP-адресов сокеты домена Unix используют пути файловой системы для адресации.

Сокеты домена INET используются для связи между процессами на разных системах, подключенных через сеть. Эти сокеты полагаются на стек протоколов TCP/IP, который обеспечивает целостность и доставку данных.

Два распространенных протокола, используемых с сокетами домена INET, это:

**TCP (Transmission Control Protocol)**: Обеспечивает надежную, упорядоченную и проверенную на наличие ошибок доставку данных.

**UDP (User Datagram Protocol)**: Обеспечивает быструю, неупорядоченную передачу данных без гарантий доставки.

### Типы сокетов

API сокетов BSD поддерживает несколько типов сокетов, которые определяют, как данные передаются между процессами:

**Потоковые сокеты (SOCK_STREAM)**: Обеспечивают надежный, ориентированный на соединение протокол связи. Данные отправляются и получаются в виде непрерывного потока байтов. Обычно используется с TCP (Transmission Control Protocol).

**Датаграммные сокеты (SOCK_DGRAM)**: Обеспечивают неупорядоченный протокол связи. Данные отправляются в виде отдельных пакетов, и доставка не гарантируется. Обычно используется с UDP (User Datagram Protocol).

**Сырые сокеты (SOCK_RAW)**: Позволяют процессам напрямую получать доступ к низкоуровневым сетевым протоколам, минуя стандартные слои TCP или UDP. Полезны для реализации пользовательских протоколов или инструментов мониторинга сети.

### Адресация сокетов

В домене INET сокеты идентифицируются двумя компонентами:

**IP-адрес**: 32-битное число (IPv4) или 128-битное число (IPv6), которое уникально идентифицирует устройство в сети. IPv4-адреса часто представляются в десятичной нотации с точками, например, 192.168.1.1.

**Номер порта**: 16-битное число, которое идентифицирует конкретную службу или приложение на устройстве. Например, веб-серверы обычно используют порт 80 (HTTP) или 443 (HTTPS).

Проверьте некоторые известные службы в системе Linux через файл /etc/services. Порты ниже 1024 обычно считаются специальными и требуют специальных привилегий операционной системы для использования.

```
worker@7e4a84e41875:~/study_workspace/LinuxNetworkProgramming$ cat /etc/services
tcpmux          1/tcp                           # TCP port service multiplexer
echo            7/tcp
echo            7/udp
...
ftp             21/tcp
fsp             21/udp          fspd
ssh             22/tcp                          # SSH Remote Login Protocol
telnet          23/tcp
smtp            25/tcp          mail
...
http            80/tcp          www             # WorldWideWeb HTTP
...
```

### API сокетов

#### getprotobyname()

```c
#include <netdb.h>

struct protoent *getprotobyname(const char *name);
```

Пример использования:

```c
struct protoent *proto;
proto = getprotobyname("tcp");
if (proto)
{
    printf("Protocol number for TCP: %d\n", proto->p_proto);
}
```

**Описание**: `getprotobyname()` возвращает структуру `protoent` для заданного имени протокола, которая содержит информацию о протоколе.

#### getservbyname()

```c
#include <netdb.h>

struct servent *getservbyname(const char *name, const char *proto);
```

Пример использования:

```c
struct servent *serv;
serv = getservbyname("http", "tcp");
if (serv)
{
    printf("Port number for HTTP: %d\n", ntohs(serv->s_port));
}
```

**Описание**: `getservbyname()` возвращает структуру `servent` для заданного имени службы и протокола, которая содержит информацию о службе.

#### getaddrinfo()

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>

struct addrinfo {
    int              ai_flags;     // AI_PASSIVE, AI_CANONNAME, etc.
    int              ai_family;    // AF_INET, AF_INET6, AF_UNSPEC
    int              ai_socktype;  // SOCK_STREAM, SOCK_DGRAM
    int              ai_protocol;  // use 0 for "any"
    size_t           ai_addrlen;   // size of ai_addr in bytes
    struct sockaddr *ai_addr;      // struct sockaddr_in or _in6
    char            *ai_canonname; // full canonical hostname

    struct addrinfo *ai_next;      // linked list, next node
};

int getaddrinfo(const char *node,     // e.g. "www.example.com" or IP
                const char *service,  // e.g. "http" or port number
                const struct addrinfo *hints,
                struct addrinfo **res);
```

Структура `addrinfo` содержит указатель на структуру `sockaddr`, которая используется во многих функциях сокетов.

Пример использования:

```c
int status;
struct addrinfo hints;
struct addrinfo *servinfo;  // will point to the results

memset(&hints, 0, sizeof(hints)); // make sure the struct is empty
hints.ai_family = AF_UNSPEC;     // don't care IPv4 or IPv6
hints.ai_socktype = SOCK_STREAM; // TCP stream sockets
hints.ai_flags = AI_PASSIVE;     // fill in my IP for me

if ((status = getaddrinfo(NULL, "3490", &hints, &servinfo)) != 0)
{
    fprintf(stderr, "getaddrinfo error: %s\n", gai_strerror(status));
    exit(1);
}

// servinfo now points to a linked list of 1 or more struct addrinfos

// ... do everything until you don't need servinfo anymore ....

freeaddrinfo(servinfo); // free the linked-list
```

**Описание**: `getaddrinfo()` используется для получения списка структур адресов для указанного узла и службы, которые могут быть использованы для создания и подключения сокетов.

#### htonl(), htons(), ntohl(), ntohs()

```c
#include <arpa/inet.h>

uint32_t htonl(uint32_t hostlong);
uint16_t htons(uint16_t hostshort);
uint32_t ntohl(uint32_t netlong);
uint16_t ntohs(uint16_t netshort);
```

Пример использования:

```c
uint32_t host_port = 8080;
uint32_t net_port = htonl(host_port);
printf("Network byte order: 0x%x\n", net_port);
```

**Описание**: Эти функции преобразуют значения между порядком байтов хоста и сети. `htonl()` и `htons()` преобразуют из порядка байтов хоста в сетевой порядок байтов, тогда как `ntohl()` и `ntohs()` преобразуют из сетевого порядка байтов в порядок байтов хоста.

```htons(uint16_t hostshort)```: Преобразует 16-битное число из порядка байтов хоста в сетевой порядок байтов.

```htonl(uint32_t hostlong)```: Преобразует 32-битное число из порядка байтов хоста в сетевой порядок байтов.

```ntohs(uint16_t netshort)```: Преобразует 16-битное число из сетевого порядка байтов в порядок байтов хоста.

```ntohl(uint32_t netlong)```: Преобразует 32-битное число из сетевого порядка байтов в порядок байтов хоста.

**Что такое сетевой порядок байтов?**

Сетевой порядок байтов — это стандартизированный способ организации байтов многобайтовых типов данных (например, целых чисел) в сетевой связи. Различные архитектуры процессоров могут обрабатывать данные в разных порядках, что называется "порядком байтов" (endianness).

> Big-endian (BE): Хранит наиболее значимый байт (the “big end”) первым. Это означает, что первый байт (на наименьшем адресе памяти) является самым большим, что имеет смысл для людей, читающих слева направо.

> Little-endian (LE): Хранит наименее значимый байт (the “little end”) первым. Это означает, что первый байт (на наименьшем адресе памяти) является самым маленьким, что имеет смысл для людей, читающих справа налево.

Данные, передаваемые в сети, всегда передаются в порядке байтов big-endian.

Данные, отправляемые с хост-машины, называются порядком байтов хоста и могут быть как big-endian, так и little-endian. Использование вышеуказанных функций гарантирует правильное взаимодействие между системами.

#### socket()

```c
#include <sys/types.h>
#include <sys/socket.h>

int socket(int domain, int type, int protocol);
```

Пример использования:

```c
int s;
struct addrinfo hints, *res;

getaddrinfo("www.example.com", "http", &hints, &res);

s = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
if (s == -1)
{
    perror("socket");
    exit(1);
}
```

**Описание**: `socket()` создает новый сокет и возвращает дескриптор файла для него.

#### setsockopt()

```c
#include <sys/types.h>
#include <sys/socket.h>

int setsockopt(int sockfd, int level, int optname, const void *optval, socklen_t optlen);
```

Пример использования:

```c
int sockfd; // Assume sockfd is a valid socket descriptor
int optval = 1;
if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval)) == -1)
{
    perror("setsockopt");
    exit(1);
}
```

**Описание**: `setsockopt()` устанавливает опции на сокете, такие как разрешение повторного использования локальных адресов.

#### bind()

```c
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>

int bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

Пример использования:

```c
int sockfd; // Assume sockfd is a valid socket descriptor
struct sockaddr_in my_addr;
my_addr.sin_family = AF_INET;
my_addr.sin_port = htons(3490);
my_addr.sin_addr.s_addr = INADDR_ANY;

if (bind(sockfd, (struct sockaddr *)&my_addr, sizeof(my_addr)) == -1)
{
    perror("bind");
    exit(1);
}
```

**Описание**: `bind()` назначает локальный адрес сокету.

#### listen()

```c
#include <sys/types.h>
#include <sys/socket.h>

int listen(int sockfd, int backlog);
```

Пример использования:

```c
int sockfd; // Assume sockfd is a valid socket descriptor
if (listen(sockfd, 10) == -1)
{
    perror("listen");
    exit(1);
}
```

**Описание**: `listen()` помечает сокет как пассивный сокет, который будет использоваться для принятия входящих запросов на подключение.

#### accept()

```c
#include <sys/types.h>
#include <sys/socket.h>

int accept(int sockfd, struct sockaddr *addr, socklen_t *addrlen);
```

Пример использования:

```c
int sockfd; // Assume sockfd is a valid socket descriptor
struct sockaddr_storage their_addr;
socklen_t addr_size = sizeof(their_addr);
int new_fd = accept(sockfd, (struct sockaddr *)&their_addr, &addr_size);
if (new_fd == -1)
{
    perror("accept");
    exit(1);
}
```

**Описание**: `accept()` принимает соединение на сокете. Если сервер хочет отправить ответные данные обратно клиенту, он отправит данные на возвращенный fd.

#### connect()

```c
#include <sys/types.h>
#include <sys/socket.h>

int connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
```

Пример использования:

```c
int sockfd; // Assume sockfd is a valid socket descriptor
struct addrinfo hints, *res;

memset(&hints, 0, sizeof(hints));
hints.ai_family = AF_UNSPEC;
hints.ai_socktype = SOCK_STREAM;

if (getaddrinfo("www.example.com", "http", &hints, &res) != 0)
{
    fprintf(stderr, "getaddrinfo error\n");
    exit(1);
}

if (connect(sockfd, res->ai_addr, res->ai_addrlen) == -1)
{
    perror("connect");
    exit(1);
}
```

**Описание**: `connect()` инициирует соединение на сокете.

#### recv()

```c
#include <sys/types.h>
#include <sys/socket.h>

ssize_t recv(int sockfd, void *buf, size_t len, int flags);
```

Пример использования:

```c
int sockfd; // Assume sockfd is a valid socket descriptor
char buf[100];
ssize_t bytes_received = recv(sockfd, buf, sizeof(buf), 0);
if (bytes_received == -1)
{
    perror("recv");
    exit(1);
}
else
{
    printf("Received %zd bytes\n", bytes_received);
}
```

**Описание**: `recv()` получает данные из сокета.

#### send()

```c
#include <sys/types.h>
#include <sys/socket.h>

ssize_t send(int sockfd, const void *buf, size_t len, int flags);
```

Пример использования:

```c
int sockfd; // Assume sockfd is a valid socket descriptor
char *msg = "Hello, World!";
ssize_t bytes_sent = send(sockfd, msg, strlen(msg), 0);
if (bytes_sent == -1)
{
    perror("send");
    exit(1);
}
else
{
    printf("Sent %zd bytes\n", bytes_sent);
}
```

**Описание**: `send()` отправляет данные в сокет.

#### close()

```c
#include <unistd.h>

int close(int fd);
```

Пример использования:

```c
close(sockfd);
```

**Описание**: `close()` закрывает дескриптор файла, так что он больше не ссылается ни на один файл и может быть повторно использован.

## Программирование моделей клиент-сервер

### Архитектура клиент-сервер

Архитектура клиент-сервер — это способ организации сетевых компьютеров, при котором один компьютер (клиент) запрашивает услуги или ресурсы у другого компьютера (сервера). Сервер предоставляет эти услуги или ресурсы клиенту.

### Простой HTTP-клиент

Вот наши цели:

- мы хотим написать программу, которая получает адрес веб-сайта (например, `httpstat.us`) в качестве аргумента и извлекает документ.
- программа выводит документ в stdout;
- программа использует TCP для подключения к HTTP-серверу.

Нажмите [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/00_tutorials/07_http_redirection.c), чтобы получить полный исходный код.

![HTTP Connection](https://raw.githubusercontent.com/nguyenchiemminhvu/LinuxNetworkProgramming/refs/heads/main/http_connection.png)

#### Включение необходимых заголовков

```c
#include <unistd.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
```

```unistd.h```: Предоставляет доступ к API операционной системы POSIX, включая дескрипторы файлов и функцию close().

```stdio.h```: Стандартная библиотека ввода-вывода для операций ввода-вывода (например, printf, fprintf).

```stdlib.h```: Стандартная библиотека для управления памятью (malloc, free) и управления процессами (exit).

```string.h```: Предоставляет функции для работы со строками, такие как memset, strlen и т.д.

```arpa/inet.h```: Функции для работы с IP-адресами, такие как ntohs и inet_ntoa.

```netdb.h```: Функции для работы с базами данных сети, такие как getaddrinfo, getprotobyname и getservbyname.

```sys/socket.h```: Определяет функции, связанные с сокетами, такие как socket, connect, send и recv.

#### Определение некоторых констант

```c
const char* CPP_HOSTNAME = "httpstat.us";
const int MESSAGE_SIZE = 1024;
```

```CPP_HOSTNAME```: Имя хоста удаленного сервера, к которому будет подключаться программа.

```MESSAGE_SIZE```: Размер буфера, используемого для отправки и получения данных (1 КБ в данном случае).

#### Определение вспомогательных функций

```c
void on_func_failure(const char* message)
{
    fprintf(stderr, "Error: %s\n", message);
    exit(EXIT_FAILURE);
}
```

Вспомогательная функция для обработки ошибок. Когда функция завершается неудачно, вызывается эта функция с сообщением об ошибке.

```fprintf(stderr, ...)```: Выводит сообщение об ошибке в стандартный вывод ошибок.

```exit(EXIT_FAILURE)```: Завершает программу с кодом ошибки.

#### Получение протокола TCP

```c
struct protoent* p_proto_ent = getprotobyname("tcp");
if (p_proto_ent == NULL)
{
    on_func_failure("TCP protocol is not available");
}
```

```getprotobyname("tcp")```: Извлекает запись протокола для "tcp" (Transmission Control Protocol). Функция возвращает структуру protoent, содержащую информацию о протоколе.

Если она возвращает NULL, программа завершается с использованием `on_func_failure`, потому что TCP необходим для подключения.

#### Получение порта службы HTTP

```c
servent* p_service_ent = getservbyname("http", p_proto_ent->p_name);
if (p_service_ent == NULL)
{
    on_func_failure("HTTP service is not available");
}
```

```getservbyname("http", p_proto_ent->p_name)```: Извлекает информацию о службе "http", включая номер порта (обычно 80 для HTTP).

Если getservbyname завершается неудачно, программа завершается. Эта функция гарантирует, что номер порта для HTTP доступен.

#### Преобразование номера порта в сетевой порядок байтов

```c
char port_buffer[6];
memset(port_buffer, 0, sizeof(port_buffer));
sprintf(port_buffer, "%d", ntohs(p_service_ent->s_port));
```

Преобразование порта: Номер порта из `getservbyname` находится в сетевом порядке байтов (big-endian). `ntohs` преобразует его в порядок байтов хоста (little-endian на большинстве систем).

```sprintf```: Преобразует номер порта в строку (хранится в port_buffer), которая требуется функции getaddrinfo.

#### Разрешение имени хоста

```c
struct addrinfo hints;
memset(&hints, 0, sizeof(hints));
hints.ai_family = AF_INET;
hints.ai_protocol = p_proto_ent->p_proto;
hints.ai_socktype = SOCK_STREAM;

struct addrinfo* server_addr;
int rc = getaddrinfo(CPP_HOSTNAME, port_buffer, &hints, &server_addr);
if (rc != 0)
{
    on_func_failure("Failed to resolve hostname");
}
```

```addrinfo```: Структура, которая содержит информацию для создания сокета.

```ai_family = AF_INET```: Указывает IPv4-адреса.

```ai_socktype = SOCK_STREAM```: Указывает TCP-соединение.

```ai_protocol = p_proto_ent->p_proto```: Гарантирует, что протокол — TCP.

```getaddrinfo```: Преобразует имя хоста (cppinstitute.org) и порт (80) в адрес, который можно использовать для подключения.

Если getaddrinfo завершается неудачно, программа завершается.

#### Создание сокета

```c
int sock_fd = socket(server_addr->ai_family, server_addr->ai_socktype, server_addr->ai_protocol);
if (sock_fd < 0)
{
    freeaddrinfo(server_addr);
    on_func_failure("socket() failed");
}
```

```socket()```: Создает новый сокет для связи.

Аргументы указывают семейство адресов, тип сокета и протокол (IPv4, TCP).

Если создание сокета завершается неудачно, программа завершается.

#### Подключение к HTTP-серверу

```c
rc = connect(sock_fd, server_addr->ai_addr, sizeof(struct sockaddr));
if (rc != 0)
{
    freeaddrinfo(server_addr);
    on_func_failure("connect() failed");
}
```

```connect()```: Инициирует соединение с удаленным сервером с использованием сокета.

Если connect завершается неудачно, программа очищает выделенные ресурсы и завершается.

#### Отправка HTTP-запроса

```c
char http_request[MESSAGE_SIZE];
memset(http_request, 0, MESSAGE_SIZE);
sprintf(http_request, "GET / HTTP/1.1\r\nHost: %s\r\nConnection: close\r\n\r\n", CPP_HOSTNAME);

int http_request_len = strlen(http_request);
int sent_bytes = 0;
while (sent_bytes < http_request_len)
{
    int sent_rc = send(sock_fd, http_request + sent_bytes, http_request_len - sent_bytes, 0);
    printf("sent %d bytes\n", sent_rc);
    sent_bytes += sent_rc;
}
```

Беседа с HTTP-сервером состоит из запросов (отправляемых клиентом) и ответов (отправляемых сервером).

Чтобы получить корневой документ с сайта с именем www.site.com, клиент должен отправить следующий запрос серверу:

```
GET / HTTP / 1.1 \ r \ n Host: www.site.com \ r \ n Connection:close \ r \ n \ r \ n
```

Запрос состоит из:

- строки, содержащей имя запроса (```GET```), за которым следует имя ресурса, который клиент хочет получить; корневой документ указывается как одиночный слэш (```/```); строка также должна включать версию протокола HTTP (```HTTP/1.1```), и должна заканчиваться символами ```\r\n```; обратите внимание, что все строки должны заканчиваться так же;
- строки, содержащей имя сайта (```www.site.com```), предшествуемое именем параметра (Host:)
- строки, содержащей параметр с именем Connection: вместе с его значением, close заставляет сервер закрыть соединение после обслуживания первого запроса; это упростит код клиента;
- пустой строки является завершающим символом запроса.

Если запрос правильный, ответ сервера начнется с аналогичного заголовка.

```
HTTP/1.1 200 OK
Content-Type: text/plain
Date: Thu, 05 Dec 2024 07:07:58 GMT
Server: Kestrel
Set-Cookie: ARRAffinity=b3b03edd65273a52d0e5a4a4995ddf09acfbb7f67adccaf277d300c0a375ea34;Path=/;HttpOnly;Domain=httpstat.us
Request-Context: appId=cid-v1:3548b0f5-7f75-492f-82bb-b6eb0e864e53
X-RBT-CLI: Name=LGEVN-Hanoi-ACC-5080M-A; Ver=9.14.2b;
Connection: close
Content-Length: 6

200 OK
```

#### Получение HTTP-ответа

```c
char http_response[MESSAGE_SIZE];
memset(http_response, 0, MESSAGE_SIZE);
int received_bytes = 0;
while (1 == 1)
{
    int received_rc = recv(sock_fd, http_response + received_bytes, MESSAGE_SIZE - received_bytes, 0);
    printf("Received %d bytes\n", received_rc);
    received_bytes += received_rc;
}
```

```recv()```: Получает ответ сервера фрагментами и добавляет его в буфер http_response.

Когда `recv()` возвращает 0 или отрицательное значение, это указывает на то, что сервер закрыл соединение или произошла ошибка.

#### Очистка

```c
close(sock_fd);
freeaddrinfo(server_addr);
```

```close()```: Закрывает сокет, освобождая системные ресурсы.

```freeaddrinfo()```: Освобождает память, выделенную getaddrinfo.

### Простой клиент-сервер на основе TCP

Нажмите [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/00_tutorials/08_simple_client_server.c), чтобы получить полный исходный код.

![TCP-Based Client-Server](https://raw.githubusercontent.com/nguyenchiemminhvu/LinuxNetworkProgramming/refs/heads/main/tcp_based_client_server.png)

#### Необходимые заголовки и макросы

```c
#include <unistd.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include <stdlib.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/socket.h>
#include <sys/stat.h>

#define PROTOCOL "tcp"
#define TCP_PORT 45123
#define MESSAGE_SIZE 1024
#define HOST_NAME "localhost"
```

**Заголовки:**

```unistd.h```: Предоставляет функции API POSIX, например, close.

```stdio.h```: Для операций ввода-вывода, например, printf, fprintf.

```time.h```: Для получения текущего времени с помощью time().

```string.h```: Для операций со строками, например, strcmp, memset.

```stdlib.h```: Для управления памятью и управления процессами.

```arpa/inet.h```: Для функций и структур данных, связанных с сокетами.

```netdb.h```: Для разрешения имен хостов с помощью getaddrinfo и gethostbyname.

```sys/socket.h```: Основные функции программирования сокетов, например, socket, connect, bind.

```sys/stat.h```: Для операций с файлами и каталогами.

**Макросы:**

```PROTOCOL```: Определяет протокол как tcp.

```TCP_PORT```: Порт, который сервер и клиент будут использовать для связи.

```MESSAGE_SIZE```: Максимальный размер сообщений, отправляемых/получаемых.

```HOST_NAME```: Имя хоста по умолчанию, установленное на localhost.

#### Вспомогательные функции

```c
void print_usage(const char *program_name)
{
    fprintf(stderr, "Usage: %s <client|server>\n", program_name);
}
```

Выводит руководство по использованию, показывая, как выполнить программу. Пример использования:

```./program_name client```

или

```./program_name server.```

```c
void report_error(const char* message)
{
    fprintf(stderr, "Error: %s\n", message);
}
```

Выводит сообщения об ошибках в stderr.

#### Настройка сервера

**Выбор протокола и разрешение адреса сервера**

```c
struct protoent* tcp_proto = getprotobyname(PROTOCOL);
```

Извлекает структуру протокола для протокола "tcp" с помощью `getprotobyname()`.

```c
char server_port[6];
memset(server_port, 0, 6);
sprintf(server_port, "%d", htons(TCP_PORT));

struct addrinfo addr_hints;
memset(&addr_hints, 0, sizeof(addr_hints));
addr_hints.ai_family = AF_INET;
addr_hints.ai_socktype = SOCK_STREAM;
addr_hints.ai_protocol = tcp_proto->p_proto;

struct addrinfo* addr_server;
rc = getaddrinfo(NULL, server_port, &addr_hints, &addr_server);
```

Преобразует порт TCP в сетевой порядок байтов с помощью `htons()`.

Инициализирует структуру addrinfo для указания параметров соединения:

- ```ai_family = AF_INET```: IPv4.
- ```ai_socktype = SOCK_STREAM```: Сокет TCP.

Разрешает адрес сервера с помощью `getaddrinfo()`.

**Создание серверного сокета**

```c
int sock_server = socket(addr_server->ai_family, addr_server->ai_socktype, addr_server->ai_protocol);
```

Создает сокет с помощью функции `socket()`.

```c
int sock_server_opt = 1;
rc = setsockopt(sock_server, SOL_SOCKET, SO_REUSEADDR | SO_KEEPALIVE, &sock_server_opt, sizeof(sock_server_opt));
```

Настраивает опции сокета:

```SO_REUSEADDR```: Позволяет серверу повторно использовать тот же порт.

```SO_KEEPALIVE```: Поддерживает соединение активным.

**Привязка сокета к адресу и начало прослушивания**

```c
for (addrinfo* p_server = addr_server; p_server != NULL; p_server = p_server->ai_next)
{
    rc = bind(sock_server, p_server->ai_addr, p_server->ai_addrlen);
    if (rc == 0)
    {
        break;
    }
}
```

Привязывает сокет к разрешенному адресу с помощью функции `bind()`.

Перебирает потенциальные адреса (список `addrinfo`) до успешного выполнения.

```c
rc = listen(sock_server, 3);
```

Начинает прослушивание входящих клиентских соединений с обратной связью 3.

**Цикл сервера — принятие входящих клиентских соединений**

```c
struct sockaddr addr_client;
socklen_t addr_len = sizeof(addr_client);
sock_client = accept(sock_server, (struct sockaddr*)&addr_client, &addr_len);
```

Принимает входящие клиентские соединения с помощью функции `accept()`.

**Цикл сервера — получение запросов**

```c
int received_bytes = recv(sock_client, request_buffer, MESSAGE_SIZE, 0);
```

Читает данные от клиента с помощью функции `recv()`.

**Цикл сервера — обработка запросов**

```c
if (strcmp(request_buffer, "exit") == 0
|| strcmp(request_buffer, "quit") == 0
|| strcmp(request_buffer, "shutdown") == 0)
{
    sprintf(response_buffer, "OK");
    rc = send(sock_client, response_buffer, MESSAGE_SIZE, 0);
    close(sock_client);
    break;
}
else if (strcmp(request_buffer, "time") == 0)
{
    sprintf(response_buffer, "%d", time(NULL));
    rc = send(sock_client, response_buffer, MESSAGE_SIZE, 0);
}
else
{
    sprintf(response_buffer, "Unknown request");
    rc = send(sock_client, response_buffer, MESSAGE_SIZE, 0);
}
```

Обрабатывает определенные команды:

```time```: Отправляет текущее время.

```exit, quit, shutdown```: Завершает соединение.

```Другие вводы```: Отвечает "Unknown request".

#### Настройка клиента

**Выбор протокола и разрешение адреса сервера**

```c
struct protoent* tcp_proto = getprotobyname(PROTOCOL);

struct addrinfo addr_hints;
memset(&addr_hints, 0, sizeof(addr_hints));
addr_hints.ai_family = AF_INET;
addr_hints.ai_socktype = SOCK_STREAM;
addr_hints.ai_protocol = tcp_proto->p_proto;

struct addrinfo* addr_server;
rc = getaddrinfo(HOST_NAME, server_port, &addr_hints, &addr_server);
```

Разрешает адрес сервера.

**Создание клиентского сокета и подключение к серверу**

```c
int sock_client = socket(addr_server->ai_family, addr_server->ai_socktype, addr_server->ai_protocol);

for (addrinfo* p_server = addr_server; p_server != NULL; p_server = p_server->ai_next)
{
    rc = connect(sock_client, p_server->ai_addr, p_server->ai_addrlen);
    if (rc == 0)
    {
        break;
    }
}
```

Создает сокет и подключается к серверу.

Перебирает потенциальные адреса (список `addrinfo`) до успешного выполнения.

**Цикл клиента — отправка запроса и ожидание ответа**

```c
fgets(request_buffer, MESSAGE_SIZE, stdin);
request_buffer[strcspn(request_buffer, "\n")] = 0;
send(sock_client, request_buffer, strlen(request_buffer), 0);
recv(sock_client, response_buffer, MESSAGE_SIZE, 0);
```

Отправляет ввод пользователя серверу и ждет ответа.

#### Основная функция

```c
if (strcmp(argv[1], "server") == 0)
{
    run_server();
}
else if (strcmp(argv[1], "client") == 0)
{
    run_client();
}
```

Определяет, будет ли программа работать как сервер или клиент на основе аргумента командной строки.

### Многопоточный клиент-сервер на основе TCP

Предоставленный пример программы на языке C — это простая реализация клиент-серверного приложения TCP, которая хорошо работает для базовых случаев использования. Однако у него есть несколько ограничений, особенно на стороне сервера: он может обрабатывать только одно клиентское соединение за раз. Пока он обрабатывает запрос от одного клиента, другие клиенты остаются в ожидании.

**Улучшение:**

Использование многопоточности для обработки нескольких клиентов одновременно. Каждое клиентское соединение может быть назначено отдельному потоку, что позволяет серверу обрабатывать несколько запросов одновременно.

Нажмите [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/00_tutorials/09_multithread_client_server.c), чтобы получить полный исходный код.

#### Настройка сервера с многопоточностью

Настройка серверного сокета и соединения такая же, как и раньше. Но в цикле сервера каждое клиентское соединение будет обрабатываться в отсоединенном потоке.

```c
int* p_sock_client = (int*)calloc(1, sizeof(int));
*p_sock_client = sock_client;
pthread_t client_thread;
rc = pthread_create(&client_thread, NULL, server_handle_client, p_sock_client);

rc = pthread_detach(client_thread);
```

**Код потока для клиента**

```c
void* server_handle_client(void* arg)
{
    int* sock_client = ((int*)arg);
    if (sock_client == NULL)
    {
        return NULL;
    }

    int rc;
    char request_buffer[MESSAGE_SIZE];
    char response_buffer[MESSAGE_SIZE];
    while (true)
    {
        memset(request_buffer, 0, MESSAGE_SIZE);
        memset(response_buffer, 0, MESSAGE_SIZE);

        int received_bytes = recv(*sock_client, request_buffer, MESSAGE_SIZE, 0);

        rc = send(*sock_client, response_buffer, MESSAGE_SIZE, 0);

        if (strcmp(request_buffer, "exit") == 0
        || strcmp(request_buffer, "quit") == 0
        || strcmp(request_buffer, "shutdown") == 0)
        {
            break;
        }
    }

    if (sock_client != NULL)
    {
        free(sock_client);
    }

    return NULL;
}
```

### Простой клиент-сервер на основе UDP

В целом, настройка клиент-серверного приложения на основе UDP аналогична приложению на основе TCP. Я покажу только отличающиеся части кода.

Нажмите [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/00_tutorials/10_peer_to_peer_client_server.c), чтобы получить полный исходный код.

![UDP-Based Client-Server](https://raw.githubusercontent.com/nguyenchiemminhvu/LinuxNetworkProgramming/refs/heads/main/udp_based_client_server.png)

#### Необходимые заголовки и макросы

```c
#define PROTOCOL "udp"
#define UDP_PORT 45123
#define MESSAGE_SIZE 1024
#define HOST_NAME "localhost"
```

Аналогично предыдущему объяснению, но теперь протокол — **UDP**.

#### Настройка сервера

**Разрешение адреса сервера**

```c
struct protoent* udp_protocol = getprotobyname(PROTOCOL);

struct addrinfo hints;
memset(&hints, 0, sizeof(hints));
hints.ai_family = AF_INET;
hints.ai_socktype = SOCK_DGRAM;
hints.ai_protocol = udp_protocol->p_proto;
struct addrinfo* addr_server;
rc = getaddrinfo(NULL, port_server, &hints, &addr_server); // INADDR_ANY
```

Указывает тип сокета datagram для UDP-соединения.

**Цикл сервера — прослушивание клиентских запросов и ответов**

```c
while (1)
{
    struct sockaddr addr_client;
    socklen_t addr_client_len = sizeof(struct sockaddr);
    int received_bytes = recvfrom(sock_server, request_buffer, MESSAGE_SIZE, 0, &addr_client, &addr_client_len);

    sprintf(response_buffer, "Server received request at %d", time(NULL));
    int response_buffer_len = strlen(response_buffer);
    rc = sendto(sock_server, response_buffer, response_buffer_len, 0, &addr_client, addr_client_len);
}
```

Функции `recvfrom()` и `sendto()` являются общей формой функций `recv()` и `send()`, они подходят для использования при передаче пакетов UDP.

#### Настройка клиента

```c
struct protoent* udp_protocol = getprotobyname(PROTOCOL);

struct addrinfo hints;
memset(&hints, 0, sizeof(hints));
hints.ai_family = AF_INET;
hints.ai_socktype = SOCK_DGRAM;
hints.ai_protocol = udp_protocol->p_proto;
struct addrinfo* addr_server;
rc = getaddrinfo(HOST_NAME, port_server, &hints, &addr_server);
```

Указывает тип сокета datagram для UDP-соединения.

**Цикл клиента — отправка запроса и ожидание ответа**

```c
char request_buffer[MESSAGE_SIZE];
char response_buffer[MESSAGE_SIZE];
while (1)
{
    printf("Enter command: ");
    fgets(request_buffer, MESSAGE_SIZE, stdin);
    request_buffer[strcspn(request_buffer, "\r\n")] = '\0';

    int request_buffer_len = strlen(request_buffer);
    rc = sendto(sock_client, request_buffer, request_buffer_len, 0, addr_server->ai_addr, addr_server->ai_addrlen);

    int received_bytes = recvfrom(sock_client, response_buffer, MESSAGE_SIZE, 0, addr_server->ai_addr, &addr_server->ai_addrlen);
}
```

### Передовые техники

#### Неблокирующие сокеты

Неблокирующие сокеты поддерживают создание отзывчивых приложений или обработку нескольких соединений без блокировки основного потока.

Код [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/00_tutorials/11_non_blocking_sockets.c) демонстрирует использование неблокирующих сокетов в простом TCP-приложении.

В этом примере функция `fcntl()` используется для установки серверных и клиентских сокетов в неблокирующий режим.

```c
#include <fcntl.h>

int fcntl(int fd, int cmd, ... /* arg */);
```

**Параметры:**

```fd```: Дескриптор файла, с которым нужно работать. Он должен быть уже открыт.

```cmd```: Команда для выполнения над дескриптором файла. Распространенные команды включают:

- ```F_DUPFD```: Дублировать дескриптор файла.
- ```F_GETFD```: Получить флаги дескриптора файла.
- ```F_SETFD```: Установить флаги дескриптора файла.
- ```F_GETFL```: Получить флаги состояния файла.
- ```F_SETFL```: Установить флаги состояния файла.
- ```F_SETLK```, ```F_SETLKW```, ```F_GETLK```: Управление блокировками файлов.

```arg (optional)```: Аргумент, значение и значение которого зависят от cmd. Обычно это целое число или указатель, в зависимости от команды.

**Вспомогательные функции**

```c
void set_non_blocking(int socket)
{
    int flags = fcntl(socket, F_GETFL, 0);
    if (flags == -1)
    {
        report_error("fcntl(F_GETFL) failed");
        return;
    }

    if (fcntl(socket, F_SETFL, flags | O_NONBLOCK) == -1)
    {
        report_error("fcntl(F_SETFL) failed");
    }
}
```

Вспомогательная функция `set_non_blocking()` используется для настройки дескриптора файла клиентских и серверных сокетов для работы в неблокирующем режиме.

**Инициализация и привязка сокета сервера**

```c
struct protoent* tcp_proto = getprotobyname(PROTOCOL);
int sock_server = socket(addr_server->ai_family, addr_server->ai_socktype, addr_server->ai_protocol);
set_non_blocking(sock_server);
```

Создает сокет TCP и устанавливает его в неблокирующий режим.

Использование `set_non_blocking()` гарантирует, что сервер не блокируется во время ожидания соединений.

**Принятие клиентского соединения**

```c
sock_client = accept(sock_server, &addr_client, &addr_client_len);
if (sock_client < 0)
{
    if (errno != EAGAIN && errno != EWOULDBLOCK)
    {
        report_error("Server accept() failed");
        break;
    }
    else
    {
        printf("No client connection\n");
    }
}
else
{
    set_non_blocking(sock_client);
}
```

Поскольку серверный сокет является неблокирующим, вызов `accept()` возвращается немедленно. Если соединение недоступно, errno устанавливается в `EAGAIN` или `EWOULDBLOCK`.

**Получение данных клиента**

```c
int received_bytes = recv(sock_client, buffer, MESSAGE_SIZE, 0);
if (received_bytes < 0)
{
    if (errno != EAGAIN && errno != EWOULDBLOCK)
    {
        report_error("Server recv() failed");
        break;
    }
}
```

Сокет клиентского соединения также установлен в неблокирующий режим, `recv()` не блокируется, когда данные недоступны. Если данные не получены, errno устанавливается в `EAGAIN` или `EWOULDBLOCK`.

#### Синхронное мультиплексирование ввода-вывода с select()

Применение неблокирующих дескрипторов файлов к сетевым сокетам позволяет серверу принимать несколько клиентских соединений одновременно без необходимости использования многопоточности.

Однако в предыдущем примере кода есть ограничение. Цикл сервера постоянно проверяет соединения и данные, что может привести к высокому использованию процессора.

Чтобы решить эту проблему, можно использовать механизм мультиплексирования ввода-вывода с помощью функции `select()`.

```c
#include <sys/select.h>
#include <sys/time.h>
#include <unistd.h>

int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
```

**Параметры:**

```nfds```: Указывает диапазон дескрипторов файлов, которые нужно проверить. Обычно устанавливается в наибольший дескриптор файла + 1.

```readfds```: Указатель на набор дескрипторов файлов для мониторинга на предмет готовности к чтению. Используйте `FD_SET()` для добавления дескрипторов и `FD_ISSET()` для их проверки.

```writefds```: Указатель на набор дескрипторов файлов для мониторинга на предмет готовности к записи.

```exceptfds```: Указатель на набор дескрипторов файлов для мониторинга исключительных состояний.

```timeout```: Указатель на структуру timeval, которая указывает максимальное время ожидания. Он может быть: ```NULL```: Ожидать бесконечно. ```Нулевой тайм-аут```: Неблокирующий режим, немедленно проверяет состояние. ```Конкретное значение```: Блокируется на указанное время.

**Возвращаемое значение:**

```> 0```: Количество дескрипторов файлов, готовых к вводу-выводу.

```0```: Тайм-аут истек, ни один дескриптор файла не готов.

```-1```: Произошла ошибка, и errno установлено соответствующим образом.

Функция `select()` в C используется для мониторинга нескольких дескрипторов файлов, чтобы узнать, готовы ли они к операциям ввода-вывода, таким как чтение, запись или наличие исключительных состояний. Она часто используется в сетевом программировании для управления несколькими сокетами без многопоточности.

```c
#include <sys/select.h>
#include <sys/time.h>
#include <unistd.h>

int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);
```

```nfds```: Наибольший номер дескриптора + 1.

```readfds```: Набор FD для проверки готовности к чтению.

```writefds```: Набор FD для проверки готовности к записи.

```exceptfds```: Набор FD для проверки исключительных состояний.

```timeout```: Максимальное время, в течение которого `select()` должен блокироваться, или ```NULL``` для бесконечной блокировки.

Полный пример кода с использованием мультиплексирования ввода-вывода с `select()` [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/00_tutorials/12_multiplexing_select_client_server.c).

**Инициализация fd_set**

```c
fd_set read_set;
fd_set master_set;
FD_ZERO(&master_set);
FD_SET(sock_server, &master_set);
global_max_fd = MAX(global_max_fd, sock_server);
```

```master_set``` отслеживает все дескрипторы файлов для мониторинга.

```read_set``` — это временная копия, используемая `select()` для определения, какие дескрипторы готовы к вводу-выводу.

Переменная ```global_max_fd``` обновляется до наибольшего значения дескриптора для использования в `select()`.

**Мультиплексирование ввода-вывода с select()**

```c
read_set = master_set;

int activity = select(global_max_fd + 1, &read_set, NULL, NULL, NULL);
if (activity < 0)
{
    report_error("Server select() failed");
}
```

`select()` мониторит дескрипторы файлов в read_set на предмет готовности к чтению. Он блокируется до тех пор, пока хотя бы один дескриптор не будет готов к чтению.

**Обработка готовых дескрипторов**

```c
for (int i = 0; i <= global_max_fd; i++)
{
    if (FD_ISSET(i, &read_set))
    {
        if (i == sock_server)
        {
            // Обработка новых входящих соединений
        }
        else
        {
            // Обработка ввода-вывода клиента
        }
    }
}
```

```FD_ISSET(i, &read_set)``` проверяет, готов ли дескриптор i к чтению.

Если ввод-вывод готов на серверном сокете, это означает, что есть новое соединение для принятия. В противном случае дескриптор соответствует клиентскому сокету, и данные можно читать из него.

**Принятие ввода-вывода сервера**

```c
struct sockaddr addr_client;
socklen_t addr_client_len = sizeof(struct sockaddr);
int sock_client = accept(sock_server, &addr_client, &addr_client_len);
FD_SET(sock_client, &master_set);
global_max_fd = MAX(global_max_fd, sock_client);
```

Добавляет новый клиентский сокет (sock_client) в `master_set` для мониторинга.

Обновляет ```global_max_fd```, если значение нового сокета больше.

**Обработка ввода-вывода клиента**

```c
int received_bytes = recv(i, request_buffer, MESSAGE_SIZE, 0);
if (received_bytes <= 0)
{
    // Клиент отключился или произошла ошибка
    close(i);
    FD_CLR(i, &master_set);
}
else
{
    // Обработка полученных данных и отправка ответа
    send(i, response_buffer, strlen(response_buffer), 0);
}
```

Если received_bytes <= 0, клиент либо отключился, либо произошла ошибка, затем удаляет сокет из `master_set`.

#### Синхронное мультиплексирование ввода-вывода с poll()

> ПРЕДУПРЕЖДЕНИЕ: select() может мониторить только номера дескрипторов файлов, которые меньше FD_SETSIZE (1024) — неразумно малое ограничение для многих современных приложений — и это ограничение не изменится. Все современные приложения должны вместо этого использовать poll(2) или epoll(7), которые не страдают этим ограничением.

Аналогично `select()`, функция `poll()` предоставляет способ мониторинга нескольких дескрипторов файлов для выполнения операций ввода-вывода. Однако `poll()` преодолевает некоторые ограничения `select()`, такие как фиксированный размер набора дескрипторов файлов.

С `poll()` сервер может эффективно обрабатывать несколько соединений без необходимости использования многопоточности, при этом решая проблему высокого использования процессора в цикле сервера.

```c
#include <poll.h>
#include <unistd.h>

int poll(struct pollfd *fds, nfds_t nfds, int timeout);
```

**Параметры:**

```fds```: Указатель на массив структур pollfd, представляющий дескрипторы файлов для мониторинга.

```nfds```: Количество дескрипторов файлов в массиве fds.

```timeout```: Указывает максимальное время ожидания (в миллисекундах). Он может быть: ```-1```: Ожидать бесконечно. ```0```: Возвращается немедленно (неблокирующий режим). ```Положительное значение```: Блокируется на указанное время.

**Возвращаемое значение:**

```> 0```: Количество дескрипторов файлов с событиями.

```0```: Тайм-аут истек, события не обнаружены.

```-1```: Произошла ошибка, и errno установлено соответствующим образом.

Функция `poll()` более масштабируема, чем `select()`, для мониторинга большого количества дескрипторов файлов. Она часто используется в сетевом программировании для управления несколькими соединениями, обеспечивая эффективное мультиплексирование ввода-вывода.

Полный пример кода мультиплексирования ввода-вывода с `poll()` [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/00_tutorials/13_multiplexing_poll_client_server.c).

**Инициализация массива pollfd**

```c
struct pollfd fds[MAX_CONNECTION];
memset(&fds, 0, sizeof(fds));
fds[0].fd = sock_server;    // Мониторинг серверного сокета
fds[0].events = POLLIN;     // Мониторинг входящих соединений
int nfds = 1;               // Начинаем с одного мониторингового сокета
```

Серверный сокет является первым элементом в массиве `pollfd`, который динамически обновляется по мере подключения или отключения клиентов.

**Цикл сервера с poll()**

```c
int activity = poll(fds, nfds, -1);  // Ожидать бесконечно
if (activity < 0)
{
    report_error("Server poll() failed");
    break;
}
```

Цикл постоянно отслеживает дескрипторы файлов и обрабатывает события по мере их возникновения.

**Обработка события готовности серверного сокета к чтению**

```c
if (fds[0].revents & POLLIN)
{
    struct sockaddr addr_client;
    socklen_t addr_client_len = sizeof(struct sockaddr);
    int sock_client = accept(fds[0].fd, &addr_client, &addr_client_len);
    if (nfds < MAX_CONNECTION)
    {
        fds[nfds].fd = sock_client;
        fds[nfds].events = POLLIN;  // Мониторинг входящих данных
        nfds++;
    }
}
```

Каждое новое соединение добавляется в массив `pollfd`, и общее количество мониторинговых дескрипторов (```nfds```) увеличивается.

**Обработка ввода-вывода клиента**

```c
for (int i = 1; i >= 1 && i < nfds; i++)
{
    if (fds[i].revents & POLLIN)
    {
        int received_bytes = recv(fds[i].fd, request_buffer, MESSAGE_SIZE, 0);
        if (received_bytes <= 0)
        {
            close(fds[i].fd);
            fds[i].fd = fds[nfds - 1].fd;  // Замена последним дескриптором
            nfds--;                        // Уменьшение общего количества
            i--;
        }
        else
        {
            sprintf(response_buffer, "Server time: %ld", time(NULL));
            send(fds[i].fd, response_buffer, strlen(response_buffer), 0);
        }
    }
}
```

Получает данные от клиента.

Отправляет ответ или отключается, если это необходимо.

Очищает массив `pollfd` после отключений, заменяя закрытый дескриптор последним дескриптором и уменьшая количество мониторинговых дескрипторов.

#### Трансляция сообщений

Трансляция — это метод в сетях, при котором сообщение отправляется от одного компьютера (называемого отправителем) всем компьютерам (называемым получателями) в той же сети. Это похоже на человека, кричащего сообщение в комнате, так что все в комнате слышат его (включая вас). Наиболее распространенный адрес для трансляции — ```255.255.255.255```.

Полный исходный код, демонстрирующий трансляцию сокетов, можно найти [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/00_tutorials/14_broadcasting.c).

**Настройка сокета получателя трансляции**

```c
int setup_broadcast_receiver(struct broadcast_t* receiver_info)
{
    int rc;

    receiver_info->fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (receiver_info->fd < 0)
    {
        report_error("socket() failed for receiver");
        return -1;
    }

    int optval = 1;
    rc = setsockopt(receiver_info->fd, SOL_SOCKET, SO_REUSEADDR, &optval, sizeof(optval));
    if (rc != 0)
    {
        report_error("setsockopt(SO_REUSEADDR) failed");
        return -1;
    }

    receiver_info->addr_receiver.sin_family = AF_INET;
    receiver_info->addr_receiver.sin_port = htons(BROADCAST_PORT);
    receiver_info->addr_receiver.sin_addr.s_addr = htonl(INADDR_ANY);
    receiver_info->addr_receiver_len = sizeof(receiver_info->addr_receiver);

    rc = bind(receiver_info->fd, (struct sockaddr *)&receiver_info->addr_receiver, receiver_info->addr_receiver_len);
    if (rc < 0)
    {
        report_error("bind() failed for receiver");
        return -1;
    }

    return 0;
}
```

```socket()```: Создает сокет UDP (```SOCK_DGRAM```) для связи.

```setsockopt()```: Настраивает сокет с опцией ```SO_REUSEADDR```, чтобы разрешить привязку сокета к адресу, который уже используется.

```bind()```: Привязывает сокет к конкретному порту (```BROADCAST_PORT```) на локальной машине. Он прослушивает сообщения, отправленные на этот порт.

Этот получатель настроен на получение транслируемых сообщений, отправленных на порт ```BROADCAST_PORT``` (определен как ```5555```).

**Настройка сокета отправителя трансляции**

```c
int setup_broadcast_sender(struct broadcast_t* sender_info)
{
    int rc;

    sender_info->fd = socket(AF_INET, SOCK_DGRAM, 0);
    if (sender_info->fd < 0)
    {
        report_error("socket() failed for sender");
        return -1;
    }

    int optval = 1;
    rc = setsockopt(sender_info->fd, SOL_SOCKET, SO_BROADCAST, &optval, sizeof(optval));
    if (rc != 0)
    {
        report_error("setsockopt(SO_BROADCAST) failed");
        return -1;
    }

    sender_info->addr_receiver.sin_family = AF_INET;
    sender_info->addr_receiver.sin_port = htons(BROADCAST_PORT);
    inet_pton(AF_INET, BROADCAST_ADDR, &sender_info->addr_receiver.sin_addr);
    sender_info->addr_receiver_len = sizeof(sender_info->addr_receiver);

    return 0;
}
```

```socket()```: Создает сокет UDP (```SOCK_DGRAM```) для трансляции.

```setsockopt()```: Настраивает сокет для разрешения трансляции с опцией ```SO_BROADCAST```.

```inet_pton()```: Преобразует адрес трансляции (```255.255.255.255```) из текстового формата в двоичный формат для использования в сокете.

Отправитель настроен на отправку транслируемых сообщений на указанный адрес и порт.

**Запуск потока получателя**

```c
void* broadcast_receiver_thread_func(void* arg)
{
    struct broadcast_t* broadcast_receiver_info = (struct broadcast_t*)calloc(1, sizeof(struct broadcast_t));
    if (setup_broadcast_receiver(broadcast_receiver_info) != 0)
    {
        report_error("setup_broadcast_receiver() failed");
        return NULL;
    }

    char buffer[MESSAGE_SIZE];

    printf("Start to listen broadcast messages\n");
    while (1)
    {
        memset(buffer, 0, MESSAGE_SIZE);
        int received_bytes = recvfrom(broadcast_receiver_info->fd, buffer, MESSAGE_SIZE, 0, (struct sockaddr*)&broadcast_receiver_info->addr_receiver, &broadcast_receiver_info->addr_receiver_len);
        if (received_bytes <= 0)
        {
            report_error("Broadcast receiver recvfrom() failed");
        }
        else
        {
            printf("Received broadcast message: %s\n", buffer);
        }
    }

    close(broadcast_receiver_info->fd);
    free(broadcast_receiver_info);

    return NULL;
}
```

Функция `broadcast_receiver_thread_func` работает в отдельном потоке.

Сначала она вызывает `setup_broadcast_receiver()` для настройки сокета получателя.

Затем она слушает входящие сообщения с помощью `recvfrom()`. Каждое полученное сообщение выводится на консоль.

Функция `recvfrom()` читает транслируемое сообщение в буфер и выводит его. Если нет данных или произошла ошибка, она сообщает о проблеме.

Поток получателя будет продолжать прослушивать до завершения программы.

**Запуск потока отправителя**

```c
void* broadcast_sender_thread_func(void* arg)
{
    char* nick_name = (char*)arg;

    struct broadcast_t* broadcast_sender_info = (struct broadcast_t*)calloc(1, sizeof(struct broadcast_t));
    if (setup_broadcast_sender(broadcast_sender_info) != 0)
    {
        report_error("setup_broadcast_sender() failed");
        return NULL;
    }

    char broadcast_message[MESSAGE_SIZE];
    while (1)
    {
        memset(broadcast_message, 0, MESSAGE_SIZE);
        sprintf(broadcast_message, "%s is active", nick_name);
        int sent_bytes = sendto(broadcast_sender_info->fd, broadcast_message, MESSAGE_SIZE, 0, (struct sockaddr*)&broadcast_sender_info->addr_receiver, broadcast_sender_info->addr_receiver_len);
        if (sent_bytes <= 0)
        {
            report_error("Send broadcast message failed");
        }
        sleep(1);
    }

    close(broadcast_sender_info->fd);
    free(broadcast_sender_info);

    return NULL;
}
```

Функция `broadcast_sender_thread_func` отвечает за отправку транслируемых сообщений на адрес трансляции (```255.255.255.255```).

Она настраивает сокет отправителя, вызывая `setup_broadcast_sender()`.

Внутри цикла она создает сообщение, содержащее имя пользователя, и отправляет его с помощью `sendto()` на адрес трансляции каждую секунду.

### Создание простого HTTP-сервера

![HTTP Server class diagram](https://raw.githubusercontent.com/nguyenchiemminhvu/LinuxNetworkProgramming/main/01_networking_libraries/my_http_server/http_server_design.png)

Полный исходный код моего простого HTTP-сервера находится [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/tree/main/01_networking_libraries/my_http_server).

Это простой `HTTP`-сервер, написанный на `C++` с использованием программирования сокетов Linux. Сервер предназначен для обработки базовых `HTTP`-запросов и ответов. Он прослушивает входящие соединения, обрабатывает запросы и отправляет соответствующие ответы.

#### Демонстрация

**Серверная сторона:**

```
ncmv@localhost:~/study_workspace/LinuxNetworkProgramming/01_networking_libraries/my_http_server/build$ cmake ..

ncmv@localhost:~/study_workspace/LinuxNetworkProgramming/01_networking_libraries/my_http_server/build$ make

ncmv@localhost:~/study_workspace/LinuxNetworkProgramming/01_networking_libraries/my_http_server/build$ ./HTTPServer 8080

[1734346074] [INFO] 127.0.0.1:8080
[1734346074] [INFO] Server starts new poll()
[1734346086] [INFO] A client is connected
[1734346086] [INFO] 127.0.0.1:48146
[1734346086] [INFO] A client is disconnected
[1734346086] [INFO] Server starts new poll()
```

**Клиентская сторона:**

```
ncmv@localhost:~/study_workspace/LinuxNetworkProgramming/01_networking_libraries/my_http_server/build$ curl -I http://localhost:8080

HTTP/1.1 200 OK
Content-Length:1544
Content-Length: 1544
```

```
ncmv@localhost:~/study_workspace/LinuxNetworkProgramming/01_networking_libraries/my_http_server/build$ curl http://localhost:8080

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Main Page</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            color: #333;
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            height: 100vh;
        }
        h1 {
            font-size: 2.5em;
            color: #333;
            margin-bottom: 20px;
        }
        ul {
            list-style-type: none;
            padding: 0;
        }
        li {
            margin: 10px 0;
        }
        a {
            text-decoration: none;
            font-size: 1.2em;
            color: #007bff;
            padding: 10px 15px;
            border: 1px solid #007bff;
            border-radius: 5px;
            transition: background-color 0.3s, color 0.3s;
        }
        a:hover {
            background-color: #007bff;
            color: white;
        }
    </style>
</head>
<body>
    <h1>Main Page</h1>
    <p>Select a folder to view its contents:</p>
    <ul>
        <li><a href="./200">200 - OK</a></li>
        <li><a href="./400">400 - Bad Request</a></li>
        <li><a href="./403">403 - Forbidden</a></li>
        <li><a href="./404">404 - Not Found</a></li>
        <li><a href="./500">500 - Internal Server Error</a></li>
    </ul>
</body>
</html>
```

## Сетевые библиотеки

### Использование libcurl

[libcurl](https://curl.se/libcurl/) — это мощная библиотека C, предназначенная для передачи данных по сети с использованием множества протоколов. Это библиотека, лежащая в основе популярного инструмента командной строки `curl`, которая предоставляет разработчикам программный способ отправлять и получать данные через `HTTP`, `HTTPS`, `FTP` и другие протоколы.

Использование libcurl идеально подходит для задач, связанных с извлечением веб-страниц, отправкой файлов на серверы, взаимодействием с `REST API` или отправкой электронных писем... Она экономит время и усилия, потому что вам не нужно иметь дело с программированием сокетов низкого уровня и разбором протоколов; вместо этого вы можете полагаться на libcurl для выполнения тяжелой работы (создание сетевых соединений, обработка запросов и управление потоками данных...).

### Примеры командной строки curl

Извлекает содержимое http://example.com и сохраняет его в файл с именем `temp.txt`.

```
curl http://example.com > temp.txt
```

----

Загружает содержимое http://example.com и сохраняет его как `index.html`.

```
curl http://example.com -o index.html
```

----

Загружает файл с именем `file.zip` с http://example.com.

```
curl -O http://example.com/file.zip
```

----

Отправляет `POST`-запрос на http://example.com с данными "name=ncmv".

```
curl -X POST -d "name=ncmv" http://example.com
```

----

Отправляет `POST`-запрос на http://example.com с данными `JSON` ({"name":"John","age":30}).

```
curl -X POST -H "Content-Type: application/json" -d '{"name":"John","age":30}' http://example.com
```

----

Извлекает только заголовки HTTP-ответа из http://example.com.

```
curl -I http://example.com
```

----

Доступ к http://example.com с использованием `HTTP` Basic Authentication с именем пользователя `username` и паролем `password`.

```
curl -u username:password http://example.com
```

----

Загружает файл `readme.txt` с `FTP`-сервера `test.rebex.net` с использованием имени пользователя `demo` и пароля `password`.

```
curl ftp://test.rebex.net/readme.txt --user demo:password
```

----

Загружает локальный файл temp на `FTP`-сервер `test.rebex.net` с использованием имени пользователя `demo` и пароля `password`.

```
curl -T temp ftp://test.rebex.net/ --user demo:password
```

----

Загружает локальный файл temp на `SFTP`-сервер на `localhost` в папку `/home/ncmv/study_workspace/` с использованием имени пользователя `demo` и пароля `password`.

```
curl -u demo:passowrd -T temp sftp://localhost/home/ncmv/study_workspace/
```

----

Загружает файл temp с `SFTP`-сервера `localhost` (в папке `/home/ncmv/study_workspace/`) с использованием имени пользователя `demo` и пароля `password`, и сохраняет его локально как `temp`.

```
curl -u demo:password sftp://localhost/home/ncmv/study_workspace/temp -O temp
```

### Базовый Curl
**Включение необходимых заголовков**
```c
#include <iostream>
#include <curl/curl.h>
```

**Функция обратного вызова для получения HTTP-ответа**
```c
size_t WriteCallback(void *contents, size_t size, size_t nmemb, void *userp)
{
    size_t total_size = size * nmemb;
    ((std::string*)userp)->append((char*)contents, total_size);
    return total_size;
}
```

Назначение: Эта функция обрабатывает данные, полученные от сервера во время HTTP-запроса.

Параметры:

- ```contents```: Указатель на полученные данные.
- ```size``` и ```nmemb```: Вместе указывают размер полученных данных (в байтах).
- ```userp```: Указатель, предоставленный пользователем для хранения полученных данных (в данном случае, объект `std::string`).

Что она делает:

- Вычисляет общий размер данных: ```size * nmemb```.
- Добавляет полученные данные (преобразованные в строку) в объект `std::string`, переданный в `userp`.
- Возвращает общий размер данных, чтобы сообщить libcurl, сколько данных было обработано.

**Проверка версии libcurl**

```c
curl_version_info_data* info = curl_version_info(CURLVERSION_NOW);
if (info)
{
    std::cout << "libcurl version: " << info->version << std::endl;
    std::cout << "SSL version: " << info->ssl_version << std::endl;
    std::cout << "Libz version: " << info->libz_version << std::endl;
    std::cout << "Features: " << info->features << std::endl;

    const char *const *protocols = info->protocols;
    if (protocols)
    {
        std::cout << "Supported protocols: ";
        for (int i = 0; protocols[i] != NULL; ++i)
        {
            std::cout << protocols[i] << " ";
        }
        std::cout << std::endl;
    }
}
```

Назначение: Отображает информацию о версии и функциях, поддерживаемых `libcurl`.

Как это работает:

- Вызывает `curl_version_info(CURLVERSION_NOW)`, чтобы получить информацию о текущей версии `libcurl`.
- Выводит версию, поддержку `SSL`, библиотеку сжатия (```Libz```) и поддерживаемые протоколы (```HTTP```, ```HTTPS```, ```FTP```, ...).

**Инициализация libcurl**

```c
CURL *curl;
CURLcode res;
std::string readBuffer;

curl = curl_easy_init();
```

Подробности:

- ```CURL *curl```: Дескриптор для управления HTTP-сессией.
- ```curl_easy_init()```: Инициализирует дескриптор. Если успешно, curl не будет равен NULL.

**Установка опций libcurl**

```c
curl_easy_setopt(curl, CURLOPT_URL, "http://httpstat.us/200");
curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
```

Назначение: Настраивает опции для HTTP-запроса.

Опции:

- ```CURLOPT_URL```: Устанавливает URL для запроса.
- ```CURLOPT_WRITEFUNCTION```: Указывает функцию обратного вызова (```WriteCallback```), которая будет обрабатывать данные ответа.
- ```CURLOPT_WRITEDATA```: Предоставляет объект `std::string` (```readBuffer```), в который будут сохранены данные ответа.

**Выполнение HTTP-запроса**

```c
res = curl_easy_perform(curl);
```

```curl_easy_perform(curl)```: Выполняет HTTP-запрос с установленными ранее опциями.

**Очистка**

```c
curl_easy_cleanup(curl);
```

Освобождает ресурсы, используемые `curl`. Всегда вызывайте это после завершения работы с `curl`.

**Результат**:

```
ncmv@localhost:~/study_workspace/LinuxNetworkProgramming/01_networking_libraries/libcurl/build$ ./basic_curl

libcurl version: 8.5.0
SSL version: OpenSSL/3.0.13
Libz version: 1.3
Features: 1438599069
Supported protocols: dict file ftp ftps gopher gophers http https imap imaps ldap ldaps mqtt pop3 pop3s rtmp rtmpe rtmps rtmpt rtmpte rtmpts rtsp scp sftp smb smbs smtp smtps telnet tftp

Response data: 200 OK
```

Полный пример базового curl [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/01_networking_libraries/libcurl/src/basic_curl.cpp).

### Curl Multiple Handles

**Включение необходимых заголовков**

```c
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <curl/curl.h>
```

**Определение структуры Easy Handle**

```c
struct CurlEasyHandle
{
    CURL* easy_handle;
    std::string url;
    std::string data;
};
```

Назначение: Хранит информацию для каждого HTTP-запроса.

- ```CURL* easy_handle```: Дескриптор для выполнения одного HTTP-запроса.
- ```std::string url```: URL для извлечения.
- ```std::string data```: Хранит данные HTTP-ответа.

**Функция обратного вызова для получения HTTP-ответа**

```c
std::size_t perform_callback(char* ptr, std::size_t size, std::size_t nmemb, void* userdata)
{
    std::string* str = static_cast<std::string*>(userdata);
    std::size_t total_size = size * nmemb;
    str->append(ptr, total_size);
    return total_size;
}
```

Назначение: Обрабатывает данные, полученные от сервера.

Как это работает:

- Вычисляет общий размер полученных данных: ```size * nmemb```.
- Добавляет эти данные в объект `std::string`, на который указывает `userdata`.
- Возвращает общий размер обработанных данных, чтобы сообщить `libcurl`, что данные были обработаны.

**Функция обратного вызова для отслеживания прогресса загрузки**

```c
int perform_progress(void* ptr, double download_size, double downloaded, double upload_size, double uploaded)
{
    CurlEasyHandle* progData = (CurlEasyHandle*)ptr;
    std::cout << "Downloaded " << progData->url << ": " << downloaded << " bytes" << std::endl;

    return 0;
}
```

Назначение: Отслеживает прогресс загрузки для каждого URL.

Как это работает:

- Выводит количество загруженных байтов для URL.
- Возвращение ```0``` сигнализирует `libcurl` продолжить загрузку.
- Возврат ненулевого значения остановит загрузку.

**Определение списка URL**

```c
const std::vector<std::string> urls = {
    "http://www.example.com",
    "http://www.google.com",
    "http://www.bing.com",
    "http://www.speedtest.net",
};
```

**Инициализация libcurl**

```c
CURLM* curl_multi;
int running_status;

curl_global_init(CURL_GLOBAL_DEFAULT);
curl_multi = curl_multi_init();
```

Назначение: Подготавливает `libcurl` для работы с несколькими дескрипторами.

Подробности:

- ```curl_global_init()```: Инициализирует глобальные ресурсы для `libcurl`.
- ```curl_multi_init()```: Создает многозадачный дескриптор для управления несколькими одновременными HTTP-запросами.

**Создание Easy Handles и добавление их в Multi Handle**

```c
std::vector<CurlEasyHandle> easy_handles(urls.size());
for (int i = 0; i < urls.size(); i++)
{
    easy_handles[i].easy_handle = curl_easy_init();
    easy_handles[i].url = urls[i];

    curl_easy_setopt(easy_handles[i].easy_handle, CURLOPT_URL, urls[i].c_str());
    curl_easy_setopt(easy_handles[i].easy_handle, CURLOPT_WRITEFUNCTION, perform_callback);
    curl_easy_setopt(easy_handles[i].easy_handle, CURLOPT_WRITEDATA, &easy_handles[i].data);
    curl_easy_setopt(easy_handles[i].easy_handle, CURLOPT_NOPROGRESS, 0L);
    curl_easy_setopt(easy_handles[i].easy_handle, CURLOPT_PROGRESSFUNCTION, perform_progress);
    curl_easy_setopt(easy_handles[i].easy_handle, CURLOPT_PROGRESSDATA, &easy_handles[i]);

    curl_multi_add_handle(curl_multi, easy_handles[i].easy_handle);
}
```

Назначение: Создает и настраивает дескриптор easy handle для каждого URL, затем добавляет его в многозадачный дескриптор.

Шаги:

- Инициализирует новый easy handle с помощью `curl_easy_init()`.
- Настраивает каждый дескриптор с:
  - URL для извлечения (```CURLOPT_URL```).
  - Функцией обратного вызова для обработки данных ответа (```CURLOPT_WRITEFUNCTION```).
  - Указателем на хранилище данных (```CURLOPT_WRITEDATA```).
  - Опциями отслеживания прогресса (```CURLOPT_NOPROGRESS```, ```CURLOPT_PROGRESSFUNCTION```, ```CURLOPT_PROGRESSDATA```).
- Добавляет easy handle в многозадачный дескриптор с помощью `curl_multi_add_handle()`.

**Выполнение запроса Multi Handle**

```c
curl_multi_perform(curl_multi, &running_status);

do
{
    int curl_multi_fds;
    CURLMcode rc = curl_multi_perform(curl_multi, &running_status);
    if (rc == CURLM_OK)
    {
        rc = curl_multi_wait(curl_multi, nullptr, 0, 1000, &curl_multi_fds);
    }

    if (rc != CURLM_OK)
    {
        std::cerr << "curl_multi failed, code " << rc << std::endl;
        break;
    }
} while (running_status);
```

Назначение: Выполняет все HTTP-запросы одновременно.

Как это работает:

- Запускает HTTP-запросы с помощью `curl_multi_perform()`.
- Постоянно вызывает `curl_multi_perform()` в цикле до завершения всех запросов (running_status становится 0).
- Использует `curl_multi_wait()` для ожидания событий (доступность данных) вместо активного ожидания.

**Сохранение данных и очистка**

```c
for (CurlEasyHandle& handle : easy_handles)
{
    std::string filename = handle.url.substr(11, handle.url.find_last_of(".") - handle.url.find_first_of(".") - 1) + ".html";
    std::ofstream file(filename);
    if (file.is_open())
    {
        file << handle.data;
        file.close();
        std::cout << "Data written to " << filename << std::endl;
    }

    curl_multi_remove_handle(curl_multi, handle.easy_handle);
    curl_easy_cleanup(handle.easy_handle);
}

curl_multi_cleanup(curl_multi);
curl_global_cleanup();
```

Назначение: Сохраняет данные ответа в файлы, затем очищает ресурсы.

Шаги:

- Для каждого дескриптора:
  - Создает имя файла на основе URL.
  - Сохраняет данные ответа в файл.
  - Удаляет дескриптор из многозадачного дескриптора (```curl_multi_remove_handle()```).
- Очищает дескриптор (```curl_easy_cleanup()```).
- Очищает многозадачный дескриптор (```curl_multi_cleanup()```) и глобальные ресурсы (```curl_global_cleanup()```).

**Результат**:

```
ncmv@localhost:~/study_workspace/LinuxNetworkProgramming/01_networking_libraries/libcurl/build$ ./curl_multi_handle

...
Downloaded http://www.speedtest.net: 167 bytes
...
Downloaded http://www.bing.com: 53057 bytes
...
Downloaded http://www.google.com: 57709 bytes
...
Downloaded http://www.example.com: 1256 bytes
...
Data written to example.html
Data written to google.html
Data written to bing.html
Data written to speedtest.html
```

Полный пример нескольких дескрипторов curl [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/01_networking_libraries/libcurl/src/curl_multi_handle.cpp).

### Curl Multithreading

**Включение необходимых заголовков**

```c
#include <iostream>
#include <thread>
#include <vector>
#include <fstream>
#include <curl/curl.h>
```

**Определение структур**

```c
struct ProgressData
{
    std::string url;
    double lastProgress;
};
```

Назначение: Хранит информацию о прогрессе для каждой загрузки.

Члены:

- ```std::string url```: URL, который загружается.
- ```double lastProgress```: Последний зарегистрированный прогресс (в байтах) для этого URL.

**Функция обратного вызова для получения HTTP-ответа**

```c
std::size_t perform_callback(char* ptr, std::size_t size, std::size_t nmemb, void* userdata)
{
    std::string* str = static_cast<std::string*>(userdata);
    std::size_t total_size = size * nmemb;
    str->append(ptr, total_size);
    return total_size;
}
```

Назначение: Обрабатывает данные, полученные от сервера во время HTTP-запроса.

Подробности:

- Добавляет полученные данные (преобразованные в строку) в объект `std::string`, переданный в `userdata`.
- Возвращает общий размер данных, чтобы подтвердить успешную обработку.

**Функция обратного вызова для отслеживания прогресса загрузки**

```c
int perform_progress(void* ptr, double download_size, double downloaded, double upload_size, double uploaded)
{
    ProgressData* progData = (ProgressData*)ptr;

    if (downloaded - progData->lastProgress >= 1024.0)
    {
        std::cout << "Download " << progData->url << ": " << downloaded << " bytes" << std::endl;
        progData->lastProgress = downloaded;
    }

    return 0;
}
```

Назначение: Отслеживает и отображает прогресс загрузки для конкретного URL.

Подробности:

- Проверяет, загружено ли не менее 1 КБ (1024 байта) новых данных с момента последнего обновления.
- Выводит прогресс и обновляет `lastProgress`.

**Функция для выполнения HTTP-запроса**

```c
void perform_request(const std::string& url)
{
    CURL* curl;
    CURLcode res;

    curl = curl_easy_init();
    if (curl != nullptr)
    {
        std::string data;
        ProgressData progData;
        progData.url = url;
        progData.lastProgress = 0.0;

        curl_easy_setopt(curl, CURLOPT_URL, url.c_str());
        curl_easy_setopt(curl, CURLOPT_FOLLOWLOCATION, 1L);
        curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, perform_callback);
        curl_easy_setopt(curl, CURLOPT_WRITEDATA, &data);
        curl_easy_setopt(curl, CURLOPT_NOPROGRESS, 0L);
        curl_easy_setopt(curl, CURLOPT_PROGRESSFUNCTION, perform_progress);
        curl_easy_setopt(curl, CURLOPT_PROGRESSDATA, &progData);

        res = curl_easy_perform(curl);
        if (res == CURLE_OK)
        {
            std::string filename = url.substr(11, url.find_last_of(".") - url.find_first_of(".") - 1) + ".html";
            std::ofstream file(filename);
            if (file.is_open())
            {
                file << data;
                file.close();
                std::cout << "Data written to " << filename << std::endl;
            }
        }
    }
}
```

Назначение: Выполняет HTTP-запрос для загрузки содержимого указанного URL.

Шаги:

- Инициализирует дескриптор easy handle.
- Настраивает опции:
  - URL для запроса (```CURLOPT_URL```).
  - Следование перенаправлениям (```CURLOPT_FOLLOWLOCATION```).
  - Функция обратного вызова для обработки данных ответа (```CURLOPT_WRITEFUNCTION```).
  - Указатель на хранилище данных (```CURLOPT_WRITEDATA```).
  - Опции отслеживания прогресса (```CURLOPT_NOPROGRESS```, ```CURLOPT_PROGRESSFUNCTION```, ```CURLOPT_PROGRESSDATA```).
- Выполняет запрос с помощью `curl_easy_perform()`.

При успешном выполнении:

- Сохраняет загруженные данные в файл с именем, основанным на URL.

**Настройка многопоточного выполнения HTTP**

```c
curl_global_init(CURL_GLOBAL_ALL);

std::vector<std::thread> threads;
std::vector<std::string> urls = {
    "http://www.example.com",
    "http://www.google.com",
    "http://www.bing.com",
    "http://www.speedtest.net",
};

for (const std::string& url : urls)
{
    threads.push_back(std::thread(perform_request, url));
}

for (std::thread& t : threads)
{
    t.join();
}

curl_global_cleanup();
```

Подробности:

- ```curl_global_init(CURL_GLOBAL_ALL)```: Подготавливает `libcurl` для многопоточной работы.
- Создает вектор для хранения объектов потоков и вектор URL-адресов.
- Для каждого URL создает новый поток для выполнения `perform_request()`.
- Гарантирует, что все потоки завершатся перед выходом из программы, используя `join()`.
- ```curl_global_cleanup()```: Освобождает ресурсы, выделенные `libcurl`.

Полный пример базового многопоточного curl [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/01_networking_libraries/libcurl/src/curl_multithreaded.cpp).

## Безопасное сетевое взаимодействие с OpenSSL

`SSL` (Secure Sockets Layer) — это криптографический протокол, первоначально разработанный для обеспечения безопасной связи по сети, например, через интернет. Он гарантирует, что передаваемые данные между клиентом (например, веб-браузером) и сервером (например, веб-сайтом) зашифрованы, аутентифицированы и защищены от изменений.

Современные системы используют `TLS` (Transport Layer Security), который является обновленной и более безопасной версией `SSL`. Когда люди говорят `SSL`, они часто имеют в виду `SSL/TLS`.

Один из хорошо известных примеров применения протокола `SSL/TLS` — это протокол HTTPs. Метод шифрования TLS используется для обеспечения безопасности взаимодействия в интернете, такого как просмотр веб-страниц, отправка форм, онлайн-платежи...

**SSL Handshake:**

- Клиент (например, браузер) подключается к серверу и говорит: "Я хочу использовать SSL/TLS."
- Сервер отправляет обратно свой сертификат, который содержит его удостоверение личности и открытый ключ.
- Клиент проверяет подлинность сертификата сервера.
- Клиент и сервер согласовывают общий "сеансовый ключ" для шифрования данных в течение сеанса.

![How HTTPs work](https://raw.githubusercontent.com/nguyenchiemminhvu/LinuxNetworkProgramming/refs/heads/main/how_https_work.png)

Для работы с протоколом `SSL/TLS` в программировании библиотека `OpenSSL` является типичным выбором.

**Установка**

```
sudo apt-get install libssl-dev openssl
```

```libssl-dev```: Содержит библиотеки разработки для `OpenSSL`, которые необходимы для компиляции программ с использованием `OpenSSL`.

```openssl```: Устанавливает команду `openssl`, которую можно использовать для генерации ключей и сертификатов или для устранения неполадок с `SSL/TLS`.

**Инициализация OpenSSL**

```c
#include <openssl/ssl.h>
#include <openssl/err.h>

SSL_library_init();
SSL_load_error_strings();
OpenSSL_add_all_algorithms();
```

Эти шаги гарантируют, что `OpenSSL` готов к обработке криптографии и предоставлению понятных сообщений об ошибках в случае сбоя.

**Создание контекста SSL**

```c
SSL_CTX *ctx = SSL_CTX_new(TLS_server_method());  // Для сервера

SSL_CTX *ctx = SSL_CTX_new(TLS_client_method());  // Для клиента
```

```TLS_server_method()```: Настраивает контекст для работы в режиме сервера.

```TLS_client_method()```: Настраивает контекст для работы в режиме клиента.

Структура `SSL_CTX` содержит параметры протокола, сертификаты и другие необходимые настройки.

**Загрузка сертификатов (только для сервера)**

```c
SSL_CTX_use_certificate_file(ctx, "server.crt", SSL_FILETYPE_PEM);

SSL_CTX_use_PrivateKey_file(ctx, "server.key", SSL_FILETYPE_PEM);
```

```server.crt```: Файл сертификата сервера (подтверждает личность сервера для клиента).

```server.key```: Файл закрытого ключа, связанный с сертификатом.

Этот шаг гарантирует, что сервер может предоставить аутентификацию во время `SSL/TLS` handshake.

**Создание и привязка сокета**

Настройте стандартный сокет TCP, как для обычного сетевого программирования.

**Обертка сокета с SSL**

```c
SSL *ssl = SSL_new(ctx);
SSL_set_fd(ssl, socket_fd);
```

Объект `SSL` управляет шифрованием и дешифрованием для соединения сокета.

**Выполнение handshake**

```c
SSL_accept(ssl); // Для сервера

SSL_connect(ssl); // Для клиента
```

`SSL/TLS` handshake аутентифицирует сервер (и, возможно, клиента) и устанавливает зашифрованный канал связи.

```SSL_accept()```: Сервер ожидает, пока клиент не инициирует handshake.

```SSL_connect()```: Клиент инициирует handshake с сервером.

**Отправка и получение зашифрованных данных**

После handshake соединение SSL готово к отправке и получению зашифрованных данных.

```c
SSL_write(ssl, "Hello, Secure World!", strlen("Hello, Secure World!"));
char buffer[1024];

SSL_read(ssl, buffer, sizeof(buffer));
```

**Очистка**

```c
SSL_shutdown(ssl);
SSL_free(ssl);
SSL_CTX_free(ctx);
```

С этими шагами достаточно, чтобы установить безопасное соединение между клиентом и сервером с использованием протокола `SSL/TLS` с библиотекой `OpenSSL`.

### HTTPS-клиент

Полный пример HTTPS-клиента находится [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/01_networking_libraries/openssl/src/https_client.c).

**Результат**:

```
ncmv@localhost:~/study_workspace/LinuxNetworkProgramming/01_networking_libraries/openssl/build$ ./https_client example.com 443

93.184.215.14:443
SSL connection is done with cipher suite TLS_AES_256_GCM_SHA384

Received 361 bytes
Received 1256 bytes
HTTP/1.1 200 OK
Age: 140532
Cache-Control: max-age=604800
Content-Type: text/html; charset=UTF-8
Date: Sat, 14 Dec 2024 09:44:47 GMT
Etag: "3147526947+gzip+ident"
Expires: Sat, 21 Dec 2024 09:44:47 GMT
Last-Modified: Thu, 17 Oct 2019 07:18:26 GMT
Server: ECAcc (sed/58B0)
Vary: Accept-Encoding
X-Cache: HIT
Content-Length: 1256
Connection: close

(Остальное — это HTTP-содержимое сайта example.com)
```

### Безопасный клиент-сервер

| Поток работы сервера SSL             | Поток работы клиента SSL             |
|----------------------------------|----------------------------------|
| ![SSL Server Workflow](https://raw.githubusercontent.com/nguyenchiemminhvu/LinuxNetworkProgramming/refs/heads/main/SSL_server_workflow.png) | ![SSL Client Workflow](https://raw.githubusercontent.com/nguyenchiemminhvu/LinuxNetworkProgramming/refs/heads/main/SSL_client_workflow.png) |

Полный пример клиент-сервера SSL находится [ЗДЕСЬ](https://github.com/nguyenchiemminhvu/LinuxNetworkProgramming/blob/main/01_networking_libraries/openssl/src/ssl_client_server.c).

# Заключение

**Ссылка:**

https://www.linuxhowtos.org/C_C++/socket.htm

https://www.tutorialspoint.com/unix_sockets/index.htm

https://documentation.softwareag.com/adabas/wcp632mfr/wtc/wtc_prot.htm

https://www.geeksforgeeks.org/little-and-big-endian-mystery/

https://github.com/openssl/openssl/tree/691064c47fd6a7d11189df00a0d1b94d8051cbe0/demos/ssl