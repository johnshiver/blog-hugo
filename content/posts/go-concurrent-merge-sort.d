---
title: "Go Concurrent Merge Sort"
date: 2019-07-28T12:21:59-04:00
draft: true
---

One of the reasons I picked up Go is its excellent support for
concurrency, and I specifically find the CSP model to be very
intuitive. So whenever I find an interesting algorithm I try to make
it concurrent / see how fast I can make it. I [previously](http://www.johnshiver.org/posts/merge-sort/) wrote about how to implement merge sort in Python, so that knowledge is assumed.

Here I will implement a concurrent merge sort in Go.

First, lets take a quick look at a serial merge sort in Go:


{{< highlight go>}}
func MergeSort(ints []int) []int {
        if len(ints) <= 1 {
                return ints
        }
        mid := len(ints) / 2                                                                                                                     left := ints[:mid]
        right := ints[mid:]
        left = MergeSort(left)
        right = MergeSort(right)
        return Merge(left, right)
}
{{< /highlight >}}



{{< highlight go>}}
func SlowMerge(left, right []int) []int {
        var merged []int
        var l, r int

        for l < len(left) && r < len(right) {
                if left[l] <= right[r] {
                        merged = append(merged, left[l])
                        l++
                } else {
                        merged = append(merged, right[r])
                        r++
                }
        }

        for l < len(left) {
                merged = append(merged, left[l])
                l++

        }

        for r < len(right) {
                merged = append(merged, right[r])
                r++

        }

        return merged

}
{{< /highlight >}}

{{< highlight go>}}

func MergeSortConcurrentSizeLimit(ints []int) []int {

}

func mergeSortConcurrentSizeLimit(ints []int) []int {
        if len(ints) <= 1 {
                return ints
        }

        mid := len(ints) / 2

        wg := sync.WaitGroup{}
        wg.Add(2)

        var l []int
        var r []int

        if len(ints) >= CONC_LIMIT {
                go func() {
                        l = MergeSortConcurrentSizeLimit(ints[:mid])
                        wg.Done()
                }()
        } else {
                l = MergeSort(ints[:mid])
                wg.Done()
        }

        if len(ints) >= CONC_LIMIT {
                go func() {
                        r = MergeSortConcurrentSizeLimit(ints[mid:])
                        wg.Done()
                }()
        } else {
                r = MergeSort(ints[mid:])
                wg.Done()
        }

        wg.Wait()
        return Merge(l, r)
}

{{< /highlight >}}
