require 'ostruct'

RSpec.describe Gob::Utils::Decoder do
  context "ArrayType" do
    context "[0,1,2,3,4,5]" do

      let!(:content) { "\u000E\xFF\x81\u0001\u0001\u0002\xFF\x82\u0000\u0001\u0004\u0001\f\u0000\u0000\n\xFF\x82\u0000\u0006\u0000\u0002\u0004\u0006\b\n" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [14,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :ArrayType
      end

      it "returns corresponding OpenStruct" do
        expect(decoder.decode).to eq [0,1,2,3,4,5]
      end
    end
  end
end