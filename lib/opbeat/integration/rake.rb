require 'rake'

module Rake
  class Task
    alias execute_without_opbeat execute

    def execute(args = nil)
      execute_without_opbeat(args)
    rescue Exception => e
      Opbeat.report(e, extra: {
        name: name,
        args: args,
        task_needed: needed?,
        prerequisites: prerequisite_tasks.sort_by(&:timestamp).join(', ')
      })
      raise e
    end
  end
end
