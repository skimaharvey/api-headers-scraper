class UserOtasScraperWorker
  include Sidekiq::Worker
  def perform(user_id)
    # Do something later
  end
end
