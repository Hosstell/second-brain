### Сравнение структур
```go
type Type1 struct {
	size int32
	values [10 << 20]byte
}

type Type2 struct {
	values [10 << 20]byte
	size int32
}
```

Сравнение структур происходит по байтого.
Поэтому 