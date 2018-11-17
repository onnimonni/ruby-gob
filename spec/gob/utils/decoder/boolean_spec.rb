RSpec.describe Gob::Utils::Decoder do
  context "boolean" do
    context "true" do

      let!(:content) { "\x03\x02\x00\x01" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [3,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :bool
      end

      it "returns true" do
        expect(decoder.decode).to be true
      end
    end

    context "false" do
      let!(:content) { "\x03\x02\x00\x00" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [3,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :bool
      end

      it "returns false" do
        expect(decoder.decode).to be false
      end
    end

    context "unknown byte" do
      let!(:content) { "\x03\x02\x00\x05" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [3,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :bool
      end

      it "throws an error" do
        expect { decoder.decode }.to raise_error(Gob::Utils::Decoder::DecodingError::ZeroMismatch)
      end
    end
  end
end