##### Короткая версия
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh`  # устновка
echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc  # автодополнение
uv python list  # список доступных версия python
uv python install 3.12.3  # устновка python
uv init  # инициализация проекта
uv add requests  # установка пакета
uv run main.py  # запуск скрипта
uv tree  # дерево зависимостей
```

**- установка**
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh`
echo 'eval "$(uv generate-shell-completion zsh)"' >> ~/.zshrc # Автодополнение
```

**- список доступных версий python**
```bash
uv python list

'
cpython-3.14.0a6+freethreaded-linux-x86_64-gnu    <download available>
cpython-3.14.0a6-linux-x86_64-gnu                 <download available>
cpython-3.13.2+freethreaded-linux-x86_64-gnu      <download available>
cpython-3.12.9-linux-x86_64-gnu                   <download available>
cpython-3.12.3-linux-x86_64-gnu                   /usr/bin/python3.12
...
'
```

**- установка python**
```bash
uv python install 3.12.3
```

**- определяем версию python для проекта**
```bash
uv python pin 3.12.3
```
в проекте появится файл `.python-version`
```bash
3.13.2
```

**- инициализация проекта**
```bash
uv init
```

**- добавление пакета**
```bash
uv add requests
```

**- запуск**
```bash
uv run main.py
```

**- дерево зависимостей**
```bash
uv tree
```

**- определение версии python и его зависимостей в самом файле**
В данном случае нам не нужно определять среду и версию python
```python
# /// script
# requires-python = ">=3.13"
# dependencies = [
#   "natsort",
#   "tabulate"
# ]
# ///

print("Hello world")
```

```bash
uv run main.py
```
