require 'spec_helper'

# :nocov:
begin
  require 'rake'
rescue LoadError
  puts 'Skipping Rake integration specs'
end
# :nocov:

if defined?(Rake)
  RSpec.describe 'Rake integration', start_without_worker: true do
    before :context do
      Rake.application = Rake::Application.new
      Rake.application.rake_require('rakefile', [File.join(File.dirname(__FILE__), 'rake')])
    end

    it 'captures and reports exceptions to Opbeat' do
      expect do
        Rake.application.invoke_task('raise_error[12,11]')
      end.to raise_error(Exception).with_message('exception')

      expect(Opbeat::Client.inst.queue.length).to be 1
    end

    it 'captures and reports exceptions in dependent tasks to Opbeat' do
      expect do
        Rake.application.invoke_task('depends_on_raise_error[12,11]')
      end.to raise_error(Exception).with_message('exception2')

      expect(Opbeat::Client.inst.queue.length).to be 1
    end
  end
end
