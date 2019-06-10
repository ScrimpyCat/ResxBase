defmodule ResxBase.DecoderTest do
    use ExUnit.Case

    test "invalid encoding type" do
        resource = Resx.Resource.open!("data:,foo")

        assert { :error, { :internal, "Unknown encoding format: nil" } } == Resx.Resource.transform(resource, ResxBase.Encoder)
        assert { :error, { :internal, "Unknown encoding format: :foo" } } == Resx.Resource.transform(resource, ResxBase.Encoder, encoding: :foo)
    end

    describe "valid decoding" do
        test "base16" do
            assert "foo" == (Resx.Resource.open!("data:,#{Base.encode16("foo")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16) |> Resx.Resource.finalise!).content.data
            assert "foo" == (Resx.Resource.open!("data:,#{Base.encode16("foo", case: :upper)}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, case: :upper) |> Resx.Resource.finalise!).content.data
            assert "foo" == (Resx.Resource.open!("data:,#{Base.encode16("foo", case: :lower)}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, case: :lower) |> Resx.Resource.finalise!).content.data

            assert "fo" == (Resx.Resource.open!("data:,#{Base.encode16("fo")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16) |> Resx.Resource.finalise!).content.data
            assert "fo" == (Resx.Resource.open!("data:,#{Base.encode16("fo", case: :upper)}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, case: :upper) |> Resx.Resource.finalise!).content.data
            assert "fo" == (Resx.Resource.open!("data:,#{Base.encode16("fo", case: :lower)}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, case: :lower) |> Resx.Resource.finalise!).content.data

            assert "f" == (Resx.Resource.open!("data:,#{Base.encode16("f")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16) |> Resx.Resource.finalise!).content.data
            assert "f" == (Resx.Resource.open!("data:,#{Base.encode16("f", case: :upper)}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, case: :upper) |> Resx.Resource.finalise!).content.data
            assert "f" == (Resx.Resource.open!("data:,#{Base.encode16("f", case: :lower)}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, case: :lower) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new("")
            resource = %{ resource | content: %{ Resx.Resource.Content.Stream.new(resource.content) | data: [Base.encode16("f"), Base.encode16("oo")] } }
            assert "foo" == (Resx.Resource.transform!(resource, ResxBase.Decoder, encoding: :base16) |> Resx.Resource.finalise!).content.data

            assert <<0>> == (Resx.Resource.open!("data:,00") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16) |> Resx.Resource.finalise!).content.data
            assert <<0>> == (Resx.Resource.open!("data:,00") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<0>> == (Resx.Resource.open!("data:,00======") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, pad_chr: "=") |> Resx.Resource.finalise!).content.data
            assert "" == (Resx.Resource.open!("data:,0") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16) |> Resx.Resource.finalise!).content.data
            assert <<0 :: size(4)>> == (Resx.Resource.open!("data:,0") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<1 :: size(4)>> == (Resx.Resource.open!("data:,1") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<0 :: size(4)>> == (Resx.Resource.open!("data:,0=======") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base16, pad_chr: "=", bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
        end

        test "base32" do
            assert "foo" == (Resx.Resource.open!("data:,#{Base.encode32("foo")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base32) |> Resx.Resource.finalise!).content.data
            assert "fo" == (Resx.Resource.open!("data:,#{Base.encode32("fo")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base32) |> Resx.Resource.finalise!).content.data
            assert "f" == (Resx.Resource.open!("data:,#{Base.encode32("f")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base32) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new("")
            resource = %{ resource | content: %{ Resx.Resource.Content.Stream.new(resource.content) | data: [Base.encode32("f"), Base.encode32("oo")] } }
            assert "foo" == (Resx.Resource.transform!(resource, ResxBase.Decoder, encoding: :base32) |> Resx.Resource.finalise!).content.data

            assert <<0>> == (Resx.Resource.open!("data:,AA======") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base32) |> Resx.Resource.finalise!).content.data
            assert <<0, 0 :: size(2)>> == (Resx.Resource.open!("data:,AA") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base32, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<0>> == (Resx.Resource.open!("data:,AA******") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base32, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "" == (Resx.Resource.open!("data:,A") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base32) |> Resx.Resource.finalise!).content.data
            assert <<0 :: size(5)>> == (Resx.Resource.open!("data:,A") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base32, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<1 :: size(5)>> == (Resx.Resource.open!("data:,B") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base32, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<0 :: size(5)>> == (Resx.Resource.open!("data:,A=======") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base32, pad_chr: "=", bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
        end

        test "base64" do
            assert "foo" == (Resx.Resource.open!("data:,#{Base.encode64("foo")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base64) |> Resx.Resource.finalise!).content.data
            assert "fo" == (Resx.Resource.open!("data:,#{Base.encode64("fo")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base64) |> Resx.Resource.finalise!).content.data
            assert "f" == (Resx.Resource.open!("data:,#{Base.encode64("f")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base64) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new("")
            resource = %{ resource | content: %{ Resx.Resource.Content.Stream.new(resource.content) | data: [Base.encode64("f"), Base.encode64("oo")] } }
            assert "foo" == (Resx.Resource.transform!(resource, ResxBase.Decoder, encoding: :base64) |> Resx.Resource.finalise!).content.data

            assert <<0>> == (Resx.Resource.open!("data:,AA==") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base64) |> Resx.Resource.finalise!).content.data
            assert <<0, 0 :: size(4)>> == (Resx.Resource.open!("data:,AA") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base64, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<0>> == (Resx.Resource.open!("data:,AA**") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base64, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "" == (Resx.Resource.open!("data:,A") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base64) |> Resx.Resource.finalise!).content.data
            assert <<0 :: size(6)>> == (Resx.Resource.open!("data:,A") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base64, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<1 :: size(6)>> == (Resx.Resource.open!("data:,B") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base64, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<0 :: size(6)>> == (Resx.Resource.open!("data:,A===") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :base64, pad_chr: "=", bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
        end

        test "hex32" do
            assert "foo" == (Resx.Resource.open!("data:,#{Base.hex_encode32("foo")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data
            assert "fo" == (Resx.Resource.open!("data:,#{Base.hex_encode32("fo")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data
            assert "f" == (Resx.Resource.open!("data:,#{Base.hex_encode32("f")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new("")
            resource = %{ resource | content: %{ Resx.Resource.Content.Stream.new(resource.content) | data: [Base.hex_encode32("f"), Base.hex_encode32("oo")] } }
            assert "foo" == (Resx.Resource.transform!(resource, ResxBase.Decoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data

            assert <<0>> == (Resx.Resource.open!("data:,00======") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data
            assert <<0, 0 :: size(2)>> == (Resx.Resource.open!("data:,00") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :hex32, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<0>> == (Resx.Resource.open!("data:,00******") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :hex32, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "" == (Resx.Resource.open!("data:,0") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :hex32) |> Resx.Resource.finalise!).content.data
            assert <<0 :: size(5)>> == (Resx.Resource.open!("data:,0") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :hex32, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<1 :: size(5)>> == (Resx.Resource.open!("data:,1") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :hex32, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<0 :: size(5)>> == (Resx.Resource.open!("data:,0=======") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :hex32, pad_chr: "=", bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
        end

        test "url64" do
            assert "foo" == (Resx.Resource.open!("data:,#{Base.url_encode64("foo")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :url64) |> Resx.Resource.finalise!).content.data
            assert "fo" == (Resx.Resource.open!("data:,#{Base.url_encode64("fo")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :url64) |> Resx.Resource.finalise!).content.data
            assert "f" == (Resx.Resource.open!("data:,#{Base.url_encode64("f")}") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :url64) |> Resx.Resource.finalise!).content.data

            { :ok, resource } = Resx.Producers.Data.new("")
            resource = %{ resource | content: %{ Resx.Resource.Content.Stream.new(resource.content) | data: [Base.url_encode64("f"), Base.url_encode64("oo")] } }
            assert "foo" == (Resx.Resource.transform!(resource, ResxBase.Decoder, encoding: :url64) |> Resx.Resource.finalise!).content.data

            assert <<0>> == (Resx.Resource.open!("data:,AA==") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :url64) |> Resx.Resource.finalise!).content.data
            assert <<0, 0 :: size(4)>> == (Resx.Resource.open!("data:,AA") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :url64, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<0>> == (Resx.Resource.open!("data:,AA**") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :url64, pad_chr: "*") |> Resx.Resource.finalise!).content.data
            assert "" == (Resx.Resource.open!("data:,A") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :url64) |> Resx.Resource.finalise!).content.data
            assert <<0 :: size(6)>> == (Resx.Resource.open!("data:,A") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :url64, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<1 :: size(6)>> == (Resx.Resource.open!("data:,B") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :url64, bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
            assert <<0 :: size(6)>> == (Resx.Resource.open!("data:,A===") |> Resx.Resource.transform!(ResxBase.Decoder, encoding: :url64, pad_chr: "=", bits: true) |> Resx.Resource.finalise!(hash: false)).content.data
        end
    end
end
