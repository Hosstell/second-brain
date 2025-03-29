## Определение асинхронной функции
```python
import asyncio

async def delay(secs: int) -> int:
    print(f"Засыпаю на {secs} c.")
    **await** asyncio.sleep(secs)
    print(f"Сон в течение {secs} c. закончился")
    return secs
```
## Как запустить асинхронную функцию(сопрограмму)?
### **await**
Чтобы запустить асинхронную функцию и ожидать ее результат, мы должны использовать оператор **await**. Но есть проблема. Оператор **await** мы можем использовать только в **асинхронных** функциях. От куда ушли, туда и пришли.  

```python
import asyncio

async def delay(secs: int) -> int:
    print(f"Засыпаю на {secs} c.")
    await asyncio.sleep(secs)
    print(f"Сон в течение {secs} c. закончился")
    return delay_seconds

await delay(2)

"""
   await delay(2)
       ^
SyntaxError: 'await' outside function
"""
```
### **asyncio.run**
Функция **asyncio.run** запускает сопрограмму и возвращает результат.

```python
import asyncio

async def delay(secs: int) -> int:
    print(f"Засыпаю на {secs} c.")
    await asyncio.sleep(secs)
    print(f"Сон в течение {secs} c. закончился")
    return secs

 print(asyncio.run(delay(2)))  # 2
```

В идеале, функция asyncio.run должна вызываться в программе только один раз и использоваться как основная точка входа. Эту функцию нельзя вызвать, когда в том же потоке запущен другой цикл событий.

### **asyncio.create_task**

Еще один вариант запуска сопрограммы - это создание задачи (task). Обернуть сопрограмму в задачу и запланировать ее выполнение можно с помощью функции asyncio.create_task. Она возвращает объект Task, который можно ожидать с await, как и сопрограммы.

Функция asyncio.create_task позволяет запускать сопрограммы одновременно, так как создание задачи означает для цикла, что надо запустить эту сопрограмму при первой возможности.

```python
import asyncio
from datetime import datetime

async def delay_print(delay, task_name):
    print(f'>>> start {task_name}. {datetime.now()}')
    await asyncio.sleep(delay)
    print(f'<<< end   {task_name}. {datetime.now()}')
    return task_name

async def main():
    delay_2 = asyncio.create_task(delay_print(2, "delay2"))
    delay_4 = asyncio.create_task(delay_print(4, "delay4"))

    print(await delay_2)
    print(await delay_4)

print(asyncio.run(main()))

"""
>>> start delay2. 2023-06-03 11:36:00.986024
>>> start delay4. 2023-06-03 11:36:00.986024
<<< end   delay2. 2023-06-03 11:36:02.999364
delay2
<<< end   delay4. 2023-06-03 11:36:04.989116
delay4
None
"""
```

## Создание задачи

```python
import asyncio

async def main():
    wait_3_secs = asyncio.**create_task**(delay(3))
		await wait_3_secs

main()
```

## Cтатус задачи

```python
wait_3_secs = asyncio.create_task(delay(3))
await asyncio.sleep(1)
print(wait_3_secs.**done**())  # True or False
```

## Снятие задачи

```python
wait_3_secs = asyncio.create_task(delay(3))
await asyncio.sleep(1)
wait_3_secs.**cancel**()

print(wait_3_secs.**cancelled**())  # False. 
# Чтобы задача прекратила свою работу, к ней должно вернуться управление(контроль). 
await asyncio.sleep(1) # Возвращаем управление(контроль) для задачи wait_3_secs
print(wait_3_secs.**cancelled**())  # True

await wait_3_secs  # **asyncio.exceptions.CancelError**
```

## Timeout на выполнение задач

```python
wait_3_secs = asyncio.create_task(delay(3))

try:
		await asyncio.**wait_for**(wait_3_secs, timeout=1)
except **asyncio.exceptions.TimeoutError**:
		pass

****print(wait_3_secs.cancelled())  # **True**
```

## Защита задачи от снятия по timeout

