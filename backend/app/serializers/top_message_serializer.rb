class TopMessageSerializer
  def initialize(result)
    @result = result
  end

  def as_json(*)
    message = result.message

    {
      id: message.id,
      content: message.content,
      user: { id: message.user_id, username: message.user.username },
      ai_sentiment_score: message.ai_sentiment_score,
      reaction_count: result.reaction_count,
      reply_count: result.reply_count,
      engagement_score: result.engagement_score
    }
  end

  private

  attr_reader :result
end
