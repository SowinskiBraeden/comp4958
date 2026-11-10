package util

import (
	"math/rand"
	"time"
)

func work(min, max int) {
	time.Sleep(time.Duration(min+rand.Intn(max-min)) * time.Millisecond)
}
