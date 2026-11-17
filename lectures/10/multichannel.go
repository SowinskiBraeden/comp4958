package main

import (
	"fmt"
	"math/rand"
	"time"
)

func worker(c chan int) {
	for {
		// simulate work then send
		r := rand.Intn(7000)
		time.Sleep(time.Duration(300+r) * time.Millisecond)
		c <- r
	}
}

func main() {
	c1 := make(chan int)
	c2 := make(chan int)

	go worker(c1)
	go worker(c2)

	for {
		select {
		case x := <-c1:
			fmt.Println("c1: ", x)
		case x := <-c2:
			fmt.Println("c2: ", x)
		}
	}
}
