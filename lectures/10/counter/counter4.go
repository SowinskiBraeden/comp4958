package main

import (
	"fmt"
)

var count int
var c chan int = make(chan int, 1) // only can store 1 int
var c2 chan int = make(chan int)

func inc() {
	for i := 0; i < 1_000_000; i++ {
		c <- 1 // send first to lock the chan from other sends
		count++
		<-c // receive to open chan to other sends
	}
	fmt.Println("done")
	c2 <- 1
}

func main() {
	go inc()
	go inc()

	<-c2
	<-c2
	fmt.Println(count)
}
