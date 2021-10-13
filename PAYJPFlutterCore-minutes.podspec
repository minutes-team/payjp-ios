#
# Be sure to run `pod lib lint PAYJP.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
module PAYJPSDK
  VERSION = '1.6.1'
  HOMEPAGE_URL = 'https://github.com/payjp/payjp-ios'
  LICENSE = { :type => 'MIT' }
  AUTHOR = { 'PAY.JP (https://pay.jp)' => 'support@pay.jp' }
  SOURCE = { :git => 'https://github.com/payjp/payjp-ios.git', :tag => VERSION }
  MODULE_NAME = 'PAYJP'
  SWIFT_VERSIONS = ['5.0', '5.1', '5.2']
  IOS_DEPLOYMENT_TARGET = '10.0'
  SOURCE_FILES = ['Sources/**/*.{h,m,swift}']
  RESOURCE_BUNDLES = { 'PAYJP' => ['Sources/Resources/**/*'] }
  RESOURCES = [ 'Sources/Resources/Assets.xcassets' ]
  PUBLIC_HEADER_FILES = 'Sources/**/*.h'
  FRAMEWORKS = 'PassKit'
  POD_TARGET_XCCONFIG = { 'OTHER_SWIFT_FLAGS' => '-DPAYJPSDKCocoaPods' }
end


Pod::Spec.new do |s|
  s.name             = 'PAYJPFlutterCore-minutes'
  s.version          = PAYJPSDK::VERSION
  s.summary          = 'PAY.JP iOS SDK for Flutter distribution'
  s.description      = 'PAY.JP iOS SDK https://pay.jp/docs/started'

  s.homepage         = PAYJPSDK::HOMEPAGE_URL
  s.license          = PAYJPSDK::LICENSE
  s.author           = PAYJPSDK::AUTHOR
  s.source           = PAYJPSDK::SOURCE
  s.module_name      = PAYJPSDK::MODULE_NAME
  s.swift_versions   = PAYJPSDK::SWIFT_VERSIONS

  s.ios.deployment_target = PAYJPSDK::IOS_DEPLOYMENT_TARGET

  s.source_files = PAYJPSDK::SOURCE_FILES
  s.resource_bundles = PAYJPSDK::RESOURCE_BUNDLES
  s.resources = PAYJPSDK::RESOURCES
  s.public_header_files = PAYJPSDK::PUBLIC_HEADER_FILES
  s.frameworks = PAYJPSDK::FRAMEWORKS
  
  s.pod_target_xcconfig = PAYJPSDK::POD_TARGET_XCCONFIG

end
