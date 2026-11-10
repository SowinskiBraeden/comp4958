package main

import "fmt"

type I interface {
	f() int
}

type S1 struct{}

func (s S1) f() int { return 1 } // value receiver

type S2 struct{}

func (s *S2) f() int { return 2 } // pointer receiver

func main() {
	var i1 I = S1{}
	var i2 I = &S1{}
	// var _ I = S2{} // pointer reciever is more restrictive
	var i3 I = &S2{}

	// type assertions (may panic)
	x1 := i1.(S1)
	x2 := i2.(*S1)
	fmt.Println(x1, x2)

	if x3, ok := i2.(S1); ok {
		fmt.Println(x3)
	} else {
		fmt.Println("i2 is not an S1")
	}

	fmt.Println(typeof(i1))
	fmt.Println(typeof(i2))
	fmt.Println(typeof(i3))
}

func typeof(i any) string {
	// type switch
	switch i.(type) {
	case S1:
		return "S1"
	case *S1:
		return "*S1"
	case *S2:
		return "*S2"
	case int:
		return "int"
	default:
		return "unknown"
	}
}
