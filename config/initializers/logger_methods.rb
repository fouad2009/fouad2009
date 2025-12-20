Rails.application.config.after_initialize do
  class ::Logger
    ::Logger::Severity.constants.each do |severity|
      define_method("#{severity.downcase}?") do
        ::Logger::Severity.const_get(severity) >= level
      end
    end
  end
end

