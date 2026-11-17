// multiple workers looking for an answer; stop when one of them finds it
package main

import (
	"fmt"
	"math/rand"
	"time"
)

func worker(id int, answer chan<- int, stop chan int) {
	for {
		select {
		case <-stop:
			fmt.Printf("Worker %d stopping\n", id)
			return
		default:
			x := work(id)
			if isAnswer(x) {
				fmt.Printf("Worker %d found %d\n", id, x)
				answer <- x
			}
		}
	}
}

func work(id int) int {
	fmt.Printf("%d working...\n", id)
	r := rand.Intn(500)
	time.Sleep(time.Duration(300+r) * time.Millisecond)
	return r
}

func isAnswer(x int) bool {
	return x%17 == 0
}

func main() {
	answer := make(chan int)
	stop := make(chan int)

	go worker(1, answer, stop)
	go worker(2, answer, stop)
	go worker(3, answer, stop)

	select {
	case <-time.After(2 * time.Second):
		fmt.Println("Timed out")
		close(stop)
	case a := <-answer:
		fmt.Println("answer: ", a)
		close(stop) // can always receive a closed channel
	}
	time.Sleep(1 * time.Second)
}
