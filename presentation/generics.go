package main

import "fmt"

/*
 * GoLang Generics:
 *
 * added in 1.18
 */

func sum_ints_or_floats[V int | float32 | float64](s []V) V {
	var sum V // zero-value
	for _, x := range s {
		sum += x
	}
	return sum
}

func main() {
	cool_ints := []int{3, 7, 1, 9, 6, 8, 4}
	fmt.Println(sum_ints_or_floats(cool_ints))

	bad_floats := []float32{3.14, 4.20, 6.7, 6.9}
	// fmt.Println(sum_float64s(bad_floats)) // cant even pass float32 for float64
	fmt.Println(sum_ints_or_floats(bad_floats))

	meh_floats := []float64{1.23, 4.56, 7.89}
	fmt.Println(sum_ints_or_floats(meh_floats))

	/*
	 * oh my days I did the same thing with just one function!
	 * minds blown but its not generic enough
	 */

	demo_p2()
}

/*
 * need int8, int16, int32, int64 and all floats too?
 * MAKE A TYPE CONSTRAINT
 */

// wowza
type Number interface {
	int | int8 | int16 | int32 | int64 | float32 | float64 |
		uint | uint8 | uint16 | uint32 | uint64
}

// ultimit genericism
func sum_number[V Number](s []V) V {
	var sum V = 0
	for _, x := range s {
		sum += x
	}
	return sum
}

func demo_p2() {
	cool_ints := []int{3, 7, 1, 9, 6, 8, 4}
	fmt.Println(sum_number(cool_ints))

	bad_floats := []float32{3.14, 4.20, 6.7, 6.9}
	fmt.Println(sum_number(bad_floats))

	meh_floats := []float64{1.23, 4.56, 7.89}
	fmt.Println(sum_number(meh_floats))

	// and all the ints
	cool_ints2 := []int8{3, 7, 1, 9, 6, 8, 4}
	fmt.Println(sum_number(cool_ints2))

	cool_ints3 := []int16{3, 7, 1, 9, 6, 8, 4}
	fmt.Println(sum_number(cool_ints3))

	cool_ints4 := []int32{3, 7, 1, 9, 6, 8, 4}
	fmt.Println(sum_number(cool_ints4))

	cool_ints5 := []int64{3, 7, 1, 9, 6, 8, 4}
	fmt.Println(sum_number(cool_ints5))

	// ... so on with the unsigned ints
}
