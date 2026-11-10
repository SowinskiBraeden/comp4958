package main

import (
	"fmt"
	"sync"
)

func NewCounter() *Counter {
	return &Counter{count: 0}
}

type Counter struct {
	count int
	mutex sync.Mutex // starts in an unlocked state
}

func (c *Counter) Inc() {
	c.mutex.Lock()
	c.count++
	c.mutex.Unlock()
}

func inc_counter(c *Counter) {
	for i := 0; i < 100_000; i++ {
		c.Inc()
	}
}

// when main thread dies, all other threads are killed
func main() {
	c := NewCounter()

	var wg sync.WaitGroup

	// WaitGroup.Go takes a function with no arguments
	wg.Go(func() { inc_counter(c) })
	wg.Go(func() { inc_counter(c) })

	fmt.Println(count)
}
