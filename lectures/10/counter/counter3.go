package main

import (
	"fmt"
	"sync"
)

var count int
var c chan int = make(chan int, 1) // only can store 1 int
var wg sync.WaitGroup

func inc() {
	for i := 0; i < 1_000_000; i++ {
		c <- 1 // send first to lock the chan from other sends
		count++
		<-c // receive to open chan to other sends
	}
	fmt.Println("done")
}

func main() {
	wg.Go(func() { inc() })
	wg.Go(func() { inc() })

	wg.Wait()
	fmt.Println(count)
}
