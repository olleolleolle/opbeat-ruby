require 'opbeat/integration/rake'

desc 'Prerequisite'
task :prereq do
  # No action.
end

desc 'Raise an error'
task :raise_error, [:strength, :wisdom] => [:prereq] do
  raise Exception, 'exception'
end

desc 'Raise another error'
task :raise_another_error, [:strength, :wisdom] => [:prereq] do
  raise Exception, 'exception2'
end

desc 'Depends on a task that raises another error'
task :depends_on_raise_error, [:strength, :wisdom] => [:raise_another_error] do
end