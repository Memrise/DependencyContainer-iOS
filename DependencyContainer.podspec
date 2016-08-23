Pod::Spec.new do |s|

  s.name         = "DependencyContainer"
  s.version      = "1.0"
  s.summary      = "Trivial Dependency Container"

  s.homepage     = "http://github.com/Memrise/"
  s.license      = { :type => 'PRIVATE USE', :file => 'LICENSE.md' }

  s.authors      = {"William Boles" => "william@memrise.com", "Wojciech Chojnacki" => "wojtek@memrise.com", "Andy Uhnak" => "andy@memrise.com"}

  s.platform     = :ios, "8.0"

  s.source       = { :git => "git@github.com:Memrise/DependencyContainer-iOS.git", :tag => s.version, :branch => "master" }
  s.source_files = "DependencyContainer/**/*.{h,m}"
  s.public_header_files = "DependencyContainer/**/*.{h}"

  s.requires_arc = true

end
