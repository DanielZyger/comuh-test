module Api
  module V1
    class AnalyticsController < ApplicationController
      DEFAULT_MIN_USERS = 3

      def suspicious_ips
        min_users = (params[:min_users].presence || DEFAULT_MIN_USERS).to_i

        render json: { suspicious_ips: SuspiciousIpsQuery.new(min_users: min_users).call }
      end
    end
  end
end
