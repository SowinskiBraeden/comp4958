package main

import "fmt"

// higher order function
func make_counter(init int) func() int {
	return func() int {
		value := init
		init++
		return value
	}
}

func main() {
	c1 := make_counter(1)
	fmt.Println(c1())
	fmt.Println(c1())
	fmt.Println(c1())

	c2 := make_counter(10)
	fmt.Println(c2())
	fmt.Println(c2())
	fmt.Println(c2())
}
