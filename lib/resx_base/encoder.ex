defmodule ResxBase.Encoder do
    use Resx.Transformer

    alias Resx.Resource.Content

    @impl Resx.Transformer
    def transform(resource, opts) do
        encode = case opts[:encoding] do
            :base16 ->
                case opts[:case] || :upper do
                    :lower -> &ResxBase.encode16_lower(&1, opts)
                    :upper -> &ResxBase.encode16_upper(&1, opts)
                end
                |> encoder
            base32 when base32 in [:base32, :hex32]  ->
                encoding_opts = opts ++ [pad_chr: "=", multiple: 8]
                case base32 do
                    :base32 -> &ResxBase.encode32(&1, encoding_opts)
                    :hex32 -> &ResxBase.hex_encode32(&1, encoding_opts)
                end
                |> encoder
            base64 when base64 in [:base64, :url64]  ->
                encoding_opts = opts ++ [pad_chr: "=", multiple: 4]
                case base64 do
                    :base64 -> &ResxBase.encode64(&1, encoding_opts)
                    :url64 -> &ResxBase.url_encode64(&1, encoding_opts)
                end
                |> encoder
            encoding -> fn _ -> { :error, { :internal, "Unknown encoding format: #{inspect(encoding)}" } } end
        end

        encode.(resource)
    end

    defp encoder(fun) do
        fn resource = %{ content: content } ->
            content = Content.Stream.new(content)
            { :ok, %{ resource | content: %{ content | data: Stream.map(content, fun) } } }
        end
    end
end
