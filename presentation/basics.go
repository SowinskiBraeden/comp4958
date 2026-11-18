package main

import "fmt"

/*
 * GoLang Generics:
 *
 * added in 1.18
 *
 * but first no generics. just basics
 */

func sum_ints(s []int) int {
	sum := 0
	for _, n := range s {
		sum += n
	}
	return sum
}

// dont even bother with int8, int16, int32, or in64

func sum_float32s(s []float32) float32 {
	var sum float32 = 0
	for _, n := range s {
		sum += n
	}
	return sum
}

func sum_float64s(s []float64) float64 {
	sum := 0.0
	for _, n := range s {
		sum += n
	}
	return sum
}

func main() {
	cool_ints := []int{3, 7, 1, 9, 6, 8, 4}
	fmt.Println(sum_ints(cool_ints))

	bad_floats := []float32{3.14, 4.20, 6.7, 6.9}
	// fmt.Println(sum_float64s(bad_floats)) // cant even pass float32 for float64
	fmt.Println(sum_float32s(bad_floats))

	meh_floats := []float64{1.23, 4.56, 7.89}
	fmt.Println(sum_float64s(meh_floats))
}