```python
wait_3_secs = asyncio.create_task(delay(3))

try:
		await asyncio.wait_for(asyncio.**shield**(wait_3_secs), timeout=1)
except asyncio.exceptions.TimeoutError:
		pass

****print(wait_3_secs.cancelled()) # **False** 
await wait_3_secs
```

## Работа с сокетами

```python
import asyncio
import socket

"""
Пример программы для работы с сокетами.
Эхо сервер. Подлючаемся через 'telnet localhost 8000'
Отрпавляем запрос, получаем ответ

loop = asyncio.**get_event_loop**() - возвращает объект для работы с сокетами.
loop.**sock_accept**(server_socket) - ждет подключение. или точней 
события записи в сокет server_socket
loop.**sock_recv**(connection, 1024) - ждем полученения данных

Сокет это место, куда кладутся данные, но не сам сервер.
"""

async def listen_for_connections(server_socket, loop):
    while True:
        connection, address = await loop.**sock_accept**(server_socket)
        connection.setblocking(False)
        print(f"Получен запрос на подключение от {address}")
        asyncio.create_task(echo(connection, loop))

async def echo(connection, loop):
    while data := await loop.**sock_recv**(connection, 1024):
        await loop.sock_sendall(connection, data)

async def main():
    server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    address = ("127.0.0.1", 8000)
    server_socket.bind(address)
    server_socket.listen()
    server_socket.setblocking(False)

    await listen_for_connections(server_socket, asyncio.**get_event_loop**())

asyncio.run(main())
```

## Перехват сигнала `signal.SIGINT`

`signal.SIGINT` - Сигнал, котораый вызывается при нажатие **CTRL + C.**

Перехватываем этот сигнал, и пытаемся выключить все запущенные таски

PS. Код работает только на системы UNIX

```python
import asyncio
import signal

from utils import delay

def cancel_tasks():
    print("Получен сигнал SIGINT")
    tasks = asyncio.all_tasks()
    [task.cancel() for task in tasks]

async def main():
    loop = asyncio.get_running_loop()
    **loop.add_signal_handler(signal.SIGINT, cancel_tasks)**
    await delay(10)

asyncio.run(main())

"""
Засыпаю на 10 c.
^CПолучен сигнал SIGINT
Traceback (most recent call last):
  File "main.py", line 18, in <module>
    asyncio.run(main())
  File "/usr/lib/python3.8/asyncio/runners.py", line 44, in run
    return loop.run_until_complete(main)
  File "/usr/lib/python3.8/asyncio/base_events.py", line 616, in run_until_complete
    return future.result()
asyncio.exceptions.CancelledError
"""
```

## AIOHTTP

Для асинхронных запросов не подойдет модуль **requests.** Он не явялется асинхронным.

### Запрос

Объект **session** может сохранять cookies и все остальное между запросами 

```python
import asyncio
import aiohttp

async def fetch_status(session: ClientSession, url: str) -> int:
    async with session.get(url) as result:
        return result.status

async def main():
    async with aiohttp.ClientSession() as session:
        url = 'https://www.example.com'
        status = await fetch_status(session, url)
        print(f'Состояние для {url} было равно {status}')

asyncio.run(main())
```

## Одновременный запуск нескольких задач

### Функция asyncio.gather

```python
import asyncio

from utils import delay

async def main():
    delay_task_1 = asyncio.create_task(delay(2))
    delay_task_2 = asyncio.create_task(delay(4))
    results = await **asyncio.gather**(delay_task_1, delay_task_2, delay(3))
    print(results)

asyncio.run(main())
```

В функцию можно передавать не только задачи, но и сопрограммы. Сопрограммы оборачиваются в задачу.

В случае ошибки в одной из задач, **asyncio.gather** вернут эту ошибку.

Если нам нужно вернуть ошибку в списке результатов от другиз задач, используем параметр **return_exception=True**

