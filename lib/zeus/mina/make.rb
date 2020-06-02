# frozen_string_literal: true

# @example invoke :make, 'docker:push'
# @example invoke :make, 'docker:push', 'APP_ENV=staging'
desc 'Execute a Make file command'
task :make, %i[command env] do |_t, argv|
  system "#{argv.env} make #{argv.command}", exception: true
end
