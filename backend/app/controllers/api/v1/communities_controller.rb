module Api
  module V1
    class CommunitiesController < ApplicationController
      DEFAULT_TOP_LIMIT = 10
      MAX_TOP_LIMIT = 50
      TIMELINE_LIMIT = 50

      def index
        communities = Community.order(:name)
        message_counts = Message.group(:community_id).count

        render json: {
          communities: communities.map { |community| community_summary(community, message_counts) }
        }
      end

      def show
        community = Community.find(params[:id])
        messages = community.messages
          .where(parent_message_id: nil)
          .order(created_at: :desc)
          .limit(TIMELINE_LIMIT)
          .includes(:user)

        render json: {
          community: { id: community.id, name: community.name, description: community.description },
          messages: MessageSummaryCollection.new(messages).as_json
        }
      end

      def top_messages
        community = Community.find(params[:id])
        messages = TopMessagesQuery.new(community, limit: resolved_top_limit).call

        render json: { messages: messages.map { |message| TopMessageSerializer.new(message).as_json } }
      end

      private

      def community_summary(community, message_counts)
        {
          id: community.id,
          name: community.name,
          description: community.description,
          message_count: message_counts.fetch(community.id, 0)
        }
      end

      def resolved_top_limit
        (params[:limit].presence || DEFAULT_TOP_LIMIT).to_i.clamp(1, MAX_TOP_LIMIT)
      end
    end
  end
end
