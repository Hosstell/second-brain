```go
package main  
  
import "fmt"  
  
type Person struct {  
    Name string  
    Age  int  
    Prof string  
}  
  
func printPerson(person Person) {  
    fmt.Printf("Person(name='%s', age=%d, prof='%s')", person.Name, person.Age, person.Prof)  
}  
  
func main() {  
    a := Person{Name: "Andrey Serov", Age: 28, Prof: "Developer"}  
    printPerson(a)  
}
```

