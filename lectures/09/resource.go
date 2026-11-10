package main

import (
	"fmt"
	"math/rand"
	"sync"
	"time"
)

type Resource struct {
	available int // number of available units
	total     int // total number of units
	cond      *sync.Cond
}

func NewResource(total int) *Resource {
	return &Resource{
		available: total,
		total:     total,
		cond:      sync.NewCond(&sync.Mutex{}),
	}
}

func (r *Resource) Acquire() {
	r.cond.L.Lock() // L is the default name of the mutex inside cond
	for r.available == 0 {
		r.cond.Wait()
	}
	r.available--
	fmt.Println(r.available)
	r.cond.L.Unlock()
}

func (r *Resource) Release() {
	r.cond.L.Lock()
	r.available++
	fmt.Println(r.available)
	r.cond.Signal()
	r.cond.L.Unlock()
}

func work(min, max int) {
	time.Sleep(time.Duration(min+rand.Intn(max-min)) * time.Millisecond)
}

func worker(r *Resource) {
	for i := 0; i < 10; i++ {
		work(500, 1000)
		r.Acquire()
		work(500, 1000)
		r.Release()
	}
}

func main() {
	var wg sync.WaitGroup

	r := NewResource(5)

	wg.Go(func() { worker(r) })
	wg.Go(func() { worker(r) })
	wg.Go(func() { worker(r) })

	wg.Wait()
}
