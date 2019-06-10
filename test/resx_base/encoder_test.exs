defmodule ResxBase.EncoderTest do
    use ExUnit.Case

    test "invalid encoding type" do
        resource = Resx.Resource.open!("data:,foo")

        assert { :error, { :internal, "Unknown encoding format: nil" } } == Resx.Resource.transform(resource, ResxBase.Encoder)
        assert { :error, { :internal, "Unknown encoding format: :foo" } } == Resx.Resource.transform(resource, ResxBase.Encoder, encoding: :foo)
    end

    describe "valid encoding" do
        test "base16" do
            resource = Resx.Resource.open!("data:,foo")
            assert Base.encode16(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16) |> Resx.Resource.finalise!).content.data
            assert Base.encode16(resource.content.data, case: :upper) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, case: :upper) |> Resx.Resource.finalise!).content.data
            assert Base.encode16(resource.content.data, case: :lower) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, case: :lower) |> Resx.Resource.finalise!).content.data

            resource = Resx.Resource.open!("data:,fo")
            assert Base.encode16(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16) |> Resx.Resource.finalise!).content.data
            assert Base.encode16(resource.content.data, case: :upper) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, case: :upper) |> Resx.Resource.finalise!).content.data
            assert Base.encode16(resource.content.data, case: :lower) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, case: :lower) |> Resx.Resource.finalise!).content.data

            resource = Resx.Resource.open!("data:,f")
            assert Base.encode16(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16) |> Resx.Resource.finalise!).content.data
            assert Base.encode16(resource.content.data, case: :upper) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, case: :upper) |> Resx.Resource.finalise!).content.data
            assert Base.encode16(resource.content.data, case: :lower) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, case: :lower) |> Resx.Resource.finalise!).content.data

            resource = %{ resource | content: %{ Resx.Resource.Content.Stream.new(resource.content) | data: ["f", "oo"] } }
            assert Base.encode16(Enum.at(resource.content.data, 0)) <> Base.encode16(Enum.at(resource.content.data, 1)) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new(<<0>>)
            assert "00" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16) |> Resx.Resource.finalise!).content.data
            assert "00" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "00======" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, multiple: 8, pad_chr: "=") |> Resx.Resource.finalise!).content.data
            assert "00" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, pad_bit: 1) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new(<<0 :: size(1)>>)
            assert "0" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16) |> Resx.Resource.finalise!).content.data
            assert "0" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "0=======" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, multiple: 8, pad_chr: "=") |> Resx.Resource.finalise!).content.data
            assert "1" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base16, pad_bit: 1) |> Resx.Resource.finalise!).content.data
        end

        test "base32" do
            resource = Resx.Resource.open!("data:,foo")
            assert Base.encode32(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32) |> Resx.Resource.finalise!).content.data

            resource = Resx.Resource.open!("data:,fo")
            assert Base.encode32(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32) |> Resx.Resource.finalise!).content.data

            resource = Resx.Resource.open!("data:,f")
            assert Base.encode32(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32) |> Resx.Resource.finalise!).content.data

            resource = %{ resource | content: %{ Resx.Resource.Content.Stream.new(resource.content) | data: ["f", "oo"] } }
            assert Base.encode32(Enum.at(resource.content.data, 0)) <> Base.encode32(Enum.at(resource.content.data, 1)) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new(<<0>>)
            assert "AA======" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32) |> Resx.Resource.finalise!).content.data
            assert "AA******" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "AA" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32, multiple: 1) |> Resx.Resource.finalise!).content.data
            assert "AB======" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32, pad_bit: 1) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new(<<0 :: size(1)>>)
            assert "A=======" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32) |> Resx.Resource.finalise!).content.data
            assert "A*******" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "A" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32, multiple: 1) |> Resx.Resource.finalise!).content.data
            assert "B=======" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base32, pad_bit: 1) |> Resx.Resource.finalise!).content.data
        end

        test "base64" do
            resource = Resx.Resource.open!("data:,foo")
            assert Base.encode64(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64) |> Resx.Resource.finalise!).content.data

            resource = Resx.Resource.open!("data:,fo")
            assert Base.encode64(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64) |> Resx.Resource.finalise!).content.data

            resource = Resx.Resource.open!("data:,f")
            assert Base.encode64(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64) |> Resx.Resource.finalise!).content.data

            resource = %{ resource | content: %{ Resx.Resource.Content.Stream.new(resource.content) | data: ["f", "oo"] } }
            assert Base.encode64(Enum.at(resource.content.data, 0)) <> Base.encode64(Enum.at(resource.content.data, 1)) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new(<<0>>)
            assert "AA==" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64) |> Resx.Resource.finalise!).content.data
            assert "AA**" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "AA" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64, multiple: 1) |> Resx.Resource.finalise!).content.data
            assert "AB==" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64, pad_bit: 1) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new(<<0 :: size(1)>>)
            assert "A===" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64) |> Resx.Resource.finalise!).content.data
            assert "A***" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "A" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64, multiple: 1) |> Resx.Resource.finalise!).content.data
            assert "B===" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :base64, pad_bit: 1) |> Resx.Resource.finalise!).content.data
        end

        test "hex32" do
            resource = Resx.Resource.open!("data:,foo")
            assert Base.hex_encode32(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data

            resource = Resx.Resource.open!("data:,fo")
            assert Base.hex_encode32(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data

            resource = Resx.Resource.open!("data:,f")
            assert Base.hex_encode32(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data

            resource = %{ resource | content: %{ Resx.Resource.Content.Stream.new(resource.content) | data: ["f", "oo"] } }
            assert Base.hex_encode32(Enum.at(resource.content.data, 0)) <> Base.hex_encode32(Enum.at(resource.content.data, 1)) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new(<<0>>)
            assert "00======" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data
            assert "00******" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "00" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32, multiple: 1) |> Resx.Resource.finalise!).content.data
            assert "01======" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32, pad_bit: 1) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new(<<0 :: size(1)>>)
            assert "0=======" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data
            assert "0*******" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "0" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32, multiple: 1) |> Resx.Resource.finalise!).content.data
            assert "1=======" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :hex32, pad_bit: 1) |> Resx.Resource.finalise!).content.data
        end

        test "url64" do
            resource = Resx.Resource.open!("data:,foo")
            assert Base.url_encode64(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64) |> Resx.Resource.finalise!).content.data

            resource = Resx.Resource.open!("data:,fo")
            assert Base.url_encode64(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64) |> Resx.Resource.finalise!).content.data

            resource = Resx.Resource.open!("data:,f")
            assert Base.url_encode64(resource.content.data) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64) |> Resx.Resource.finalise!).content.data

            resource = %{ resource | content: %{ Resx.Resource.Content.Stream.new(resource.content) | data: ["f", "oo"] } }
            assert Base.url_encode64(Enum.at(resource.content.data, 0)) <> Base.url_encode64(Enum.at(resource.content.data, 1)) == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new(<<0>>)
            assert "AA==" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64) |> Resx.Resource.finalise!).content.data
            assert "AA**" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "AA" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64, multiple: 1) |> Resx.Resource.finalise!).content.data
            assert "AB==" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64, pad_bit: 1) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new(<<0 :: size(1)>>)
            assert "A===" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64) |> Resx.Resource.finalise!).content.data
            assert "A***" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "A" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64, multiple: 1) |> Resx.Resource.finalise!).content.data
            assert "B===" == (Resx.Resource.transform!(resource, ResxBase.Encoder, encoding: :url64, pad_bit: 1) |> Resx.Resource.finalise!).content.data
        end
    end
end