```python
import asyncio

from utils import delay

async def delay_with_error(sec):
    raise Exception()

async def main():
    delay_task_1 = asyncio.create_task(delay(2))
    delay_task_2 = asyncio.create_task(delay(4))
    results = await asyncio.gather(
        delay_task_1, delay_task_2, delay_with_error(3),
        **return_exceptions=True**
    ) 
    print(results) # [2, 4, Exception()]

asyncio.run(main())
```

### Обработка результатов по мере поступления

Метод **as_completed** принимает список допускающих ожидание объектов и  возвращает итератор по будущим объектам. Эти объекты можно перебирать, применяя к каждому await. Когда выражение await вернет управление, мы получим результат первой завершившейся сопрограммы. Это значит, что мы сможем обрабатывать результаты по мере их доступности, но теперь порядок результатов не детерминирован, поскольку неизвестно, какой объект завершится первым.

```python
import asyncio
import aiohttp
from aiohttp import ClientSession
from util import async_timed
from chapter_04 import fetch_status

async def fetch_status(session: ClientSession, url: str, delay: int = 0) -> int:
		await asyncio.sleep(delay)
		async with session.get(url) as result:
				return result.status

async def main():
		async with aiohttp.ClientSession() as session:
				fetchers = [
						fetch_status(session, 'https://www.example.com', 1),
						fetch_status(session, 'https://www.example.com', 1),
						fetch_status(session, 'https://www.example.com', 10)
				]
				for finished_task in **asyncio.as_completed(fetchers)**:
						print(await finished_task)

asyncio.run(main())
```

У функции **as_completed** есть параметр **timeout.** Принимает секунды. Если задача не выпониться за это время - **TimeoutError.**

## Точный контроль с помощью wait

Базовая сигнатура wait  – список допускающих ожидание объектов, за которым следует факультативный тайм-аут и факультативный параметр return_when, который может принимать значения **ALL_COMPLETED**, **FIRST_EXCEPTION** и **FIRST_COMPLETED**, а по умолчанию равен **ALL_COMPLETED**

```python
import asyncio
import aiohttp
from aiohttp import ClientSession
from util import async_timed
from chapter_04 import fetch_status

async def main():
		async with aiohttp.ClientSession() as session:
		fetchers = [
				asyncio.create_task(fetch_status(session, 'https://example.com')),
				asyncio.create_task(fetch_status(session, 'https://example.com'))
		]
		done, pending = await asyncio.**wait**(fetchers)

		print(f'Число завершившихся задач: {len(done)}')
		print(f'Число ожидающих задач: {len(pending)}')

		for done_task in done:
				result = await done_task
				print(result)

asyncio.run(main())

"""
В данном случае мы задали режим ALL_COMPLETED, 
поэтому множество pending будет пустым, так как 
asyncio.wait не вернется, пока все не завершится.
"""
```

### Обработка исключений при использовании wait

```python
async def main():
		async with aiohttp.ClientSession() as session:
				good_request = fetch_status(session, 'https://www.example.com')
				bad_request = fetch_status(session, 'python://bad')
				fetchers = [
						asyncio.create_task(good_request),
						asyncio.create_task(bad_request)
				]
				done, pending = await asyncio.wait(fetchers)
				
				print(f'Число завершившихся задач: {len(done)}')
				print(f'Число ожидающих задач: {len(pending)}')
				
				**for done_task in done:
						# result = await done_task возбудит исключение
						if done_task.exception() is None:
								print(done_task.result())
						else:
								logging.error(
										"При выполнении запроса возникло исключение",
										exc_info=done_task.exception()
								)**
```

### Обработка всех результатов по мере поступления

```python
async def main():
		async with aiohttp.ClientSession() as session:
				url = 'https://www.example.com'
				pending = [
						asyncio.create_task(fetch_status(session, url)),
						asyncio.create_task(fetch_status(session, url)),
						asyncio.create_task(fetch_status(session, url))
				]

				while pending:
					done, pending = await asyncio.wait(pending, return_when=asyncio.FIRST_COMPLETED)
					
					print(f'Число завершившихся задач: {len(done)}')
					print(f'Число ожидающих задач: {len(pending)}')
					
					for done_task in done:
							print(await done_task)
```

