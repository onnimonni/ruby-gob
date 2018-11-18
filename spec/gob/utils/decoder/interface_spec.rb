RSpec.describe Gob::Utils::Decoder do
  context "interface" do
    context "&{}" do

      before(:each) { skip "Not implemented yet" }

      let!(:content) { "\u000F\xFF\x81\u0003\u0001\u0001\u0003Cat\u0001\xFF\x82\u0000\u0000\u0000\u0003\xFF\x82\u0000" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [15,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :interface
      end

      it "returns empty interface" do
        expect(decoder.decode).to be "?????????"
      end
    end
  end
end