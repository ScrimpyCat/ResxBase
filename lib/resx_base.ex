defmodule ResxBase do
    require Itsy.Binary

    "0123456789ABCDEF"
    |> String.graphemes
    |> Enum.with_index
    |> Itsy.Binary.encoder(encode: :encode16_upper, decode: :decode16_upper, docs: false)

    "0123456789abcdef"
    |> String.graphemes
    |> Enum.with_index
    |> Itsy.Binary.encoder(encode: :encode16_lower, decode: :decode16_lower, docs: false)

    "ABCDEFGHIJKLMNOPQRSTUVWXYZ234567"
    |> String.graphemes
    |> Enum.with_index
    |> Itsy.Binary.encoder(encode: :encode32, decode: :decode32, docs: false)

    "0123456789ABCDEFGHIJKLMNOPQRSTUV"
    |> String.graphemes
    |> Enum.with_index
    |> Itsy.Binary.encoder(encode: :hex_encode32, decode: :hex_decode32, docs: false)

    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    |> String.graphemes
    |> Enum.with_index
    |> Itsy.Binary.encoder(encode: :encode64, decode: :decode64, docs: false)

    "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"
    |> String.graphemes
    |> Enum.with_index
    |> Itsy.Binary.encoder(encode: :url_encode64, decode: :url_decode64, docs: false)
end
