// consider the following snippet

type Speaker interface {
	Speak() string
}

func announce(s Speaker) {
	fmt.Println(s.Speak())
}

// you could make it generic
// but importantly you dont have to

func announce[T Speaker](s T) {
	fmt.Println(s.Speak())
}

/*
 * Interfaces are usually better for showing shared behavior,
 *
 * while generics are useful for algorithms and containers that
 * need to keep relationships between types.
 */