# ASYNCPG. Создание пулы подключений

```python
import asyncio
import asyncpg

product_query = \
    """
    SELECT
    p.product_id,
    p.product_name,
    p.brand_id,
    s.sku_id,
    pc.product_color_name,
    ps.product_size_name
    FROM product as p
    JOIN sku as s on s.product_id = p.product_id
    JOIN product_color as pc on pc.product_color_id = s.product_color_id
    JOIN product_size as ps on ps.product_size_id = s.product_size_id
"""

async def query_product(pool):
    async with **pool.acquire()** as connection:
        return await connection.fetchrow(product_query)

async def main():
    async with asyncpg.create_pool(host='127.0.0.1',
                                   port=5432,
                                   user='postgres',
                                   password='mysecretpassword',
                                   database='products',
                                   min_size=6,
                                   max_size=6) as **pool**:
        results = await asyncio.gather(
            query_product(pool),
            query_product(pool)
        )
        print(results)

asyncio.run(main())
```

- **pool.acquire()** приостанавливается, до тех пор пока не освободится подключение.
- Параметр **min_size** определяет минимальное число подключений, т. е. гарантируется, что столько подключений в пуле всегда будет.
- Параметр **max_size** определяет максимальное число подключений. Если подключений недостаточно, то пул попытается создать еще одно при условии, что число подключений не превысит max_size.

## Транзакция

```python
async with **connection.transaction()**:
		await connection.execute("INSERT INTO brand VALUES(DEFAULT, 'brand_1')")
		await connection.execute("INSERT INTO brand VALUES(DEFAULT, 'brand_2')")
```

## Курсоры

```python
query = 'SELECT product_id, product_name FROM product'
async with **connection.transaction()**:
    **async for** product in connection.**cursor**(query):
        print(product)
```

Для примера выполним запрос, который получает на курсоре все товары, имеющиеся в базе
данных. И будем выбирать элементы из результирующего набора **по одному** в цикле async for. 

Здесь распечатываются все имеющиеся товары. Хотя в таблице хранится 1000 товаров, в память загружается лишь небольшая порция. Объем предвыборки по умолчанию был равен 50 записей. 

То есть, если в таблице 1000 записей, то этот код сделает 20 запросов (1000/50 = 20) к бд.

# Счетные задачи

## Запуск новых процессов

```python
import time
**from multiprocessing import Process**

def count(count_to: int) -> int:
    start = time.time()
    counter = 0
    while counter < count_to:
        counter = counter + 1
    end = time.time()
    print(f'Закончен подсчет до {count_to} за время {end-start}')
    return counter

if __name__ == "__main__":
    start_time = time.time()
    to_one_hundred_million = **Process**(target=count, args=(100000000,))
    to_two_hundred_million = **Process**(target=count, args=(200000000,))

    to_one_hundred_million.start()
    to_two_hundred_million.start()
    to_one_hundred_million.join()
    to_two_hundred_million.join()
    end_time = time.time()
    print(f'Полное время работы {end_time-start_time}')
```

## concurrent.futures

В пакете есть функции: **ProcessPoolExecutor** и **ThreadPoolExecutor**.
**ThreadPoolExecutor** - запускает функцию в отдельном потоке
**ProcessPoolExecutor** - запускает функцию в отдельном процессе 

```python
import time
f**rom concurrent.futures import ProcessPoolExecutor**

def count(count_to: int) -> int:
    start = time.time()
    counter = 0
    while counter < count_to:
        counter = counter + 1
    end = time.time()
    print(f'Закончен подсчет до {count_to} за время {end - start}')
    return counter

if __name__ == "__main__":
    with **ProcessPoolExecutor()** as process_pool:
        numbers = [1, 3, 5, 100000000, 50000000]
        for result in **process_pool.map(count, numbers)**:
            print(result)

"""
Закончен подсчет до 1 за время 0.0
Закончен подсчет до 3 за время 0.0
Закончен подсчет до 5 за время 0.0
1
3
5
Закончен подсчет до 50000000 за время 3.4276492595672607
Закончен подсчет до 100000000 за время 6.280510425567627
100000000
50000000
"""
```

