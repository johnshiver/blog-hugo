+++
title = "Writing a Singly Linked List in Python"
date = "2017-01-04"
tags = ["python", "algorithms", "tutorial"]
+++

A lot of self-taught programmers don’t realize the importance of these concepts until they already have an interview lined up, and by then it’s already too late! I was fortunate enough to attend the Code Fellows Python Development Accelerator, where a section of the curriculum was dedicated to basic data structures and algorithms. But eight whirlwind weeks were not enough to solidify these concepts, so I thought it’d be beneficial, both for my own edification and for other budding Pythonistas, to write a series on basic data structures, starting with the linked list.

In its most basic form, a linked list is a string of nodes, sort of like a string of pearls, with each node containing both data and a reference to the next node in the list (Note: This is a singly linked list. The nodes in a doubly linked list will contain references to both the next node and the previous node). The main advantage of using a linked list over a similar data structure, like the static array, is the linked list’s dynamic memory allocation: if you don’t know the amount of data you want to store before hand, the linked list can adjust on the fly.* Of course this advantage comes at a price: dynamic memory allocation requires more space and commands slower look up times.

*In practice this means certain insertions are more expensive. For example, if the list initially allocates enough space for eight nodes, on the ninth insertion the list will have to double its allocated space to 16 and copy over the original 8 nodes, a more expensive operation than a normal insertion.

## The Node

The node is where data is stored in the linked list (they remind me of those plastic Easter eggs that hold treats). Along with the data each node also holds a pointer, which is a reference to the next node in the list. Below is a simple implementation.


{{< highlight python >}}

class Node(object):

    def __init__(self, data=None, next_node=None):
        self.data = data
        self.next_node = next_node

    def get_data(self):
        return self.data

    def get_next(self):
        return self.next_node

    def set_next(self, new_next):
        self.next_node = new_next

{{< /highlight >}}

The node initializes with a single datum and its pointer is set to None by default (this is because the first node inserted into the list will have nothing to point at!). We also add a few convenience methods: one that returns the stored data, another that returns the next node (the node to which the object node points), and finally a method to reset the pointer to a new node. These will come in handy when we implement the Linked List.

## The Linked List

My simple implementation of a linked list includes the following methods:

    Insert: inserts a new node into the list
    Size: returns size of list
    Search: search list for node throw error if none exists
    Delete: search list for node and, if exists, remove it

## The Head of the List

The first architectural piece of the linked list is the ‘head node’, which is simply the top node in the list. When the list is first initialized it has no nodes, so the head is set to None. (Note: the linked list doesn’t necessarily require a node to initialize. The head argument will default to None if a node is not provided.)


{{< highlight python >}}

class LinkedList(object):
    def __init__(self, head=None):
        self.head = head

{{< /highlight >}}

## Insert

This insert method takes data, initializes a new node with the given data, and adds it to the list. Technically you can insert a node anywhere in the list, but the simplest way to do it is to place it at the head of the list and point the new node at the old head (sort of pushing the other nodes down the line).

As for time complexity, this implementation of insert is constant O(1) (efficient!). This is because the insert method, no matter what, will always take the same amount of time: it can only take one data point, it can only ever create one node, and the new node doesn’t need to interact with all the other nodes in the list, the inserted node will only ever interact with the head.

{{< highlight python >}}
   def insert(self, data):
        new_node = Node(data)
        new_node.set_next(self.head)
       self.head = new_node
{{< /highlight >}}

## Size

The size method is very simple, it basically counts nodes until it can’t find any more, and returns how many nodes it found. The method starts at the head node, travels down the line of nodes until it reaches the end (the current will be None when it reaches the end) while keeping track of how many nodes it has seen.

The time complexity of size is O(n) because each time the method is called it will always visit every node in the list but only interact with them once, so n * 1 operations.

{{< highlight python >}}
    def size(self):
        current = self.head
        count = 0
        while current:
            count += 1
            current = current.get_next()
        return count
{{< /highlight >}}

## Search

Search is actually very similar to size, but instead of traversing the whole list of nodes it checks at each stop to see whether the current node has the requested data and if so, returns the node holding that data. If the method goes through the entire list but still hasn’t found the data, it raises a value error and notifies the user that the data is not in the list.

The time complexity of search is O(n) in the worst case (you often hear about best case / average case / worst case for Big O analysis. For this purpose of this blog post, we’ll assume worst case is the one we care about it, because it often is!)


{{< highlight python >}}
    def search(self, data):
        current = self.head
        found = False
        while current and found is False:
            if current.get_data() == data:
                found = True
            else:
                current = current.get_next()
        if current is None:
            raise ValueError("Data not in list")

        return current
{{< /highlight >}}

## Delete

You’ll be happy to know that delete is very similar to search! The delete method traverses the list in the same way that search does, but in addition to keeping track of the current node, the delete method also remembers the last node it visited. When delete finally arrives at the node it wants to delete, it simply removes that node from the chain by “leap frogging” it. By this I mean that when the delete method reaches the node it wants to delete, it looks at the last node it visited (the ‘previous’ node), and resets that previous node’s pointer so that, rather than pointing to the soon-to-be-deleted node, it will point to the next node in line. Since no nodes are pointing to the poor node that is being deleted, it is effectively removed from the list!

The time complexity for delete is also O(n), because in the worst case it will visit every node, interacting with each node a fixed number of times.

{{< highlight python >}}
    def delete(self, data):
        current = self.head
        previous = None
        found = False
        while current and found is False:
            if current.get_data() == data:
                found = True
            else:
                previous = current
                current = current.get_next()
        if current is None:
            raise ValueError("Data not in list")
        if previous is None:
            self.head = current.get_next()
        else:
            previous.set_next(current.get_next())
{{< /highlight >}}

That wraps up the linked list implementation! If I made a mistake please shoot me an email. At the bottom I’ve provided a link to the source code and have also added a test suite that tests all the functionality described in this blog post. Happy coding!

