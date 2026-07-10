require "rails_helper"

RSpec.describe SentimentAnalyzer do
  describe ".call" do
    it "returns 0.0 for text with no sentiment keywords" do
      expect(described_class.call("Uma mensagem qualquer sem palavras-chave")).to eq(0.0)
    end

    it "returns 0.0 for an empty string" do
      expect(described_class.call("")).to eq(0.0)
    end

    it "returns 1.0 for text with only positive keywords" do
      expect(described_class.call("Que dia ótimo e excelente")).to eq(1.0)
    end

    it "returns -1.0 for text with only negative keywords" do
      expect(described_class.call("Isso foi ruim e péssimo")).to eq(-1.0)
    end

    it "returns 0.0 when positive and negative keywords balance out" do
      expect(described_class.call("Foi bom mas também ruim")).to eq(0.0)
    end

    it "weighs more positive than negative keywords toward a positive score" do
      score = described_class.call("ótimo, excelente, adorei, mas também ruim")

      expect(score).to be > 0
    end

    it "is case-insensitive" do
      expect(described_class.call("ÓTIMO E EXCELENTE")).to eq(1.0)
    end
  end
end
