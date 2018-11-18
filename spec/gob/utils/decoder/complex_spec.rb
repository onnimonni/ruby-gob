RSpec.describe Gob::Utils::Decoder do
  context "complex" do
    context "(2+3i)" do

      let!(:content) { "\u0006\u000E\u0000@\xFE\b@" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [6,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :complex
      end

      it "returns correct complex number with imaginary part" do
        skip "This is not implemented yet"
        expect(decoder.decode).to eq Complex(2, 3)
      end
    end
  end
end