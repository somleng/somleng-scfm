namespace :task do
  namespace :enqueue_calls do
    desc "Invokes EnqueueCallsTask#run!"
    task :run => :environment do
      EnqueueCallsTask.new.run!
    end
  end

  namespace :update_calls do
    desc "Invokes UpdateCallsTask#run!"
    task :run => :environment do
      UpdateCallsTask.new.run!
    end
  end

  namespace :rapidpro_start_flow do
    desc "Invokes RapidproStartFlowTask#run!"
    task :run => :environment do
      RapidproStartFlowTask.new.run!
    end
  end
end
