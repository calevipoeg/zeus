require_relative 'lib/zeus/version'

Gem::Specification.new do |spec|
  spec.name          = 'calevipoeg-zeus'
  spec.version       = Zeus::VERSION
  spec.authors       = ['Aliaksandr Shylau']
  spec.email         = %w[alex.shilov.by@gmail.com]

  spec.summary       = 'Helper package for own projects'
  spec.description   = 'Helper package for own projects'
  spec.homepage      = 'https://github.com/calevipoeg/zeus'
  spec.license       = 'MIT'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/calevipoeg/zeus'
  spec.metadata['changelog_uri'] = 'https://github.com/calevipoeg/zeus'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]
end
