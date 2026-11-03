package main

import "fmt"

type Circle struct {
	x, y, r int
}

func (c Circle) Display() { // c is the receiver; value receiver
	fmt.Printf("(%d, %d), %d\n", c.x, c.y, c.r)
}

func (c *Circle) Scale(factor int) { // pointer receiver
	c.r *= factor
}

func main() {
	c1 := Circle{0, 0, 1}
	c2 := Circle{
		x: 1,
		y: 1,
		r: 1,
	}

	c1.Display()
	c2.Display()
	c2.Scale(3)
	c2.Display()
}
