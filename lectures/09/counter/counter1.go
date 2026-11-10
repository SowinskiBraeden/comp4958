package main

import (
	"fmt"
	"time"
)

var count int

func inc() {
	for i := 0; i < 100_000; i++ {
		count++
	}
}

// when main thread dies, all other threads are killed
func main() {
	go inc()
	go inc()

	time.Sleep(2 * time.Second)

	fmt.Println(count)
}
