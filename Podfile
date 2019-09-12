# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
# Uncomment this line if you're using Swift
# use_frameworks!

workspace 'AnalyticsSDK'

project 'AnalyticsSDK/AnalyticsSDK.xcodeproj'

def mainApp_pod
  pod 'AnalyticsSDKFramework', :podspec => 'AnalyticsSDKFramework/AnalyticsSDKFramework.podspec'
  
  pod 'Mixpanel-swift'
end

target 'AnalyticsSDK' do
project 'AnalyticsSDK/AnalyticsSDK.xcodeproj'
mainApp_pod
end

target 'AnalyticsSDKFramework' do
project 'AnalyticsSDKFramework/AnalyticsSDKFramework.xcodeproj'
  pod 'RxSwift'
end
