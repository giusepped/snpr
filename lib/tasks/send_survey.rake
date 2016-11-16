namespace :survey do
  desc 'send survey'
  task :send => :environment do
    # invoke script with rake survey:send EXCLUDEFILE=/path/to/file.txt
    # read list of users to exclude
    # should contain one user-ID per line
    if ENV['EXCLUDEFILE']
      exclude_users = File.readlines(ENV['EXCLUDEFILE']).map { |l| l.chomp! }
    else
      exclude_users = []
    end

    # send survey to each user that
    # a) allows us emailing them
    # b) has genetic data
    # c) is not already in the DB
    User.where(:message_on_newsletter => true).find_each do |u|
      unless exclude_users.include?u.id.to_s
        if u.genotypes.length > 0
          UserMailer.survey(u).deliver_now
          # wait for one minute so we don't crash the google mail daily limit
          sleep(1.minute)
        end
      end
    end
  end
end
