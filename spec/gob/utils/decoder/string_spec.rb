RSpec.describe Gob::Utils::Decoder do
  context "string" do
    context "lorem ipsum" do

      let!(:lorem_ipsum) { "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum." }
      let!(:content) { "\xFE\x02C\f\x00\xFE\x02>#{lorem_ipsum}" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [579,3]
      end

      it "has correct length according to bytes" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :string
      end

      it "returns correct string" do
        expect(decoder.decode).to eq lorem_ipsum
      end
    end

    context "Hello" do
      let!(:content) { "\x0F\f\x00\fHello World!" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [15,1]
      end

      it "has correct length according to bytes" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :string
      end

      it "returns correct string" do
        expect(decoder.decode).to eq "Hello World!"
      end
    end

    context "🐻🦊🐨🦁🐮🐷" do
      let!(:content) { "\e\f\x00\x18\xF0\x9F\x90\xBB\xF0\x9F\xA6\x8A\xF0\x9F\x90\xA8\xF0\x9F\xA6\x81\xF0\x9F\x90\xAE\xF0\x9F\x90\xB7" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [27,1]
      end

      it "has correct length according to bytes" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :string
      end

      it "returns correct string" do
        expect(decoder.decode).to eq "🐻🦊🐨🦁🐮🐷"
      end
    end
  end
end