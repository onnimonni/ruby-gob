RSpec.describe Gob::Utils::Decoder do
  context "uint" do
    context "maximum 64 bit uint" do

      let!(:content) { "\v\x06\x00\xF8\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [11,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :uint
      end

      it "returns correct positive number" do
        expect(decoder.decode).to eq 18446744073709551615
      end
    end
  end
end