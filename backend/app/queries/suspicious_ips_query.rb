class SuspiciousIpsQuery
  def initialize(min_users:)
    @min_users = min_users
  end

  def call
    Message
      .joins(:user)
      .distinct
      .pluck(:user_ip, :username)
      .group_by { |user_ip, _username| user_ip }
      .filter_map { |user_ip, rows| build_entry(user_ip, rows) }
  end

  private

  attr_reader :min_users

  def build_entry(user_ip, rows)
    usernames = rows.map(&:last)
    return if usernames.size < min_users

    { ip: user_ip, user_count: usernames.size, usernames: usernames }
  end
end
