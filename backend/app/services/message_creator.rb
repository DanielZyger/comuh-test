class MessageCreator
  def initialize(username: nil, community_id: nil, content: nil, user_ip: nil, parent_message_id: nil)
    @username = username
    @community_id = community_id
    @content = content
    @user_ip = user_ip
    @parent_message_id = parent_message_id
  end

  def call
    ActiveRecord::Base.transaction do
      user = User.find_or_create_by!(username: @username)

      Message.create!(
        user: user,
        community_id: @community_id,
        parent_message_id: @parent_message_id,
        content: @content,
        user_ip: @user_ip,
        ai_sentiment_score: SentimentAnalyzer.call(@content)
      )
    end
  end
end
