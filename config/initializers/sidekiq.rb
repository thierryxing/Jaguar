# Init schedule job for scheduled environments
Sidekiq.configure_client do |config|
  Rails.application.config.after_initialize do
    puts "configure_client"
    begin
      Environment.scheduled.each do |env|
        env.set_build_schedule
      end
    rescue => e
      puts e.message
    end
  end
end