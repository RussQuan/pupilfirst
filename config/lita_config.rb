Lita.configure do |config|
  # The name your robot will use.
  config.robot.name = 'Vocalist'
  config.robot.mention_name = 'vocalist'

  config.robot.alias = '!'

  config.robot.adapter = :slack
  config.adapters.slack.token = ENV['SLACK_TOKEN']

  config.redis = { url: ENV['REDIS_URL'] }

  # The locale code for the language to use.
  config.robot.locale = :en

  # The severity of messages to log. Options are:
  # :debug, :info, :warn, :error, :fatal
  # Messages at the selected level and above will be logged.
  config.robot.log_level = ENV['LITA_DEBUG'] ? :debug : :info

  # An array of user IDs that are considered administrators. These users
  # the ability to add and remove other users from authorization groups.
  # What is considered a user ID will change depending on which adapter you use.
  config.robot.admins = ["U08U63H0Q", "U08TWENL9", "U0963MJLV"]
end
