RSpec.describe Gob::Utils::Decoder do
  context "float" do

    context "0.0" do
      let!(:content) { "\x03\b\x00\x00" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [3,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :float
      end

      it "returns correct number" do
        expect(decoder.decode).to be 0.0
      end

      it "returns float" do
        expect(decoder.decode.class).to eq Float
      end
    end

    context "1.0" do
      let!(:content) { "\x05\b\x00\xFE\xF0?" }
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
        expect(decoder.decode).to be 1.0
      end
    end

    context "-1.0" do
      let!(:content) { "\x05\b\x00\xFE\xF0\xBF" }
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
        expect(decoder.decode).to be -1.0
      end
    end

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

    context "math.MaxFloat64" do
      let!(:content) { "\v\b\x00\xF8\xFF\xFF\xFF\xFF\xFF\xFF\xEF\x7F" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [11,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :float
      end

      it "returns correct number" do
        expect(decoder.decode).to eq 1.7976931348623157e+308
      end
    end

    context "negative math.MaxFloat64" do
      let!(:content) { "\v\b\x00\xF8\xFF\xFF\xFF\xFF\xFF\xFF\xEF\xFF" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [11,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :float
      end

      it "returns correct number" do
        expect(decoder.decode).to eq -1.7976931348623157e+308
      end
    end
  end
end