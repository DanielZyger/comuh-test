class MessageSummaryCollection
  def initialize(messages)
    @messages = messages.to_a
  end

  def as_json
    messages.map { |message| serialize(message) }
  end

  private

  attr_reader :messages

  def serialize(message)
    {
      id: message.id,
      content: message.content,
      user: { id: message.user_id, username: message.user.username },
      community_id: message.community_id,
      ai_sentiment_score: message.ai_sentiment_score,
      reactions: Reaction::REACTION_TYPES.index_with { |type| reactions_by_message.dig(message.id, type) || 0 },
      reply_count: reply_counts_by_message.fetch(message.id, 0),
      created_at: message.created_at.iso8601
    }
  end

  def reactions_by_message
    @reactions_by_message ||= Reaction.where(message_id: message_ids)
      .group(:message_id, :reaction_type)
      .count
      .each_with_object(Hash.new { |hash, key| hash[key] = {} }) do |((message_id, type), count), acc|
        acc[message_id][type] = count
      end
  end

  def reply_counts_by_message
    @reply_counts_by_message ||= Message.where(parent_message_id: message_ids).group(:parent_message_id).count
  end

  def message_ids
    @message_ids ||= messages.map(&:id)
  end
end
