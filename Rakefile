# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

DOCKER_IMAGE_NAME = "mrkn/railsdm2019_demo:latest"

namespace :model_learner do
  namespace :docker do
    desc "Build docker image of model learner"
    task :build do
      Dir.chdir Rails.root.join('model_learner') do
        sh "docker", "build", "-t", DOCKER_IMAGE_NAME, "."
      end
    end

    desc "Run model learner container"
    task :run do
      sh "docker", "run", "--rm", "-p", "24224:24224",
         "-v", "#{Rails.root.join("log/fluentd")}:/home/ubuntu/fluentd/log",
         DOCKER_IMAGE_NAME
    end
  end
end
