RSpec.describe Gob::Utils::Decoder do
  context "[]byte" do
    context "{'g', 'o', 'l', 'a', 'n', 'g'}" do

      let!(:content) { "\t\n\u0000\u0006golang" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [9,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :byte_array
      end

      it "returns corresponding byte array" do
        expect(decoder.decode).to eq "golang".bytes
      end
    end

    context "empty byte array {}" do

      let!(:content) { "\u0003\n\u0000\u0000" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [3,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :byte_array
      end

      it "returns empty array" do
        expect(decoder.decode).to eq []
      end
    end
  end
end