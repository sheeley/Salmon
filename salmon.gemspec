require File.expand_path('../lib/salmon/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name               = 'salmon'
  gem.version            = Salmon::VERSION
  gem.summary            = "A migration tool for Github accounts and organizations."
  gem.description        = "A migration tool for Github accounts and organizations."
  gem.authors            = ["Johnny Sheeley"]
  gem.email              = 'jsheeley@aigee.org'
  gem.homepage           = 'https://github.com/sheeley/Salmon'
  gem.files              = ['README.md', 'LICENSE', 'lib/salmon.rb', 'bin/salmon'] + Dir['lib/**/*.rb']
  # gem.test_files    = Dir['spec/**/*.rb']
  gem.require_paths      = ["lib"]
  gem.executables        = ['salmon']
  gem.default_executable = 'salmon'
  gem.license            = 'MIT'

  gem.add_runtime_dependency 'github_api', '~>0.10.2'
end
