package main

import "fmt"

/*
 * we can somewhat get a generic linked list
 * without using generics, i.e. with `any` (interface{})
 */

type Node struct {
	value any // previously interface{}
	next  *Node
}

type LinkedList struct {
	head *Node
}

func (l *LinkedList) push(value any) {
	l.head = &Node{
		value: value,
		next:  l.head,
	}
}

func main() {
	list := LinkedList{}
	list.push(20)
	list.push(40)

	// here is the issue with `any`
	list.push("60") // this is allowed

	/*
			 * you may think this is great and flexible,
		   * but then "you're an idiot" - Dr. Gregory House
	*/

	fmt.Println(list.sum())
}

/*
 * if some buffoon actually uses `any` or `interface{}`
 * in their linked list, and accidently pushes two
 * different types to the list, then tries to do any
 * operation like.. oh idk, sum. will encounter a
 * panic only at runtime
 */
func (l *LinkedList) sum() any {
	sum := 0
	for node := l.head; node != nil; node = node.next {
		sum += node.value.(int) // type assertion will panic
	}
	return sum
}

/*
 * why not just define int instead of any?
 * cause.. Albert probably said so.
 * something to do with then its not generic
 */