Функция **ProcessPoolExecutor** создает пул процессов(по умолчанию их количество - количество доступных ядер). Метод **map** запускает функции в доступых процессах, но возвращает данные по тому порядку, который указан в параметрах. То есть програма не выведет результат **50000000** пока не закончится процесс с **100000000**, даже есть процесс с **50000000** будет закончен раньше.

## Asyncio + **ProcessPoolExecutor.**

### **Возврат ответа по мере выполнения**

Чтобы воспользоваться функционалом asyncio при работе с процессами, можно воспользоваться методом **run_in_executor**. 

P.S. Функция принимает только фукцию без параметров, поэтому мы воспользовались функцией **partial** из functools, которая реализует замыкание

```python
import asyncio
from asyncio.events import AbstractEventLoop
from concurrent.futures import ProcessPoolExecutor
from functools import partial
from typing import List

def count(count_to: int) -> int:
    counter = 0
    while counter < count_to:
        counter = counter + 1
    return counter

async def main():
    with ProcessPoolExecutor() as process_pool:
        loop: AbstractEventLoop = asyncio.get_running_loop()
        nums = [1, 3, 5, 22, 100000000, 50000000]
        **calls: List[partial[int]] = [partial(count, num) for num in nums]**

        call_coros = []
        for call in calls:
            call_coros.append(**loop.run_in_executor**(process_pool, call))

        results = asyncio.as_completed(call_coros)
        for result in results:
            print(await result)

if __name__ == "__main__":
    asyncio.run(main())

"""
1
3
5
22
50000000
100000000
"""
```

## MapReduce

В модели программирования MapReduce большой набор данных сначала разбивается на меньшие части. Затем мы можем решить задачу для поднабора данных, а не для всего набора – это называется отображением (mapping), поскольку мы «отображаем» данные на частичный результат. После того как задачи для всех поднаборов решены, мы можем объединить результаты в окончательный ответ. Этот шаг называется редукцией (reducing), потому что «редуцируем» (сводим) несколько ответов в один. Подсчет частоты вхождения слов в большой набор текстовых данных – каноническая задача MapReduce.

Для удобнства работы в библиотеке **functools** реализован нужный функционал

## Разделение памяти между процессами

```python
from multiprocessing import Process, Value, Array

def increment_value(shared_int: Value):
		shared_int.value = shared_int.value + 1

def increment_array(shared_array: Array):
		for index, integer in enumerate(shared_array):
				shared_array[index] = integer + 1

if __name__ == '__main__':
	**integer = Value('i', 0)
	integer_array = Array('i', [0, 0])**
	procs = [
			Process(target=increment_value, args=(integer,)),
			Process(target=increment_array, args=(integer_array,))
	]
	[p.start() for p in procs]
	[p.join() for p in procs]
	print(integer.value)
	print(integer_array[:])
```

Между процессами мы можем разделить только числа(**Value**) и массивы(**Array**). Изменение переменной, которая создана через эти конструкции, будет меняться в остальных процессах

### Избавление состояния гонки. Мютексы.

```python
from multiprocessing import Process, Value

def increment_value(shared_int: Value):
		**shared_int.get_lock().acquire()**  # Блокируем переменную
		shared_int.value = shared_int.value + 1
		**shared_int.get_lock().release()**  # Отпускаем переменную

"""
Или можно заменить на котекстный менеджер
**def increment_value(shared_int: Value):
		with shared_int.get_lock():
				shared_int.value = shared_int.value + 1**
"""

if __name__ == '__main__':
	for _ in range(100):
		integer = Value('i', 0)
		procs = [
				Process(target=increment_value, args=(integer,)),
				Process(target=increment_value, args=(integer,))
		]
		[p.start() for p in procs]
		[p.join() for p in procs]
		print(integer.value)
		**assert (integer.value == 2)  # Эта ошибка никогда не произойдет**
```

