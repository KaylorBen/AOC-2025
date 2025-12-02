split_by = fn(string, n) ->
  len = String.length(string)
  ratio = len / n
  if ratio != floor(ratio) do
    []
  else
    Enum.map(0..n-1, fn cur ->
      idx = trunc(cur * (ratio))
      String.slice(string, idx..(idx + trunc(ratio))-1)
    end)
  end
end

IO.puts(Tuple.sum(List.to_tuple(Enum.map(String.split(File.read!("input"), ","), fn(range) ->
  [lower, upper] = Enum.map(String.split(range, "-"), fn x ->
    elem(Integer.parse(x), 0)
  end)
  Tuple.sum(List.to_tuple(Enum.map(lower..upper, fn value ->
    full_num = Integer.to_string(value)
    len = String.length(full_num)
    if Enum.any?(Enum.map(2..len, fn n ->
      parts = split_by.(full_num, n)
      if Enum.empty?(parts) do
        false
      else
        Enum.all?(parts, fn x -> x == Enum.at(parts, 1) end)
      end
    end)) do
      value
    else
      0
    end
  end)))
end))))
