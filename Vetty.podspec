Pod::Spec.new do |s|
  s.name             = 'Vetty'
  s.version          = '1.1.0'
  s.summary          = 'Reactive Model Provider built on RxSwift'
  s.description      = 'Very easy commit & read & mutation mechanism about all of model'
  s.homepage         = 'https://github.com/Geektree0101/Vetty'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Geektree0101' => 'h2s1880@gmail.com' }
  s.source           = { :git => 'https://github.com/Geektree0101/Vetty.git', :tag => s.version.to_s }
  s.social_media_url = 'https://geektree0101.github.io/'
  s.ios.deployment_target = '8.0'
  s.source_files = 'Vetty/Classes/**/*'
  s.dependency 'RxSwift', '~> 4.0'
  s.dependency 'RxCocoa', '~> 4.0'
end
