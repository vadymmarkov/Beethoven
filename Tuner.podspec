Pod::Spec.new do |s|
  s.name             = "Tuner"
  s.summary          = "A short description of Tuner."
  s.version          = "0.1.0"
  s.homepage         = "https://github.com/vadymmarkov/Tuner"
  s.license          = 'MIT'
  s.author           = { "Vadym Markov" => "markov.vadym@gmail.com" }
  s.source           = { :git => "https://github.com/vadymmarkov/Tuner.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/vadymmarkov'
  s.platform     = :ios, '8.0'
  s.requires_arc = true
  s.source_files = 'Source/**/*'
  s.dependency 'Pitchy'
  s.frameworks = 'AVFoundation', 'Accelerate'
end
