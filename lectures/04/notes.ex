# raise("hell") # runtime error
# exit(:die)    # typtically exit with an atom
# throw(:what)
# throw(1)      # can throw anything

try do
    1/0
catch type, value ->
    IO.inspect({type, value})
end

# 3 types of runime error
try do
    raise("hell")
catch type, value ->
    IO.inspect({type, value})
end

try do
    throw :up
catch type, value ->
    IO.inspect({type, value})
end

try do
    exit(1)
catch type, value ->
    IO.inspect({type, value})
after
    IO.puts("done")
end
