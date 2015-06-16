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

  describe ".from_dyno" do

    context "when the the value is an integer" do

      it "returns a integer" do
        expect(Integer.from_dyno(number)).to eq(number)
      end
    end

    context "when the value is nil" do

      it "returns nil" do
        expect(Integer.from_dyno(nil)).to be_nil
      end
    end

    context "when the value is not an integer" do

      it "converts the value to an integer" do
        expect(Integer.from_dyno("1.0")).to eq(1)
      end
    end
  end

  describe ".to_dyno" do

    context "when the value is a number" do

      context "when the value is an integer" do

        context "when the value is small" do

          it "it returns the integer" do
            expect(Integer.to_dyno(3)).to eq(3)
          end
        end

        context "when the value is large" do

          it "returns the integer" do
            expect(Integer.to_dyno(1024**2).to_s).to eq("1048576")
          end
        end
      end

      context "when the value is a decimal" do

        it "casts to integer" do
          expect(Integer.to_dyno(2.5)).to eq(2)
        end
      end

      context "when the value is floating point zero" do

        it "returns the integer zero" do
          expect(Integer.to_dyno(0.00000)).to eq(0)
        end
      end

      context "when the value is a floating point integer" do

        it "returns the integer number" do
          expect(Integer.to_dyno(4.00000)).to eq(4)
        end
      end

      context "when the value has leading zeros" do

        it "returns the stripped integer" do
          expect(Integer.to_dyno("000011")).to eq(11)
        end
      end
    end

    context "when the string is not a number" do

      context "when the string is non numerical" do

        it "returns 0" do
          expect(Integer.to_dyno("foo")).to eq(0)
        end
      end

      context "when the string is numerical" do

        it "returns the integer value for the string" do
          expect(Integer.to_dyno("3")).to eq(3)
        end
      end

      context "when the string is empty" do

        it "returns nil" do
          expect(Integer.to_dyno("")).to be_nil
        end
      end

      context "when the string is nil" do

        it "returns nil" do
          expect(Integer.to_dyno(nil)).to be_nil
        end
      end
    end
  end
end
