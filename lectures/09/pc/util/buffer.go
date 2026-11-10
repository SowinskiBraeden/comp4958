package util

import (
	"fmt"
	"sync"
)

type Buffer struct {
	used              int // number of used cells in buffer
	total             int
	mutex             sync.Mutex
	notFull, notEmpty *sync.Cond
}

func NewBuffer(total int) *Buffer {
	b := new(Buffer)
	b.used = 0
	b.total = total
	b.notFull = sync.NewCond(&b.mutex)
	b.notEmpty = sync.NewCond(&b.mutex)
	return b
}

func (b *Buffer) Produce() {
	b.mutex.Lock()
	for b.used == b.total { // as long as buffer is full
		b.notFull.Wait() // wait for not full
	}
	b.used++
	fmt.Print("+")
	b.notEmpty.Signal()
	b.mutex.Unlock()
}

func (b *Buffer) Consume() {
	b.mutex.Lock()
	for b.used == 0 { // as long as buffer is empty
		b.notEmpty.Wait() // wait for not empty
	}
	b.used--
	fmt.Print("-")
	b.notFull.Signal()
	b.mutex.Unlock()
}
