RSpec.describe Gob::Utils::Decoder do
  context "int" do
    context "5" do
      let!(:decoder) { Gob::Utils::Decoder.new("\x03\x04\x00\n") }

      it "returns correct positive number" do
        expect(decoder.decode).to be 5
      end
    end
    context "-5" do
      let!(:decoder) { Gob::Utils::Decoder.new("\x03\x04\x00\t") }

      it "returns correct positive number" do
        expect(decoder.decode).to be -5
      end
    end
    context "1000" do

      let!(:content) { "\x05\x04\x00\xFE\a\xD0" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [5,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :int
      end

      it "returns correct positive number" do
        expect(decoder.decode).to be 1000
      end
    end

    context "-1000" do

      let!(:content) { "\x05\x04\x00\xFE\a\xCF" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [5,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :int
      end

      it "returns correct negative number" do
        expect(decoder.decode).to be -1000
      end
    end
  end
end