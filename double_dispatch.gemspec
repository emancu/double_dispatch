Gem::Specification.new do |s|
  s.name = 'double_dispatch'
  s.version = '1.0.0'
  s.date = Time.now.strftime('%Y-%m-%d')
  s.summary = 'Method overloading with runtime types made easy'
  s.description = 'Call different functions depending on the runtime types of two objects, use method overloading, separate concerns, etc.'
  s.authors = ['Emiliano Mancuso']
  s.email = ['emiliano.mancuso@gmail.com']
  s.homepage = 'http://github.com/emancu/double_dispatch'
  s.license = 'MIT'

  s.files = Dir[
    'README.md',
    'rakefile',
    'lib/double_dispatch.rb',
    'double_dispatch.gemspec'
  ]
  s.test_files = Dir['test/double_dispatch_test.rb']
end
