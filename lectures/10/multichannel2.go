package main

import (
	"fmt"
	"math/rand"
	"time"
)

func worker(c chan int) {
	for {
		// simulate work then send
		r := rand.Intn(200)
		time.Sleep(time.Duration(300+r) * time.Millisecond)
		c <- r
		if r%37 == 0 { // simulating the worker randomly stopping
			fmt.Println("stopping")
			close(c) // so that main can detect this
			return
		}
	}
}

func main() {
	c1 := make(chan int)
	c2 := make(chan int)

	go worker(c1)
	go worker(c2)

	for {
		select {
		case x, ok := <-c1:
			if ok {
				fmt.Println("c1: ", x)
			} else {
				c1 = nil
			}
		case x, ok := <-c2:
			if ok {
				fmt.Println("c2: ", x)
			} else {
				c2 = nil
			}
		}
		if c1 == nil && c2 == nil {
			return
		}
	}
}
