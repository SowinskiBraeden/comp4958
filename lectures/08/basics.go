package main

import "fmt"

var x1 = 1
var x2 int = 2

func main() {
	var x3 = 3.14
	x4 := 2.17     // short decleration; only inside functions
	var x5 float64 // uninitialized: gets zero value
	fmt.Println(x1, x2, x3, x4, x5)

	arrays()
	slices()
	maps()
}

func arrays() {
	fmt.Println("ARRAYS")
	// note arrays are values, not references
	var a1 = [5]int{3, 2, 7, 6, 8}
	var a2 [5]int
	a3 := [5]int{1, 2, 3, 4, 5}

	fmt.Println(a1, a2, a3)
	a2 = a3
	fmt.Println(a1, a2, a3)

	fmt.Println(sum5(a1))
	fmt.Println(sum5_v2(&a1))
}

// gets a copy of the array
func sum5(a [5]int) int {
	sum := 0
	for i := 0; i < 5; i++ {
		sum += a[i]
	}
	return sum
}

func sum5_v2(a *[5]int) int {
	sum := 0
	for i := 0; i < 5; i++ {
		sum += a[i]
	}
	return sum
}

func slices() {
	// a non-nil non-empty slice ms tbe backed by an array (which can be named or anonymous)
	fmt.Println("SLICES")

	var s1 []int     // nil slice
	var s2 = []int{} // empty slice

	// can only compare a slice to nil
	fmt.Println(s1, s2)
	fmt.Println(s1 == nil)
	fmt.Println(s2 == nil)
	// fmt.Println(s1 == s2) // NOT OK

	a := [5]int{0, 1, 2, 3, 4}
	s := a[1:3] // a[lo:hi], half-open

	fmt.Println(s, len(s), cap(s)) // len: 2, cap: 6 - 1

	s[0] = -1
	fmt.Println(a, s)

	s = append(s, -3)
	fmt.Println(a, s)
	s = append(s, -4, -5, -6, -7) // exceeds capacity; gets new backing array
	fmt.Println("a:", a, "s:", s)
	// can append to nil slice
	s1 = append(s1, 1, 2, 3)
	fmt.Println(s1, s1 == nil)
	// fmt.Println(sum(a)) // will not compile since a is not a slice
	fmt.Println(sum(a[:])) // needs a slice
}

func sum(s []int) int {
	sum := 0

	for _, x := range s { // x is a copy of the element
		sum += x
	}

	// for i := range s {
	// 	sum += s[i]
	// }

	// for i := 0; i < len(s); i++ {
	// 	sum += s[i]
	// }

	return sum
}

func maps() {
	fmt.Println("MAPS")

	var m1 map[string]int // nil map; can't put key/value inside
	m1 = make(map[string]int)
	m1["homer"] = 25
	m1["bart"] = 66
	fmt.Println(m1["monty"]) // zero value

	if x, ok := m1["homer"]; ok {
		fmt.Println(x)
	} else {
		fmt.Println("Not Found")
	}

	delete(m1, "bart")
	m2 := map[string]int{"homer": 25}
	fmt.Println(m2)
}
