### Bit Strings
# takes last 3 bits of 12
# takes last 5 bits of 55
<<12::3, 55::5>> # result: <<71::size(8)>>
# 12 = 0b1100
# 55 = 0b110111
# becomes 0b10010111 = 151

<<71::7>> # short form of <<71::size(7)>>

is_binary(<<12::3, 55::4>>) # -> false
# a binary is a bit string where its # of bits is a multiple of 8
is_binary(<<12::3, 55::5>>) # -> true
is_binary("hello")

# you can pattern match using bit strings
<<x::3, y::5>> = <<151>> # 151 = 0b10010111
# x = 4  = 0b100
# y = 23 = 0b10111

<<x::3, y::5, z::binary>> = <<151, 255, 55, 66>>
# works -> x, y pull its from 151
# z = <<255, 55, 66>> remaining since its a binary


<<x::3, y::6, z::bits>> = <<151, 255, 55, 66>>
# works -> x, y pull bits from 151 and 255 since looking for 9 bits
# but since 255, 55, 66 are non binary, we canot use z::binary it will fail
# instead we can use z::bits where z takes up the last remaining bits even
# if its non-binary (not a multiple of 8)

<<_, x, _, y, __::binary>> = "hello!"

# character(s) 'abc' is okay, but elixir wants you to use
# ~c"" to specify a char list or a single char
~c"abc"

String.to_charlist("hello")
# returns: ~c"hello"

s = "안녕하세요"
String.to_charlist(s) # -> [50504, 45397, 54616, 49464, 50836]
Stirng.codepoints(s)  # -> ["안", "녕", "하", "세", "요"]

byte_size(s) # -> 15 bytes

## concat with a 0 byte at end
s <> <<0>>
# -> since it cant display the unicodes, it will fallback to actually showing
# the 15 bytes and the 0 byte
# -> <<236, 149, 136, 235, 133, 149, 237, 149, 152, 236, 132, 184, 236, 154, 148, 0>>

# valid ascii code will show as a charlist
[97, 98, 99] # -> ~c"abc"
?a # -> 97 returns a code
?b # -> 98...

<<_, ?e, x, _::binary>> = "hello"
x # -> 108

### LIST COMPREHENSION
for x <- [3, 2, 7, 6, 8], do: (x + 1)
for x <- [3, 2, 7, 6, 8], rem(x, 2) == 0, do: (x * x)

### MAPS
m = %{"a" => 1, :b => "hello", {1, 2} => "world"}
m[{1, 2}]
m["a"]
m[:b]

# though typically the keys are atoms
# and can be written like this
m = %{a: 1, b: 2, c: 3}
m[:a]
m.a # or since keys are atoms

# pattern matchin on a Map
%{c: x} = m
x # -> 3

%{m | c: 4} # returns a new map, but does not assign to original m

for {_, v} <- m, do: v
# -> [3, 1, 2] returns values as list

# you can use pipe to pipe value to *first argument* of a function
for {_, v} <- m, do: v |> Enum.sum
# -> 6

# lets say we want to convert this list to a map
data = ["homer", 55, "bart", 33, "lisa", 99]
Enum.chunk_every(data, 2) # -> [["homer", 55], ["bart", 33], ["lisa", 99]]
for [n, s] <- Enum.chunk_every(data, 2), into: %{}, do: {n, s}


s = "नमस्ते"
for <<c <- s>>, do: c
# gets the 18 bytes


### CREATING PROCESSES
slow = fn x -> Process.sleep(1000); IO.puts(x) end # simulated slow method
slow.(1)

f = fn x -> spawn(fn -> slow.(x) end) end
f.(1)

# lets execute slow 10 times
Enum.each(1..10, slow) # will take 10 seconds, 1->10
Enum.each(1..10, f)    # will spawn a process for each 1->10 so only takes 1 second

pid = spawn(fn -> Process.sleep(1000); IO.puts("hello") end)
# send(pid, "msg") -> send processes message
# find pid of own processes -> self()

# lets send ourself hello, all processes have a mailbox
send(self(), "hello")

# we can read from mailbox
receive do
  x -> x
end

send(self(), {1, 2})
receive do
  {x, y} -> x + y
end

# flush will empty the mailbox, and shows
# all contents the mailbox before flush
flush

# not advised since processes can be running different elixir versions
f = fn x -> x * x end
send(self, f) # function brackets are optional, so self is same as self()

receive do
  g -> g.(3)
end


# ALIASES
# alias <name>, as: <alias>
# e.g.
# alias ArithmeticServer, as: AS

### FILES
{:ok, content} = File.read("filename.txt")
content |> String.split |> Enum.frequencies |> Enum.sort_by(fn {_, v} -> v end, :desc)
# -> [{"hello", 2}, {"world", 1}]

elem({1, "hello"}, 0) # -> 1
elem({1, "hello"}, 1) # -> "hello"

# pattern match result to only show most common word, i.e. discard word count
[{w, _} | _] = content |> String.split |> Enum.frequencies |> Enum.sort_by(fn {_, v} -> v end, :desc)
w