## Многопоточность в многопроцессорности

ДЗ: Реализовать многопоточное выполнение запросов к бд в многопроцессорном режиме

## Избавление состояния гонки в многопоточности

```python
import functools
import requests
import asyncio
from concurrent.futures import ThreadPoolExecutor
from threading import Lock
from utils import async_timed

**counter_lock = Lock()**
counter: int = 0

def get_status_code(url: str) -> int:
    global counter
    response = requests.get(url)
    **with counter_lock:
        counter = counter + 1**
    return response.status_code

async def reporter(request_count: int):
    while counter < request_count:
        print(f'Завершено запросов: {counter}/{request_count}')
        await asyncio.sleep(.5)

@async_timed()
async def main():
    loop = asyncio.get_running_loop()
    with ThreadPoolExecutor() as pool:
        request_count = 200
        urls = ['https://www.example.com' for _ in range(request_count)]
        reporter_task = asyncio.create_task(reporter(request_count))
        tasks = [
            loop.run_in_executor(pool,functools.partial(get_status_code, url))
            for url in urls
        ]
        results = await asyncio.gather(*tasks)
        await reporter_task

    print(results)

asyncio.run(main())
```

# Aiohttp

### Первый сервер

```python
from aiohttp import web
from datetime import datetime
from aiohttp.web_request import Request
from aiohttp.web_response import Response

routes = web.RouteTableDef()

@routes.get('/time')
async def time(request: Request) -> Response:
		today = datetime.today()
		result = {
			'month': today.month,
			'day': today.day,
			'time': str(today.time())
		}
		return web.json_response(result)

app = web.Application()
app.add_routes(routes)
web.run_app(app)
```

### Разделение данных между ручками

