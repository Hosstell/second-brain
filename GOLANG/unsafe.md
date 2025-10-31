```go
package main

import (
	"fmt"
	"unsafe"
)

  

func main() {
var x int8 = 10
var y int8 = 20
var z int8 = 30

yp := unsafe.Pointer(&y)
nextp := uintptr(yp) - 1

fmt.Println("x:", x) // x: 10
fmt.Println("&x:", &x) // &x: 0xc0000120dd
fmt.Println("y:", y) // y: 20
fmt.Println("y:", &y) // y: 0xc0000120de
fmt.Println("z:", z) // z: 30
fmt.Println("z:", &z) // z: 0xc0000120df

fmt.Println((*int8)(unsafe.Pointer(nextp))) // 0xc0000120dd
fmt.Println(*(*int8)(unsafe.Pointer(nextp))) // 10

  

a := "hello"

ap := unsafe.Pointer(&a)

  

sizep := unsafe.Pointer(uintptr(ap) + 8)

*(*int)(sizep) = 4

  

fmt.Println(a) // hell

}
```