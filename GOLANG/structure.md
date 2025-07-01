```go
package main  
  
import "fmt"  
  
type Person struct {  
    Name string  
    Age  int  
    Prof string  
} 

// Метод для структуры Person  
func (p *Person) Greet() {  
    fmt.Printf("Hello, my name is %s and I am %d years old.\n", p.Name, p.Age)  
}  
  
func printPerson(person Person) {  
    fmt.Printf("Person(name='%s', age=%d, prof='%s')\n", person.Name, person.Age, person.Prof)  
}  
  
func main() {  
    a := Person{Name: "Andrey Serov", Age: 28, Prof: "Developer"}  
    printPerson(a)  
    a.Greet()  
}
```

