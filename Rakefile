begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "gitploy"
    gemspec.summary = "Deployment DSL created with git in mind"
    gemspec.description = "Dead-simple deployments. No, for real this time."
    gemspec.email = ["brentdillingham@gmail.com", "mglenn@ilude.com"]
    gemspec.homepage = "http://github.com/brentd/gitploy"
    gemspec.authors = ["Brent Dillingham", "Mike Glenn"]
    gemspec.add_development_dependency 'rspec'
    gemspec.add_development_dependency 'aruba'
  end
  Jeweler::GemcutterTasks.new  
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler -s http://gemcutter.org"
end