module Api
  module V1
    class ReactionsController < ApplicationController
      rescue_from ActiveRecord::RecordNotUnique, with: :render_duplicate_reaction

      def create
        message = Message.find(params.fetch(:message_id))
        user = current_user || User.find(params.fetch(:user_id))

        message.reactions.create!(user: user, reaction_type: params.fetch(:reaction_type))

        render json: reaction_counts(message), status: :ok
      end

      def destroy
        message = Message.find(params.fetch(:message_id))
        user = current_user || User.find(params.fetch(:user_id))

        message.reactions.find_by!(user: user, reaction_type: params.fetch(:reaction_type)).destroy!

        render json: reaction_counts(message), status: :ok
      end

      private

      def reaction_counts(message)
        counts = message.reactions.group(:reaction_type).count

        {
          message_id: message.id,
          reactions: Reaction::REACTION_TYPES.index_with { |type| counts.fetch(type, 0) }
        }
      end

      def render_duplicate_reaction(_exception)
        render json: { error: "Você já reagiu com esse tipo de reação nesta mensagem." }, status: :conflict
      end
    end
  end
end
