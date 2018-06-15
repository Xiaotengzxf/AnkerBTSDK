#
# Be sure to run `pod lib lint AnkerBTSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AnkerBTSDK'
  s.version          = '1.0.0'
  s.summary          = 'AnkerBTSDK For BT'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'AnkerBTSDK for Anker bluetooth project, All bluetooth project can integrate with cocoapods.'

  s.homepage         = 'https://github.com/Xiaotengzxf/AnkerBTSDK'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Bruce Zhang' => '315082431@qq.com' }
  s.source           = { :git => 'https://github.com/Xiaotengzxf/AnkerBTSDK.git', :tag => s.version }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.platform = :ios, '9.0'

  s.source_files = 'AnkerBTSDK/Classes/*.swift'
  
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.1' }
  
  # s.resource_bundles = {
  #   'AnkerBTSDK' => ['AnkerBTSDK/Assets/*.png']
  # }

 #s.public_header_files = 'AnkerBTSDK/Classes/BTManager.swift'
  s.frameworks = 'UIKit', 'Foundation', 'CoreBluetooth', 'AVFoundation'
  # s.dependency 'AFNetworking', '~> 2.3'
end
