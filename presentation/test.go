package main

import "fmt"

type Test struct {
	a, b any
}

// wont compile
// invalid operation: operator + not defined on t.a (variable of interface type any) (compiler UndefinedOp)
// func (t *Test) sum() any {
// 	return t.a + t.b
// }

func (t *Test) sum() (int, bool) {
	a, okA := t.a.(int)
	b, okB := t.b.(int)

	if !okA || !okB {
		return 0, false
	}

	return a + b, true
}

func main() {
	t := &Test{3, 4}

	fmt.Println(t.sum()) // ok

	t2 := &Test{67, "bad"}
	fmt.Println(t2.sum()) // not ok - could panic if not handled correctly
}
