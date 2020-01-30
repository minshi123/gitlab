if Rails.env.development?
  Rails.application.config.hosts << Gitlab.config.gitlab.host
end
