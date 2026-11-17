package main

import (
	"fmt"
	"time"
)

func main() {
	fmt.Println("setting timer to 2 seconds")
	c := time.After(2 * time.Second)
	fmt.Println(<-c)
	// fmt.Println(<-c) // deadlock
}
