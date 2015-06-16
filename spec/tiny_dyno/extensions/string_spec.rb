require "spec_helper"

describe TinyDyno::Extensions::String do

  # describe "#__mongoize_time__" do
  #
  #   context "when using active support's time zone" do
  #
  #     before do
  #       TinyDyno.use_activesupport_time_zone = true
  #       ::Time.zone = "Tokyo"
  #     end
  #
  #     after do
  #       ::Time.zone = "Berlin"
  #     end
  #
  #     context "when the string is a valid time" do
  #
  #       let(:string) do
  #         "2010-11-19 00:24:49 +0900"
  #       end
  #
  #       let(:time) do
  #         string.__mongoize_time__
  #       end
  #
  #       it "converts to a time" do
  #         expect(time).to eq(Time.configured.parse(string))
  #       end
  #
  #       it "converts to the as time zone" do
  #         expect(time.zone).to eq("JST")
  #       end
  #     end
  #
  #     context "when the string is an invalid time" do
  #
  #       let(:string) do
  #         "shitty string"
  #       end
  #
  #       it "raises an error" do
  #         expect {
  #           string.__mongoize_time__
  #         }.to raise_error(ArgumentError)
  #       end
  #     end
  #   end
  #
  #   context "when not using active support's time zone" do
  #
  #     before do
  #       Mongoid.use_activesupport_time_zone = false
  #     end
  #
  #     after do
  #       Mongoid.use_activesupport_time_zone = true
  #       Time.zone = nil
  #     end
  #
  #     context "when the string is a valid time" do
  #
  #       let(:string) do
  #         "2010-11-19 00:24:49 +0900"
  #       end
  #
  #       let(:time) do
  #         string.__mongoize_time__
  #       end
  #
  #       it "converts to a time" do
  #         expect(time).to eq(Time.parse(string))
  #       end
  #     end
  #
  #     context "when the string is an invalid time" do
  #
  #       let(:string) do
  #         "shitty string"
  #       end
  #
  #       it "raises an error" do
  #         expect {
  #           string.__mongoize_time__
  #         }.to raise_error(ArgumentError)
  #       end
  #     end
  #   end
  # end

  describe ".from_dyno" do

    context "when the object is not a string" do

      it "returns the string" do
        expect(String.from_dyno(:test)).to eq("test")
      end
    end

    context "when the object is nil" do

      it "returns nil" do
        expect(String.from_dyno(nil)).to be_nil
      end
    end
  end

  describe ".to_dyno" do

    context "when the object is not a string" do

      it "returns the string" do
        expect(String.to_dyno(:test)).to eq("test")
      end
    end

    context "when the object is nil" do

      it "returns nil" do
        expect(String.to_dyno(nil)).to be_nil
      end
    end
  end

  describe "#mongoize" do

    it "returns self" do
      expect("test".to_dyno).to eq("test")
    end
  end

  describe "#reader" do

    context "when string is a reader" do

      it "returns self" do
        expect("attribute".reader).to eq("attribute")
      end
    end

    context "when string is a writer" do

      it "returns the reader" do
        expect("attribute=".reader).to eq("attribute")
      end
    end

    context "when the string is before_type_cast" do

      it "returns the reader" do
        expect("attribute_before_type_cast".reader).to eq("attribute")
      end
    end
  end

  describe "#numeric?" do

    context "when the string is an integer" do

      it "returns true" do
        expect("1234").to be_numeric
      end
    end

    context "when string is a float" do

      it "returns true" do
        expect("1234.123").to be_numeric
      end
    end

    context "when the string is has exponents" do

      it "returns true" do
        expect("1234.123123E4").to be_numeric
      end
    end

    context "when the string is non numeric" do

      it "returns false" do
        expect("blah").to_not be_numeric
      end
    end
  end

  describe "#singularize" do

    context "when string is address" do

      it "returns address" do
        expect("address".singularize).to eq("address")
      end
    end

    context "when string is address_profiles" do

      it "returns address_profile" do
        expect("address_profiles".singularize).to eq("address_profile")
      end
    end
  end

  describe "#writer?" do

    context "when string is a reader" do

      it "returns false" do
        expect("attribute".writer?).to be false
      end
    end

    context "when string is a writer" do

      it "returns true" do
        expect("attribute=".writer?).to be true
      end
    end
  end

  describe "#before_type_cast?" do

    context "when string is a reader" do

      it "returns false" do
        expect("attribute".before_type_cast?).to be false
      end
    end

    context "when string is before_type_cast" do

      it "returns true" do
        expect("attribute_before_type_cast".before_type_cast?).to be true
      end
    end
  end

end
