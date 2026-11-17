package main

import (
	"fmt"
	"time"
)

func main() {
	c := time.Tick(1 * time.Second)

	for {
		fmt.Println(<-c) // every second, receives from channel
	}
}