Создание пула подключений для бд. Объект [**request.app](http://request.app)** выступает общим между всеми запросами и ручками.

```python
import asyncpg
from aiohttp import web
from aiohttp.web_app import Application
from aiohttp.web_request import Request
from aiohttp.web_response import Response
from asyncpg import Record
from asyncpg.pool import Pool
from typing import List, Dict

routes = web.RouteTableDef()
DB_KEY = 'database'

async def create_database_pool(app: Application):
		print('Создается пул подключений.')
		pool: Pool = await asyncpg.create_pool(
				host='127.0.0.1',
				port=5432,
				user='postgres',
				password='password',
				database='products',
				min_size=6,
				max_size=6
		)
		**app[DB_KEY] = pool**

async def destroy_database_pool(app: Application):
		print('Уничтожается пул подключений.')
		pool: Pool = app[DB_KEY]
		await pool.close()

@routes.get('/brands')
async def brands(request: Request) -> Response:
		**# Объект app глобальный и к нему можно обратиться через request.app
		connection: Pool = request.app[DB_KEY]**
		brand_query = 'SELECT brand_id, brand_name FROM brand'
		results: List[Record] = await connection.fetch(brand_query)
		result_as_dict: List[Dict] = [dict(brand) for brand in results]
		return web.json_response(result_as_dict)

app = web.Application()
**""" Добавить сопрограммы создания и уничтожения пула в обработчики инициализации и очистки """
app.on_startup.append(create_database_pool)
app.on_cleanup.append(destroy_database_pool)**
app.add_routes(routes)
web.run_app(app)
```

# Микросервисы

## Паттерн backend-for-frontend

Его идея в том, что UI не взаимодействует с сервисами напрямую, а создает новый сервис, который отправляет вызовы и агрегирует результаты. Это решает наши проблемы, потому что вместо нескольких запросов мы отправляем только один, что уменьшает количество обращений к интернету.

![Untitled](Личное/Развитие%20a656b3834cb54c55b16399c3637e6a5b/Книги%20c1178ae87f5347d5bc9dd089c2f833c9/Asyncio%20и%20конкурентное%20программирование%20на%20python%208e5bb5605323401aaef30e5e53ca99fc/Untitled.png)

## Паттерн Прерыватель

У паттерна Прерыватель есть два состояния: разомкнут и замкнут. В замкнутом состоянии все хорошо: мы отправляем запрос сервису, и тот успешно возвращает ответ. Разомкнутое состояние имеет место, когда цепь аварийно отключилась. В этом состоянии можно даже не трудиться вызывать сервис, потому что это заведомо не приведет к успеху, и мы вместо этого сразу возвращаем ошибку.

![Untitled](Личное/Развитие%20a656b3834cb54c55b16399c3637e6a5b/Книги%20c1178ae87f5347d5bc9dd089c2f833c9/Asyncio%20и%20конкурентное%20программирование%20на%20python%208e5bb5605323401aaef30e5e53ca99fc/Untitled%201.png)

## Разница **Lock() из thearding и asyncio**

Lock из threading МОЖНО определять глобально и использовать в потеке.
см. в п. **Избавление состояния гонки в многопоточности**

Lock из asyncio НЕЛЬЗЯ определять как глобальную переменную. Ее нужно создавать в цикле и прокидывать в задачи.

```python
import asyncio
from asyncio import Lock
from util import delay

async def a(lock: Lock):
		print('Сопрограмма a ждет возможности захватить блокировку')
		async with lock:
				print('Сопрограмма a находится в критической секции')
				await delay(2)
		print('Сопрограмма a освободила блокировку')

async def b(lock: Lock):
		print('Сопрограмма b ждет возможности захватить блокировку')
		async with lock:
				print('Сопрограмма b находится в критической секции')
				await delay(2)
		print('Сопрограмма b освободила блокировку')

async def main():
		**lock = Lock()**
		await asyncio.gather(a(lock), b(lock))

asyncio.run(main())
```

## Семафоры

Семафор похож на блокировку в том смысле, что его можно захватывать и освобождать, а основное отличие заключается в том, что захватить семафор можно не один раз, а несколько, – максимальное число задаем мы сами. Под капотом семафор следит за этим пределом; при каждом захвате предел уменьшается, а при каждом освобождении увеличивается. Как только счетчик обращается в нуль, дальнейшие попытки захватить семафор блокируются, пока кто-то не выполнит операцию освобождения, которая увеличит счетчик. Можно считать, что блокировка – частный случай семафора с пределом 1.

```python
import asyncio
from asyncio import Semaphore

async def operation(semaphore: Semaphore):
		print('Жду возможности захватить семафор...')
		async with semaphore:
				print('Семафор захвачен!')
				await asyncio.sleep(2)
		print('Семафор освобожден!')

async def main():
		semaphore = Semaphore(2)
		await asyncio.gather(*[operation(semaphore) for _ in range(4)])

asyncio.run(main())
```

## Уведомление задач с помощью событий

```python
import asyncio
import functools
from asyncio import Event

def trigger_event(event: Event):
		print('Активируется событие!')
		event.set() # Запуск события

async def do_work_on_event(event: Event):
		print('Ожидаю события...')
		await event.wait()  # Ждать событие
		print('Работаю!')
		await asyncio.sleep(1) # Когда событие произойдет, блокировка снимается, и мы можем начать работу
		print('Работа закончена!')
		event.clear()

async def main():
		event = asyncio.Event()
		# Активировать событие через 5 с
		asyncio.get_running_loop().call_later(5.0, functools.partial(trigger_event, event))
		await asyncio.gather(do_work_on_event(event), do_work_on_event(event))

asyncio.run(main())

"""
Ожидаю события...
Ожидаю события...
Активируется событие!
Работаю!
Работаю!
Работа закончена!
Работа закончена!
"""
```

## Очереди

```python
import asyncio
import random
import time

async def worker(name, queue):
    while True:
        # Get a "work item" out of the queue.
        sleep_for = await queue.get()

        # Sleep for the "sleep_for" seconds.
        await asyncio.sleep(sleep_for)

        # Notify the queue that the "work item" has been processed.
        queue.task_done()

        print(f'{name} has slept for {sleep_for:.2f} seconds')

async def main():
    # Create a queue that we will use to store our "workload".
    queue = asyncio.Queue()

    # Generate random timings and put them into the queue.
    for _ in range(20):
        sleep_for = random.uniform(0.05, 1.0)
        queue.put_nowait(sleep_for)

    # Create three worker tasks to process the queue concurrently.
    tasks = []
    for i in range(3):
        task = asyncio.create_task(worker(f'worker-{i}', queue))
        tasks.append(task)
		
	  # Wait until the queue is fully processed
		await queue.join()
		await asyncio.gather(*tasks, return_exceptions=True)
		# OR
		# await asyncio.gather(queue.join(), *tasks, return_exceptions=True)

asyncio.run(main())

"""
Асинхронное получения данынх - await queue.get()
Синхронное получение данных - queue.get_nowait()
Асинхроное добавление данных - await queue.put(...)
Синхронное добвление данных - queue.put_nowait(...)
"""
```

### Очередь с приоритетом

```python
import asyncio
from asyncio import Queue, PriorityQueue
from dataclasses import dataclass, field

@dataclass(order=True)
class WorkItem:
		priority: int
		order: int
		data: str = field(compare=False)

priority_queue = **PriorityQueue()**
work_items = [
		WorkItem(3, 1, 'Lowest priority'),
		WorkItem(3, 2, 'Lowest priority second'),
		WorkItem(3, 3, 'Lowest priority third'),
		WorkItem(2, 4, 'Medium priority'),
		WorkItem(1, 5, 'High priority')
]

while not priority_queue.empty():
		work_item: WorkItem = await priority_queue.get()
		print(work_item)
		queue.task_done()

"""
WorkItem(priority=1, order=5, data='High priority')
WorkItem(priority=2, order=4, data='Medium priority')
WorkItem(priority=3, order=1, data='Lowest priority')
WorkItem(priority=3, order=2, data='Lowest priority second')
WorkItem(priority=3, order=3, data='Lowest priority third')
"""
```

### Очередь FILO

```python
import asyncio
from asyncio import Queue, LifoQueue
from dataclasses import dataclass, field

@dataclass(order=True)
class WorkItem:
		priority: int
		order: int
		data: str = field(compare=False)

lifo_queue = **LifoQueue()**
work_items = [
		WorkItem(3, 1, 'Lowest priority'),
		WorkItem(3, 2, 'Lowest priority second'),
		WorkItem(3, 3, 'Lowest priority third'),
		WorkItem(2, 4, 'Medium priority'),
		WorkItem(1, 5, 'High priority')
]

while not lifo_queue.empty():
		work_item: WorkItem = await lifo_queue.get()
		print(work_item)
		queue.task_done()

"""
WorkItem(priority=1, order=5, data='High priority')
WorkItem(priority=2, order=4, data='Medium priority')
WorkItem(priority=3, order=3, data='Lowest priority third')
WorkItem(priority=3, order=2, data='Lowest priority second')
WorkItem(priority=3, order=1, data='Lowest priority first')
"""
```

# Работа с консольными программами

```python
user_input = ''
while user_input != 'quit':
		user_input = input('Введите текст: ')
		print(user_input)
```

```python
import asyncio
from asyncio import StreamWriter, StreamReader
from asyncio.subprocess import Process

async def consume_and_send(text_list, stdout: StreamReader, stdin: StreamWriter):
		for text in text_list:
				line = await **stdout.read(2048)**
				print(line)
				**stdin.write(text.encode())**
				await stdin.drain()

async def main():
		program = ['python3', 'listing_13_11.py']
		process: Process = await asyncio.create_subprocess_exec(
				*program,
				stdout=asyncio.subprocess.PIPE,
				stdin=asyncio.subprocess.PIPE
		)
		text_input = ['one\n', 'two\n', 'three\n', 'four\n', 'quit\n']
		await asyncio.gather(
				consume_and_send(text_input, process.stdout, process.stdin), 
				process.wait()
		)

asyncio.run(main())
```