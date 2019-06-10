defmodule ResxBase.Encoder do
    @moduledoc """
      Encode data resources into a RFC 4648 encoding.

      ### Encoding

      The type of encoding is specified by using the `:encoding` option.

        Resx.Resource.transform(resource, ResxBase.Encoder, encoding: :base64)

      The list of available encoding formats to choose from are:

      * `:base16` - By default this works the same as `Base.encode16/1`.
      Optionally the case can be specified using the `:case` option, this can
      be either `:lower` (for lowercase output) or `:upper` (for uppercase
      output).
      * `:base32` - By default this works the same as `Base.encode32/1`.
      * `:base64` - By default this works the same as `Base.encode64/1`.
      * `:hex32` - By default this works the same as `Base.hex_encode32/1`.
      * `:url64` - By default this works the same as `Base.url_encode64/1`.

      All encodings also take the configuration options specified in `ResxBase`.

      ### Streams

      Streams are encoded by forming a complete sequence and separating each
      encoded sequence with the necessary amount of padding characters.

      e.g. If you encoded `"hello world"` as a single base64 sequence you would
      end up with the encoded data: `"aGVsbG8gd29ybGQ="`. However if it was a
      stream consisting of `["hello", " ", "world"]`, it would be encoded as 3
      individual sequences resulting in the encoded data: `"aGVsbG8=IA==d29ybGQ="`
    """
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
