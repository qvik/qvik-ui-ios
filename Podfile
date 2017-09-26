platform :ios, '9.0'
use_frameworks!

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/qvik/qvik-podspecs.git'

def pods
  pod 'QvikSwift', '~> 4'
  #pod 'QvikSwift', :path => '../qvik-swift-ios/'
end

target 'QvikUi' do
  pods
end

target 'QvikUiTests' do
  pods
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '4.0'
        end
    end
end
