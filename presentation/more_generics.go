package main

import "fmt"

type Number interface {
	int | float64
}

func sum_numbers[K comparable, V Number](data map[K]V) V {
	var sum V
	for _, x := range data {
		sum += x
	}
	return sum
}

func main() {
	ints := map[string]int{
		"first":  34,
		"second": 12,
	}

	floats := map[string]float64{
		"first":  35.98,
		"second": 26.99,
	}

	// implicit type inference - go will determine the types for you
	fmt.Println(sum_numbers(ints))
	fmt.Println(sum_numbers(floats))

	/**
	 * clearly this isn't clear enough for you,
	 * is that clear? so lets clear this up for the
	 * sake of clarity
	 */

	// explicit type arguments - we tell go to go with these types
	fmt.Println(sum_numbers[string, int](ints))
	fmt.Println(sum_numbers[string, float64](floats))
}
