IO.puts(Tuple.sum(List.to_tuple(Enum.map(String.split(File.read!("input"), ","), fn(range) ->
  [lower, upper] = Enum.map(String.split(range, "-"), fn x ->
    elem(Integer.parse(x), 0)
  end)
  Tuple.sum(List.to_tuple(Enum.map(lower..upper, fn(value) ->
    full_num = Integer.to_string(value)
    {first, last} = String.split_at(
      full_num,
      div(String.length(full_num),2)
    )
    if first == last do
      value
    else
      0
    end
  end)))
end))))
