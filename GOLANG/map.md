```go
package main  
  
import "fmt"  
  
// Создай карту, которая хранит имена студентов и их оценки.  
// Реализуй функции для добавления, удаления и поиска  
// студентов по имени.  
  
var scores = make(map[string][]int)  
  
func addScore(name string, score int) {  
    scores[name] = append(scores[name], score)  
}  
  
func getScores(name string) []int {  
    return scores[name]  
}  
  
func removeScores(name string) {  
    delete(scores, name)  
}  
  
func main() {  
    addScore("andrey", 2)  
    addScore("andrey", 4)  
    fmt.Println(getScores("andrey"))  
    removeScores("andrey")  
    fmt.Println(getScores("andrey"))  
}
```