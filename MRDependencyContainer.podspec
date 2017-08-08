Pod::Spec.new do |s|

  s.name         = "MRDependencyContainer"
  s.version      = "2.0"
  s.summary      = "Trivial Dependency Container"

  s.homepage     = "http://github.com/Memrise/DependencyContainer"
  s.license      = { :type => 'PRIVATE USE', :file => 'LICENSE.md' }

  s.authors      = {"William Boles" => "william@memrise.com", "Wojciech Chojnacki" => "wojtek@memrise.com", "Andy Uhnak" => "andy@memrise.com"}

  s.platform     = :ios, "9.0"

  s.source       = { :git => "git@github.com:Memrise/DependencyContainer-iOS.git", :tag => s.version, :branch => "master" }
  s.source_files = "DependencyContainer/**/*.swift"

  s.requires_arc = true

end