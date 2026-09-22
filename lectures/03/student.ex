### Structs

defmodule Name do
  # defaults to john doe
  # or without defaults
  # defstruct [:first, :last]
  defstruct [first: "john", last: "doe"]

  def new(firstname, lastname) do
    %Name{first: firstname, last: lastname}
  end
end

defmodule Student do
  # default empty id, default name, default empty score map
  defstruct [id: "", name: %Name{}, scores: %{}]

  # default scores to empty map
  def new(id, firstname, lastname, scores \\ %{}) do
    %Student{id: id, name: Name.new(firstname, lastname), scores: scores}
  end

  # returns a new map
  def add_score(%Student{} = s, course, score) do
    %Student{s | scores: Map.put(s.scores, course, score)}
  end

  def parse(line) do
    case String.split(line) do
      [id, firstname, lastname | rest] ->
        # chunk_every returns a list of lists
        scores = for [c, s] <- Enum.chunk_every(rest, 2), into: %{},
                  do: {c, String.to_integer(s)}
        Student.new(id, firstname, lastname, scores)

      _ -> :error
    end
  end

  def read_data(file) do
    {:ok, content} = File.read(file)
    content |> String.split("\n") |> Enum.map(&parse/1) |> Enum.filter(& &1 != :error)
  end
end

# s = Student.new("a22222222", "homer", "simpson")
# # struct pattern matching
# %Student{id: x} = s
# x # -> a22222222

# %Student{} = s # doesnt match anything
#                # but ensures that s is a Student

# Student.add_score(s, "comp4958", 55)
