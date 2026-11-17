package main

import (
	"bufio"
	"fmt"
	"os"
	"sync"
)

type Worker struct {
	logged_p         int
	logged_q         int
	logged_r         int
	mutex            sync.Mutex
	p_lte_q, q_lte_r *sync.Cond // less than equal conditions
}

func NewWorker() *Worker {
	w := new(Worker)
	w.logged_p = 0
	w.logged_q = 0
	w.logged_r = 0
	w.p_lte_q = sync.NewCond(&w.mutex)
	w.q_lte_r = sync.NewCond(&w.mutex)
	return w
}

// each log function locks the mutex before running
// to allow it to update logged_ counts before
// other routines may read it
// then unlocks to allow others to read

func (w *Worker) log_p() {
	w.mutex.Lock()
	for w.logged_p >= w.logged_q { // as long as # of Ps is more than or equal to # of Qs
		w.p_lte_q.Wait() // wait for # of Ps less than equal to # of Qs
	}
	fmt.Print("P")
	w.logged_p++
	w.mutex.Unlock()
}

func (w *Worker) log_q() {
	w.mutex.Lock()
	for w.logged_q >= w.logged_r { // as long as # of Qs is more than equal to # of Rs
		w.q_lte_r.Wait() // wait for # of Qs less than equal to # of Rs
	}
	fmt.Print("Q")
	w.logged_q++
	w.p_lte_q.Signal() // Q increased, so P may now proceed
	w.mutex.Unlock()
}

func (w *Worker) log_r() {
	w.mutex.Lock()
	fmt.Print("R") // No limits on R, doesn't need to wait for anything
	w.logged_r++
	w.q_lte_r.Signal() // R increase, so Q may proceed
	w.mutex.Unlock()
}

func log_p_worker(w *Worker) {
	for {
		w.log_p()
	}
}

func log_q_worker(w *Worker) {
	for {
		w.log_q()
	}
}

func log_r_worker(w *Worker) {
	for {
		w.log_r()
	}
}

func main() {
	w := NewWorker()

	go log_p_worker(w)
	go log_q_worker(w)
	go log_r_worker(w)

	_ = bufio.NewScanner(os.Stdin).Scan()
}
