package main

import (
	"fmt"
	"sync"
)

var count int
var mutex sync.Mutex // starts in an unlocked state
var wg sync.WaitGroup

func inc() {
	// if we a function has multiple return paths, defer will ensure wg.Done() is always returned after
	defer wg.Done()
	for i := 0; i < 100_000; i++ {
		mutex.Lock()
		count++
		mutex.Unlock()
	}
	// wg.Done() // decrements the count of threads (i.e. 2 -> 1 -> 0)
}

// when main thread dies, all other threads are killed
func main() {
	wg.Add(2) // since we are creating 2 go routines, we add 2

	go inc()
	go inc()

	// time.Sleep(2 * time.Second)
	wg.Wait() // once the count gets to 0, then wg.Wait returns
	fmt.Println(count)
}
