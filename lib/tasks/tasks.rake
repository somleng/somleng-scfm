namespace :task do
  namespace :callout do
    desc "Invokes EnqueueCallsTask#run!"
    task :run => :environment do
      EnqueueCallsTask.new.run!
    end
  end

  namespace :phone_call_updater do
    desc "Invokes PhoneCallUpdaterTask#run!"
    task :run => :environment do
      PhoneCallUpdaterTask.new.run!
    end
  end

  namespace :rapidpro_start_flow do
    desc "Invokes RapidproStartFlowTask#run!"
    task :run => :environment do
      RapidproStartFlowTask.new.run!
    end
  end
end
