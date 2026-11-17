package main

import (
	"fmt"
	"slices"
	"strconv"
)

func sieve(p, acc []int, n int) []int {
	if len(p) == 0 {
		return acc
	}

	h := p[0]
	if h*h > n {
		return append(acc, p...)
	}

	var remaining []int
	for _, x := range p[1:] { // skip first elem
		if x%h != 0 {
			remaining = append(remaining, x)
		}
	}

	return sieve(remaining, append(acc, h), n)
}

// precondition: 0 <= m < n
func primes(m, n int) []int {
	if m < 0 || m >= n || n < 2 {
		return []int{}
	}

	c := make([]int, 0, n-2)
	for i := 2; i < n; i++ {
		c = append(c, i)
	}

	var result []int
	for _, x := range sieve(c, nil, n) {
		if x > m {
			result = append(result, x)
		}
	}

	return result
}

func sortDigits(n int) string {
	digits := []byte(strconv.Itoa(n))
	slices.Sort(digits)
	return string(digits)
}

func main() {
	p := primes(100_000, 1_000_000)
	fmt.Println(len(p))

	groups := make(map[string][]int)
	for _, x := range p {
		key := sortDigits(x)
		groups[key] = append(groups[key], x) // appending to a nil slice is ok
	}

	var largest []int
	for _, v := range groups {
		if len(v) > len(largest) {
			largest = v
		}
	}

	fmt.Println(len(largest))
}
