package main

import (
	"fmt"
	"time"
)

var count int
var c chan int = make(chan int)

// problematic: 1_000_000 receives/1_000_001 sends
// (the last send blocks)
func inc() {
	for i := 0; i < 1_000_000; i++ {
		<-c
		count++
		c <- 1
	}
	fmt.Println("done")
}

func main() {
	go inc()
	go inc()
	c <- 1 // write first to start, otherwise both inc() only read first and no writes
	time.Sleep(1 * time.Second)
	fmt.Println(count)
}
