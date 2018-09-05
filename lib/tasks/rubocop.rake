return unless Rails.env.development? || Rails.env.test?

require 'rubocop/rake_task'

namespace 'rubocop' do
  desc 'run rubocop and store results on tmp file'
  RuboCop::RakeTask.new(:run) do |t|
    t.options = ['--config', '.rubocop.yml']
    t.formatters = ['worst']
    t.fail_on_error = true
  end
end

# after running specs
Rake::Task['spec'].enhance do
  # check if number of offenses increased
  Rake::Task['rubocop:run'].invoke
end
