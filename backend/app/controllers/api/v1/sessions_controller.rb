module Api
  module V1
    class SessionsController < ApplicationController
      # Autenticação mínima por username
      # Apenas para dentificar quem está reagindo a uma mensagem, sem exigir uma tela de login
      def create
        user = User.find_or_create_by!(username: params.fetch(:username))
        token = JsonWebToken.encode(user_id: user.id)

        render json: { token: token, user: { id: user.id, username: user.username } }, status: :created
      end
    end
  end
end
