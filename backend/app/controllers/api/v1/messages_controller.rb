module Api
  module V1
    class MessagesController < ApplicationController
      def create
        message = MessageCreator.new(**message_params.to_h.symbolize_keys).call

        render json: MessageSerializer.new(message).as_json, status: :created
      end

      def show
        message = Message.includes(:user).find(params[:id])
        replies = message.replies.order(created_at: :asc).includes(:user)

        render json: {
          message: MessageSummaryCollection.new([ message ]).as_json.first,
          replies: MessageSummaryCollection.new(replies).as_json
        }
      end

      private

      def message_params
        params.permit(:username, :community_id, :content, :user_ip, :parent_message_id)
      end
    end
  end
end
