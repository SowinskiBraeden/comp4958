package main

import (
	"fmt"
	"os"
)

func greet(lang string) string {
	switch lang {
	case "en":
		return "hello"
	case "fr":
		return "bonjour"
	default:
		return "hola"
	}
}

func main() {
	if len(os.Args) == 1 {
		fmt.Println(greet("en"))
	} else {
		fmt.Println(greet(os.Args[1]))
	}
}
