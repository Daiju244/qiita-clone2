ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  address: 'smtp.gmail.com',
  domain: 'gmail.com',
  port: 587,
#   6行目がGmailのメールアドレス、7行目がアプリパスワードです。ここに直書きしてしまうとGithubから簡単にパスワードが漏洩してしまうので、credentialsを使います。ターミナルで以下を実行し、credentialsを設定しましょう。
#   user_name: Rails.application.credentials.gmail[:mail_address],
#   password: Rails.application.credentials.gmail[:mail_password],
  authentication: 'plain',
  enable_starttls_auto: true
}