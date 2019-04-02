package main

import (
	"fmt"
	"murderers/storage"
)

func main() {
	fmt.Println("Hello world")
	s := storage.NewInMemoryStorage()
}
