module PAYJPSDK
  VERSION = '1.2.4'
  HOMEPAGE_URL = 'https://github.com/payjp/payjp-ios'
  LICENSE = { :type => 'MIT' }
  AUTHOR = { 'PAY.JP (https://pay.jp)' => 'support@pay.jp' }
  SOURCE = { :git => 'https://github.com/payjp/payjp-ios.git', :tag => VERSION }
  MODULE_NAME = 'PAYJP'
  SWIFT_VERSIONS = ['5.0', '5.1', '5.2']
  IOS_DEPLOYMENT_TARGET = '10.0'
  SOURCE_FILES = ['Sources/**/*.{h,m,swift}']
  RESOURCE_BUNDLES = { 'PAYJP' => ['Assets.xcassets', 'Resource.bundle', 'Sources/**/*.{xib,storyboard}'] }
  RESOURCES = [ 'Assets.xcassets' ]
  PUBLIC_HEADER_FILES = 'Sources/**/*.h'
  FRAMEWORKS = 'PassKit'
  POD_TARGET_XCCONFIG = { 'OTHER_SWIFT_FLAGS' => '-DPAYJPSDKCocoaPods' }
end