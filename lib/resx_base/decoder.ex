defmodule ResxBase.Decoder do
    use Resx.Transformer

    alias Resx.Resource.Content

    defmodule DecodingError do
        defexception [:message, :resource, :data, :options]

        @impl Exception
        def exception({ resource, data, options }) do
            %DecodingError{
                message: "failed to decode the resource with a #{inspect options[:encoding]} decoder",
                resource: resource,
                data: data,
                options: options
            }
        end
    end

    @impl Resx.Transformer
    def transform(resource, opts) do
        decode = case opts[:encoding] do
            :base16 ->
                case opts[:case] || :upper do
                    :lower -> &ResxBase.decode16_lower(&1, opts)
                    :mixed -> &ResxBase.decode16_upper(String.upcase(&1), opts)
                    :upper -> &ResxBase.decode16_upper(&1, opts)
                end
                |> decoder(opts)
            base32 when base32 in [:base32, :hex32]  ->
                decoding_opts = opts ++ [pad_chr: "="]
                case base32 do
                    :base32 -> &ResxBase.decode32(&1, decoding_opts)
                    :hex32 -> &ResxBase.hex_decode32(&1, decoding_opts)
                end
                |> decoder(decoding_opts)
            base64 when base64 in [:base64, :url64]  ->
                decoding_opts = opts ++ [pad_chr: "="]
                case base64 do
                    :base64 -> &ResxBase.decode64(&1, decoding_opts)
                    :url64 -> &ResxBase.url_decode64(&1, decoding_opts)
                end
                |> decoder(decoding_opts)
            encoding -> fn _ -> { :error, { :internal, "Unknown encoding format: #{inspect(encoding)}" } } end
        end

        decode.(resource)
    end

    defp decoder(fun, opts) do
        fn resource = %{ content: content } ->
            content = Content.Stream.new(content)
            data = Stream.map(content, fn data ->
                case fun.(data) do
                    { :ok, data } -> data
                    :error -> raise DecodingError, { resource, data, opts }
                end
            end)
            { :ok, %{ resource | content: %{ content | data: data } } }
        end
    end
end
