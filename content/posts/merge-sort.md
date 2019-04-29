+++
title = "Implementing Merge Sort in Python"
date = "2017-03-01"
tags = ["python", "algorithms"]
+++

Imagine having a phone book without the last names sorted alphabetically. Or a dictionary with words unorganized. Ever tried to find a web page on the internet without the help of a search engine to rank results by relevance?

All of these tools derive their usefulness primarily from presenting information that has been sorted.
Sorting algorithms are one of the key areas of research within computer science. After all, data is mostly useless without some sort of structure. Some algorithms (like binary search) even require the input data to be sorted. While sorting data in your language of choice may be as easy as calling a built-in sort function, it’s essential for software engineers to understand the cost of sorting data (known as Big O notation for time and space complexity) and even better to understand the mechanics of the fundamental sorting algorithms: merge sort and quicksort.

In this blog post, I’m going to explain merge sort. My Python implementation will sort a list of integers, but you can use merge sort with any data that can be compared.
A note before we begin: if you are not already familiar with recursion, I recommend reading up on that topic first, before tackling merge sort.

## Merge Sort
Merge sort is comprised of two key insights:
a list of size one (i.e. a list with only one element) is always considered sorted
creating a sorted list from two lists that are already sorted can be done in linear time, expressed in Big O notation as: O(n)
Combined, these two innocuous insights are quite powerful:

{{< highlight python >}}

x = [5]
y = [8]

{{< /highlight >}}

Both x and y are size one and are therefore sorted. Combining xand y into a new sorted list, z, is simple and fast:

{{< highlight python >}}
z = []
if x[0] < y[0]:
    z.append(x[0])
    z.append(y[0])
else:
    z.append(y[0])
    z.append(x[0])
{{< /highlight >}}

Easy enough!
Now, think: how can these two concepts extend to a list of any size?
This is where recursion comes into play. Recursion is all about breaking big problems into smaller problems that are easy to manage. Say we have an array with 100 random integers and we need to sort them. Given the two insights we learned above, you might think, “I don’t know how to sort an array with 100 integers. But, I do know how to handle an array of size one.”
With this in mind, the first step of merge sort is to divide the input list into smaller lists, until we are working with lists that contain a single element. To divide the input list, we’ll use recursion: each time the function recurses, the input list is divided in half until the input list is of size one. When the input list is of size one (holding only one element), recursion ends and we can work with that list. Therefore, our base case is when the list contains fewer than 2 elements:


{{< highlight python >}}

def merge_sort(array):
    if len(array) < 2:
	return array

{{< /highlight >}}

If the base case does not trigger (meaning we have a list with more than one element in it), we divide the list into two halves, then recursively call the same merge_sort function on each half. How many recursions will it take until the list only has one element? Since every recursive step only processes “half” the data, it’s the inverse of exponential growth, meaning log(n) steps.


{{< highlight python >}}

mid = len(array) / 2
left = array[:mid]
right = array[mid:]
left = merge_sort(left)
right = merge_sort(right)

return merge(array, left, right)

{{< /highlight >}}

Again, if you are not comfortable with recursion, it might take a few reads to wrap your head around the concept. In the above code, the first time merge_sort returns a value to left and right (when the base case is finally triggered), it will be either an empty list or a list with one element in it. Recalling insight number one, we know we have two sorted lists! Recalling insight number two, two sorted lists can be merged into one sorted list in linear time, so we simply need to write a function to merge two sorted lists of any size. We’re nearly done!
Let’s look at the merge function line by line:

{{< highlight python >}}
def merge(array, left, right):
    # index pointers for array, left, and right
    m = l = r = 0
    while l < len(left) and r < len(right):
	if left[l] <= right[r]:
	    array[m] = left[l]
	    l += 1
	else:
	    array[m] = right[r]
	    r += 1
	m += 1
{{< /highlight >}}

The merge function takes the original list (unsorted) and its two sorted halves: the left list and the right list. Here we are reusing the original list to create a sorted list, but you could also create a new list altogether and add your arrays to that.
The basic idea is to compare elements from the left list to elements of the right list, copying the smaller of the two values onto the original array, incrementing index pointers as you move along. You’ll notice these steps take place in a while loop that checks that the left and right index are both within the bounds of their respective lists. This means that when the first while loop executes, one list will have some elements left over. This intuitively makes sense — while comparing elements from the left and right lists, one list (left or right) is going to have more smaller values and will run out of elements first, killing the while loop. Since we have a list with some leftover, sorted elements, the next step is simply to add the remainder to the final sorted list and return it.


{{< highlight python >}}
while l < len(left):
    array[m] = left[l]
    l += 1
    m += 1
while r < len(right):
    array[m] = right[r]
    r += 1
    m += 1
return array
{{< /highlight >}}

That’s all there is to the merge sort! The left and right list that emerge from recursion will be sorted, and your algorithm will happily merge these increasingly large sorted lists until you are a left with your initial array, sorted.


{{< highlight python >}}
# left and right will always be sorted
left = merge_sort(left)
right = merge_sort(right)
return merge(array, left, right)
{{< /highlight >}}

## Time Complexity
Finally, what is the time complexity of this algorithm? The goal of the recursive function was to reduce the size of the input list recursively until we reached a list of size one or smaller. This should ring a bell! Cutting an input’s size in half during each recursive iteration is a O(log n) operation. That is, it will take log(n) recursive calls until the base case is reached.
The other half of our merge sort algorithm is combining the two sorted lists into one list. Taking a look at the merge function, you are basically just comparing elements and sticking them in the final list one at a time. As the number of elements in each list grows, the number of comparisons grows at the same rate as the size of the list. That is, two lists of size 5 would need 5 comparisons for each merge, two lists of size 100 would require 100 comparisons and so on. This is very clearly a linear function, or O(n).
Putting it together, the merge sort algorithm performs an O(n) merge O(log n) times, which is expressed as an O(nlog(n)) algorithm. That’s very speedy compared to traditional O(n2) algorithms!

That concludes our basic introduction to merge sort. Other considerations I’d encourage as an exercise for the reader are memory as a function of n and whether the sort is “stable,” and so on.
What is important to take away is that there is no sorting algorithm on earth that beats O(nlog(n)). All the best sorting algorithms reach this same value. The reason there are so many different sorting algorithms lies in the details—choosing one over another often depends on the nature of the data you are sorting and other considerations. In the vast majority of cases, the built-in sort method will perform far better than any sorting implementation you write, but now you know the cost for each call is at least O(nlog(n)).

