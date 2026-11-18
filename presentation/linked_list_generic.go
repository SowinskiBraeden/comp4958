package main

import "fmt"

// woah
type Number interface {
	int | int8 | int16 | int32 | int64 | float32 | float64 |
		uint | uint8 | uint16 | uint32 | uint64
}

type Node[T Number] struct {
	value T
	next  *Node[T]
}

type LinkedList[T Number] struct {
	head *Node[T]
}

func (l *LinkedList[T]) push(v T) {
	l.head = &Node[T]{
		value: v,
		next:  l.head,
	}
}

func (l *LinkedList[T]) sum() T {
	var sum T
	for node := l.head; node != nil; node = node.next {
		sum += node.value // no more type assertion since its a type, not `any`
	}
	return sum
}

func main() {
	list := LinkedList[int]{}

	list.push(10)
	list.push(20)
	// list.Push("hello") // Compile-time error

	fmt.Println(list.sum())

	floats := LinkedList[float64]{}
	floats.push(10.5)
	floats.push(20.25)

	fmt.Println(floats.sum())
}
