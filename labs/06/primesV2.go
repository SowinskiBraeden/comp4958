package main

import (
	"fmt"
	"maps"
	"slices"
	"strconv"
)

/*
 * Sieve of Eratosthenes: but the right way
 */

func sieve(n int) []int {
	is_prime := make([]bool, n+1) // true means false, and false means true: wild
	is_prime[0] = true
	is_prime[1] = true

	p := 2

	for p < n/p {
		if !is_prime[p] {
			multiple := p * p
			for multiple <= n {
				is_prime[multiple] = true
				multiple += p
			}
		}
		p += 1
	}

	var primes []int
	for candidate, prime := range is_prime {
		if !prime { // since false is true, !prime is actually prime
			primes = append(primes, candidate)
		}
	}

	return primes
}

func primes(m, n int) []int {
	if m > n || n < 2 {
		return []int{}
	}

	primes := sieve(n)
	i := 0
	for _, prime := range primes {
		if prime >= m {
			primes[i] = prime
			i++
		}
	}
	return primes[:i]
}

func sortDigits(n int) string {
	digits := []byte(strconv.Itoa(n))
	slices.Sort(digits)
	return string(digits)
}

func main() {
	p := primes(100_000, 1_000_000)
	fmt.Println(len(p))

	groups := make(map[string]int)
	for _, x := range p {
		groups[sortDigits(x)]++
	}

	values := slices.Collect(maps.Values(groups))
	slices.Sort(values)
	slices.Reverse(values)
	fmt.Println(values[0])
}
