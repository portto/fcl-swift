Pod::Spec.new do |s|
  s.name             = 'FCL-SDK'
  s.version          = '0.4.1'
  s.summary          = 'Flow Client Library Swift version.'

  s.homepage         = 'https://github.com/portto/fcl-swift'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dawson' => 'dawson@portto.com', 'Scott' => 'scott@portto.com' }
  s.source           = { :git => 'https://github.com/portto/fcl-swift.git', :tag => s.version.to_s }
  s.social_media_url = 'https://x.com/BloctoApp'

  s.swift_version = '5.0.0'
  s.ios.deployment_target = '13.0'
  
  s.source_files  = "Sources/**/*"
  s.dependency "BloctoSDK/Flow", "~> 0.6.1"
  s.dependency "SwiftyJSON"

end
