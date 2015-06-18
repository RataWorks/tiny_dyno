require "spec_helper"

describe TinyDyno::Extensions::Integer do

  let(:number) do
    118347652312341
  end

  describe "#__to_dyno_time__" do

    let(:integer) do
      1335532685
    end

    let(:to_dynod) do
      integer.__to_dyno_time__
    end

    it "returns the float as a time" do
      expect(to_dynod).to eq(Time.at(integer))
    end
  end

end
