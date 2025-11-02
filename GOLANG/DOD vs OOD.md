**DOD** - **Data** Oriented Design
**OOD** - **Object** Oriented Design

### OOD

Храним массив объектов
```go

type Data struct {
	Field1 int
	Field2 string
	Field3 int
	...
}

data := []Data{}
```

### DOD

Храним массивы значений полей
```go

type Data struct {
	Field1 []int
	Field2 []string
	Field3 []int
	...
}

data := Data{}
```

В случае поиска значения по принципу DOD, то поиск происходит значительно быст 