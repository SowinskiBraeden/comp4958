defmodule Lab1 do
  # Question 1 - Multiplicitive inverse of a module n
  defp inverse_mod(r, t, newr, _) when newr == 0 do {r, t} end
  defp inverse_mod(r, t, newr, newt) do
    q = div(r, newr)
    inverse_mod(
      newr,
      newt,
      r - q * newr,
      t - q * newt
    )
  end

  def inverse_mod(a, n) do
    case inverse_mod(n, 0, a, 1) do
      {r, _} when r > 1 ->
        :not_invertible

      {_, t} when t < 0 ->
        t + n

      {_, t} ->
        t
    end
  end

  # Question 2 - Fast modular exponent
  defp pow_mod(acc, a, m, n) do
    case rem(m, 2) do
      0 when m == 0 ->
        acc
      0 when m > 0 ->
        pow_mod(acc, rem(a*a, n), div(m, 2), n)
      _ ->
        pow_mod(rem(acc * a, n), rem(a*a, n), div(m, 2), n)
    end
  end

  def pow_mod(a, m, n) do
    rem(pow_mod(1, a, m, n), n)
  end
end
