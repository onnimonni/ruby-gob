RSpec.describe Gob::Utils::Decoder do
  context "float" do
    context "17.0" do

      let!(:content) { "\x05\b\x00\xFE1@" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [5,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :float
      end

      it "returns correct number" do
        expect(decoder.decode).to eq 17.0
      end
    end
  end

  context "float" do
    context "-17.0" do

      let!(:content) { "\x05\b\x00\xFE1\xC0" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [5,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :float
      end

      it "returns correct number" do
        expect(decoder.decode).to eq -17.0
      end
    end
  end
end