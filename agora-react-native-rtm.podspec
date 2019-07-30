require 'json'

package = JSON.parse File.read File.join __dir__, "package.json"
Pod::Spec.new do |s|
  s.name         = package["name"]
  s.version      = package["version"]
  s.summary      = package["summary"]
  s.description  = package["description"]

  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["authors"]
  s.platform     = :ios
  s.source        = { :git => package["repository"]["url"], :tag => "#{s.version}" }
  s.source_files = 'ios/src/**/*.{h,m}'

  s.dependency 'AgoraRtm_iOS', '1.0.0'
  s.dependency 'React'
  s.ios.deployment_target = '8.0'
end
