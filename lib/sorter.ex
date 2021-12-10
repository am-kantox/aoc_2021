defmodule M do
  @case_shift ?a - ?A + 1
  @lowercase_ascii Enum.to_list(?a..?z)
  @uppercase_ascii Enum.to_list(?A..?Z)
  @ascii_letters @lowercase_ascii ++ @uppercase_ascii
  @digits Enum.to_list(?0..?9)
  @service [?_]
  @ascii @ascii_letters ++ @digits ++ @service

  defguard is_same_group(c1, c2)
           when (c1 in @lowercase_ascii and c2 in @lowercase_ascii) or
                  (c1 in @uppercase_ascii and c2 in @uppercase_ascii)

  @spec sorter(String.t(), String.t()) :: boolean()
  def sorter(<<c::8, tl1::binary>>, <<c::8, tl2::binary>>) when c in @ascii,
    do: sorter(tl1, tl2)

  def sorter(<<c::utf8, tl1::binary>>, <<c::utf8, tl2::binary>>), do: sorter(tl1, tl2)

  def sorter(<<c1::8, _::binary>>, <<c2::8, _::binary>>) when is_same_group(c1, c2),
    do: c1 <= c2

  def sorter(<<c1::8, _::binary>>, <<c2::8, _::binary>>)
      when c1 in @lowercase_ascii and c2 in @uppercase_ascii,
      do: c1 <= c2 + @case_shift

  def sorter(<<c1::8, _::binary>>, <<c2::8, _::binary>>)
      when c1 in @uppercase_ascii and c2 in @lowercase_ascii,
      do: c1 + @case_shift <= c2

  def sorter(<<c1::8, _::binary>>, <<c2::8, _::binary>>) when c1 in @ascii and c2 in @ascii,
    do: c1 <= c2

  def sorter(s1, s2) do
    [s1, s2]
    |> Enum.map(&String.normalize(&1, :nfd))
    |> Enum.map(&String.split(&1, "", trim: true, parts: 2))
    |> case do
      [[c, ""], [c, <<d::utf8, _::binary>>]] ->
        not (c in @digits and d in @digits)

      [[c, <<d::utf8, _::binary>>], [c, ""]] ->
        c in @digits and d in @digits

      [[c, tl1], [c, tl2]] ->
        sorter(tl1, tl2)

      [[c1 | _], [c2 | _]] ->
        cond do
          String.upcase(c1) == c2 -> true
          c1 == String.upcase(c2) -> false
          true -> c1 <= c2
        end
    end
  end

  #############################################################################

  @input ~w|
    reraise/2
    reraise/3
    send/2
    sigil_C/2
    sigil_D/2
    sigil_c/2
    λ/1
    spawn/1
    spawn/3
    Λ/1
    a1/1
    a0/1
    a10/1
    a1_0/1
    a_0/1
    äpfeln/1
    Äpfeln/1
  |

  @sorted ~w|
    a0/1
    a1/1
    a10/1
    a1_0/1
    a_0/1
    äpfeln/1
    Äpfeln/1
    reraise/2
    reraise/3
    send/2
    sigil_c/2
    sigil_C/2
    sigil_D/2
    spawn/1
    spawn/3
    λ/1
    Λ/1
  |

  def test(), do: Enum.sort(@input, &sorter/2) == @sorted
end
