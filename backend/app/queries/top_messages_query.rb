class TopMessagesQuery
  Result = Struct.new(:message, :reaction_count, :reply_count, :engagement_score, keyword_init: true) do
    delegate :id, to: :message
  end

  def initialize(community, limit:)
    @community = community
    @limit = limit
  end

  def call
    messages = community.messages.where(parent_message_id: nil).includes(:user).to_a
    message_ids = messages.map(&:id)

    reaction_counts = Reaction.where(message_id: message_ids).group(:message_id).count
    reply_counts = Message.where(parent_message_id: message_ids).group(:parent_message_id).count

    results = messages.map { |message| build_result(message, reaction_counts, reply_counts) }

    results.sort_by { |result| -result.engagement_score }.first(limit)
  end

  private

  attr_reader :community, :limit

  def build_result(message, reaction_counts, reply_counts)
    reactions = reaction_counts.fetch(message.id, 0)
    replies = reply_counts.fetch(message.id, 0)

    Result.new(
      message: message,
      reaction_count: reactions,
      reply_count: replies,
      engagement_score: (reactions * 1.5 + replies * 1.0).round(2)
    )
  end
end
