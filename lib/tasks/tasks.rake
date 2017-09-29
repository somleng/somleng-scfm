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

  namespace :start_flow_rapidpro do
    desc "Invokes StartFlowRapidpro#run!"
    task :run => :environment do
      StartFlowRapidpro.new.run!
    end
  end
end
