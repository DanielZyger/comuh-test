class SentimentAnalyzer
  POSITIVE_WORDS = %w[ótimo excelente legal bom adorei incrível].freeze
  NEGATIVE_WORDS = %w[ruim péssimo horrível terrível odeio].freeze

  def self.call(text)
    new(text).call
  end

  def initialize(text)
    @text = text.to_s.downcase
  end

  def call
    positive = POSITIVE_WORDS.count { |word| @text.include?(word) }
    negative = NEGATIVE_WORDS.count { |word| @text.include?(word) }
    total = positive + negative

    return 0.0 if total.zero?

    ((positive - negative).to_f / total).round(2)
  end
end
