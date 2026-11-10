package main

import (
	"bufio"
	"fal/pc/util"
	"os"
)

func producer(b *util.Buffer) {
	for {
		b.Produce()
	}
}

func consumer(b *util.Buffer) {
	for {
		b.Consume()
	}
}

func main() {
	b := util.NewBuffer(100)

	go producer(b)
	go producer(b)
	go producer(b)

	go consumer(b)
	go consumer(b)
	go consumer(b)

	_ = bufio.NewScanner(os.Stdin).Scan()
}
