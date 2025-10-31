#### UTF-X
UTF-8 - Может хранить символы в 1 байт, 2 байта, 3 байта или 4 байт
UTF-16 - 2 или 4 байта
UTF-32 - только 4 байта на символ

#### len(string) возвращает количество байт, а не длину строки
```go
package main

import "fmt"

func main() {
	a := "Hello"
	b := "Привет"
	
	fmt.Println(len(a), len(b))
	fmt.Println([]byte(a), []byte(b))
}
```