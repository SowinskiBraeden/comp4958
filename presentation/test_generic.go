package main

import "fmt"

type TestGen[T int | float64] struct {
	a, b T
}

func (t *TestGen[T]) sum() T {
	return t.a + t.b
}

func main() {
	t := TestGen[int]{3, 4}
	fmt.Println(t.sum())

	// Compile-time error
	// t2 := TestGeneric[int]{67, "bad"}
}

/*
 * so, would you rather have a runtime panic,
 * or a compile-time error?
 *
 * your choice
 */
