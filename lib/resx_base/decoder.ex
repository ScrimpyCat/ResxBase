defmodule ResxBase.Decoder do
    @moduledoc """
      Decode data resources from a RFC 4648 encoding.

      ### Decoding

      The type of decoding is specified by using the `:encoding` option.

        Resx.Resource.transform(resource, ResxBase.Decoder, encoding: :base64)

      The list of available decoding formats to choose from are:

      * `:base16` - By default this works the same as `Base.decode16/1`.
      Optionally the case can be specified using the `:case` option, this can
      be either `:lower` (for lowercase input) or `:upper` (for uppercase input)
      or `:mixed` (for case-insensitive input).
      * `:base32` - By default this works the same as `Base.encode32/1`.
      * `:base64` - By default this works the same as `Base.encode64/1`.
      * `:hex32` - By default this works the same as `Base.hex_encode32/1`.
      * `:url64` - By default this works the same as `Base.url_encode64/1`.

      All decodings also take the configuration options specified in `ResxBase`.

      ### Streams

      Streamed data is expected to be made up of individual complete encoding
      sequences. Where each encoding is decoded as-is in the stream.

      e.g. If you had the encoded data `"aGVsbG8=IA==d29ybGQ="` this would be
      decoded to: `"hello world"`. However if it was a stream consisting of
      `["aGVsbG8=", "IA==", "d29ybGQ="]`, it would be decoded as:
      `["hello", " ", "world"]`.
    """
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
