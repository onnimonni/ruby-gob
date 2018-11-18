require 'ostruct'

RSpec.describe Gob::Utils::Decoder do
  context "StructType" do
    context "Student{name: 'Foo Bar', age: 35}" do

      let!(:content) { "&\xFF\x81\u0003\u0001\u0001\aStudent\u0001\xFF\x82\u0000\u0001\u0002\u0001\u0004Name\u0001\f\u0000\u0001\u0003Age\u0001\u0004\u0000\u0000\u0000\u000E\xFF\x82\u0001\aFoo Bar\u0001F\u0000" }
      let!(:decoder) { Gob::Utils::Decoder.new(content) }

      it "has correct length according to bytes" do
        expect(decoder.content_byte_length).to eq [38,1]
      end

      it "has correct length" do
        expect(decoder.content_length_correct?).to be true
      end

      it "has correct type" do
        expect(decoder.type).to be :StructType
      end

      it "returns corresponding OpenStruct" do
        expect(decoder.decode).to eq OpenStruct.new(name: 'Foo Bar', age: 35)
      end
    end
  end
end