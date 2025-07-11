**ACID** — это набор свойств, гарантирующих надежность транзакций в системах управления базами данных (СУБД). Аббревиатура расшифровывается следующим образом:
### 🔹 **A — Atomicity (Атомарность)**
Транзакция должна быть **выполнена полностью или не выполнена вовсе**.  
Если какая-либо часть транзакции не удалась, вся транзакция откатывается.
🧠 Пример: перевод денег с одного счёта на другой. Если деньги списались с одного счёта, но не зачислились на другой, всё отменяется.
### 🔹 **C — Consistency (Согласованность)**
Транзакция должна **переводить базу данных из одного корректного состояния в другое**.  
Все бизнес-правила и ограничения (например, целостность данных, внешние ключи) должны сохраняться.
🧠 Пример: если при переводе денег баланс стал отрицательным, это нарушает правило — значит, такая транзакция невозможна.
### 🔹 **I — Isolation (Изолированность)**
Промежуточные состояния транзакции **не видны другим транзакциям**.  
Одновременное выполнение нескольких транзакций не должно влиять на результат выполнения каждой из них.
🧠 Пример: два клиента одновременно бронируют один и тот же билет — только один должен успеть.
### 🔹 **D — Durability (Надежность/Долговечность)**
После завершения транзакции (commit) **изменения сохраняются навсегда**, даже если произойдёт сбой (например, отключение питания).
🧠 Пример: если деньги переведены и транзакция завершена, они не исчезнут после перезагрузки сервера.
