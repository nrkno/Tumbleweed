Pod::Spec.new do |s|
  s.name         = "Tumbleweed"
  s.version      = "0.1"
  s.summary      = "Logs detailed metrics about URLSession tasks to the console"
  s.description  = <<-DESC
    Logs detailed metrics about URLSession tasks to the console, such as DNS lookup durations, request and response times and more
  DESC
  s.homepage     = "https://github.com/nrkno/Tumbleweed"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Johan Sørensen" => "johan.sorensen@nrk.no" }
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/nrkno/Tumbleweed.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
