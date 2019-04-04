package main

import (
	"fmt"
	"murderers/context"
	"murderers/storage"
)

func main() {
	fmt.Println("Hello world")

	// Create context.
	cStorage := storage.NewInMemoryStorage()
	c := context.New(
		&cStorage,
	)

	fmt.Println(c)
}
