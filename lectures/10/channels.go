package main

import (
	"fmt"
	"time"
)

/*
c chan int     - send/receive
c <-chan int   - receive only
c chan<- int   - send only
*/

func main() {
	// channel for sending ints
	// CSP: Communicating Sequential Process
	var c chan int // nil channel

	// receive/send always block on nil channel (deadlock)
	// <-c // receive
	// c <- 1 // send

	c = make(chan int) // unbuffered channel; rendezvous
	// send waits for receive and vice versa
	go receive(c)
	time.Sleep(1 * time.Second)
	c <- 1
	time.Sleep(1 * time.Second)

	c2 := make(chan int, 2)
	c2 <- -1
	c2 <- -2
	// c2 <- -3 // deadlock

	for i := 0; i < 2; i++ {
		<-c2
	}
	fmt.Println("C2: ", len(c2), cap(c2), "\nC1: ", len(c), cap(c))

	// <- c2 // deadlock

	for i := 0; i < 2; i++ {
		c2 <- i
	}
	close(c2) // otherwise range will lead to deadlock

	for x := range c2 { // reads till EOF (channel close, otherwise causes deadlock)
		fmt.Println(x)
	}

	fmt.Println(<-c2) // receiving a closed chan always succeeds
	// gets ZERO-value

	// c2 <- 2 // PANIC: send on closed channel
	if x, ok := <-c2; ok {
		fmt.Println(x)
	} else {
		fmt.Println("channel has no data and is closed")
	}
}

func receive(c chan int) {
	fmt.Println("receiving")
	fmt.Println(<-c)
}
