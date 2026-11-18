package main

import "fmt"

/*
 * Now you may think...
 * can't we just use type constraints?
 */

type Number interface {
	int | float64
}

func sum(s []Number) Number {
	var sum Number
	for _, x := range s {
		sum += x
	}
	return sum
}

/*
 * NO! You cannot use type constraints
 * outside.. constraints.
 *
 * Interfaces containing type unions,
 *    e.g. int | float64
 * can only be used as type constraints,
 * not ordinary value types like `any`
 */

func main() {
	data1 := []int{1, 2, 3, 4, 5, 6, 7, 8, 9}
	data2 := []float64{1.2, 3.4, 5.6, 7.8, 9.0}

	fmt.Println(sum(data1))
	fmt.Println(sum(data2))
}
