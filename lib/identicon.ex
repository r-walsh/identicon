defmodule Identicon do

  def main(seed) do
    seed
      |> hash_seed
      |> generate_rgb_color
      |> build_grid
      |> filter_odd_squares
      |> build_pixel_map
      |> draw_image
      |> save_image(seed)
  end

  defp hash_seed(seed) do
    hex = :crypto.hash(:md5, seed)
      |> :binary.bin_to_list

    %Identicon.Image{hex: hex}
  end

  defp build_grid(%Identicon.Image{hex: hex} = image) do
    grid = hex
      |> Enum.chunk(3)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Identicon.Image{ image | grid: grid }
  end

  defp mirror_row([first, second | _tail] = row) do
    row ++ [second, first]
  end

  defp filter_odd_squares(%Identicon.Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({hex_code, _index}) ->
      rem(hex_code, 2) == 0
    end

    %Identicon.Image{image | grid: grid}
  end

  defp build_pixel_map(%Identicon.Image{grid: grid} = image) do
    pixel_map = Enum.map grid, fn({_hex_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50
      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Identicon.Image{image | pixel_map: pixel_map}
  end

  defp draw_image(%Identicon.Image{rgb: rgb, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(rgb)

    Enum.each pixel_map, fn({top_left, bottom_right}) ->
      :egd.filledRectangle(image, top_left, bottom_right, fill)
    end

    :egd.render(image)
  end

  defp save_image(image, filename) do
    File.write("#{filename}.png", image)
  end

  defp generate_rgb_color(%Identicon.Image{hex: [r, g, b | _tail]} = image) do
    %Identicon.Image{image | rgb: {r, g, b}}    
  end

end
