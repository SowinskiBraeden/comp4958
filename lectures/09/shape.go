package main

import (
	"fmt"
	"math"
)

type Shape interface {
	Area() float64
}

type Circle struct {
	x, y, r int
}

func (c Circle) Display() { // c is the receiver; value receiver
	fmt.Printf("(%d, %d), %d\n", c.x, c.y, c.r)
}

func (c *Circle) Scale(factor int) { // pointer receiver
	c.r *= factor
}

func (c Circle) Area() float64 {
	return float64(c.r*c.r) * math.Pi
}

type Rectangle struct {
	x1, y1 int
	x2, y2 int
}

func (r Rectangle) Display() {
	fmt.Println("(%d, %d), (%d, %d)\n", r.x1, r.y1, r.x2, r.y2)
}

func (r Rectangle) Area() float64 {
	return math.Abs(float64((r.x1 - r.x2) * (r.y1 - r.y2)))
}

func TotalArea(shapes []Shape) float64 {
	sum := 0.0
	for _, s := range shapes {
		sum += s.Area()
	}
	return sum
}

func main() {
	c1 := Circle{0, 0, 1}
	c2 := Circle{
		x: 1,
		y: 1,
		r: 2,
	}

	c1.Display()
	c2.Display()
	c2.Scale(3)
	c2.Display()

	r := Rectangle{1, 1, 2, 2}

	shapes := []Shape{c1, c2, r}
	fmt.Println(TotalArea(shapes))
}
