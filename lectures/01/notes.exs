## Sep. 08, 2026 - Braeden Sowinski

# h can be used to find info on a function
h is_boolean

# function brackets are optional but recommended
is_boolean "hello"
is_boolean(false)

3/2      # -> 1.5 results in a float
div(3,2) # -> 1 results in an int

### Atoms
# - Create atoms by starting with a :
# ANYTHING that starts with an uppercase is an atom
## atoms are constants whos value is their own name
:hello_world
Hello # is an atom because it starts with uppercase

# Similarly module names must start with uppercase, and are therefor atoms
# e.g.
Hello = :"Elixir.Hello" # -> true

# nil is an atom but nil is built in
nil
:nil
nil == :nil

# Short circuits returns second cond
1 < 2 and false # -> results in false
1 < 2 and 3     # -> results in 3

1 and false     # -> errors out, first must be a boolean
1 && false      # -> works

# and or not operators

# erlang modules start with lowercase and you can call them by using
# a colon before the module name, this makes it an atom which are modules
:math.pi

# in erlang syntax its math:pi

# variables in erlang start with uppercase where in elixir they start with lowercase
x = 1

# variables are immutable but can be rebound
# i.e. this is a different x
x = 2
2 = x

# '=' is not an assignment, its a match operator trying to match left to right

{x, 2} = {1, 2} # matches, and x becomes 1

# you can pin the value of x with ^
{^x, 2} = {3, 2} # this wont match since x is pinned to 1, and we are trying to match with 3

# if a match is successful, it will always return the right hand side of the match

{a, "hello", b} = {2, "hello", :atom}
a # -> 2
b # -> :atom

# you can use x more than once as long as it matches
{x, x, 1} = {"hello", "world", 1} # -> no match
{x, x, 1} = {"hello", "hello", 1} # -> matches
x # -> "hello"

### List type
[1, 2, "hello"]

# cons operator is | similar to `||` in ocaml
[1 |[2, "hello"]]     # -> same as above
[1 | [2 | ["hello"]]] # -> same as above

# cons operator can be used to pattern match
[h | t] = [1, 2, 3]
h # -> 1
t # -> [2, 3]

[_, x, _, y | _] = [1, "hello", 2, "world", 5]
x # -> "hello"
y # -> "world"

# `_` can be used to match and just throw that junk away,
# similarly we can do `| _` to match the remaining to nothing

### Anonymous Functions
f = fn x -> x + 1 end

# to call an anon function use .()
f.(1)

String.upcase("hello") # -> "HELLO"

# functions passed to other functions need to be anon functions
Enum.map(["hello", "world"], fn x -> String.upcase(x) end)

# Another way to do this is to capture a function to make it anon
# we specify String.upcase/1 since there are two version of upcase
# one with /1 argument and another upcase with /2 arguments
Enum.map(["hello", "world"], &String.upcase/1)

Enum.map([1, 2], fn x -> x * x end)
Enum.map([1, 2], &(&1 * &1)) # captured anon function, &1 is first argument

# or

Enum.map([1, 2], fn x -> x + 1 end)
Enum.map([1, 2], &(&1 + 1))

# LIST CONCAT / DIFF
[1, 2] ++ [3, 4]
[1, 2] -- [1] # -> [2]

# STRING CONCAT
"hello" <> " " <> "world"
