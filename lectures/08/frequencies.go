package main

import (
	"bufio"
	"fmt"
	"os"
)

func main() {
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Split(bufio.ScanWords)

	freq := make(map[string]int)

	for scanner.Scan() {
		freq[scanner.Text()]++
	}

	fmt.Println(freq)

	max_freq, most_freq := 0, []string{}
	for word, count := range freq {
		if count > max_freq {
			max_freq = count
			most_freq = []string{word}
		} else if count == max_freq {
			most_freq = append(most_freq, word)
		}
	}

	fmt.Println(most_freq, max_freq)
}
