require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
RSpec::Core::RakeTask.new(:remote) do |t|
  t.rspec_opts = '--tag remote'
end
task :default => :spec

namespace :travis do
  desc 'load .env variables into travis env'
  task :env do
    # use this to push variables to travis
    # the names are the lower case names of the env
    # variables set in your .env file
    # %w{env_var_name}.each do |w|
    #   key = w.upcase
    #   `travis env set -- #{key} '#{ENV[key]}'`
    # end
  end
end

task :run do
  sh "slnky service run route53"
end
