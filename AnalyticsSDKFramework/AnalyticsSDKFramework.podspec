Pod::Spec.new do |s|
  s.name         = "AnalyticsSDKFramework"
  s.version      = "0.0.1"
  s.summary      = "A short description of AnalyticsSDKFramework."
  s.description  = <<-DESC
  A much much longer description of AnalyticsSDKFramework.
                   DESC
  s.homepage     = "http://EXAMPLE/MyFramework"
  s.license      = "Copyleft"
  s.author       = { "Balraj Singh" => "erbalrajs@gmail.com" }
  s.source       = { :git => "https://github.com/balrajOla/AnalyticsSDK" }
  s.source_files = "AnalyticsSDKFramework"
 
  s.dependency 'RxSwift'
end