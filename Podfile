platform :ios, '9.0'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/qvik/qvik-podspecs.git'

def pods
  pod 'QvikSwift', '~> 6.0'
  #pod 'QvikSwift', :path => '../qvik-swift-ios/'
  pod 'SwiftLint'
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
            config.build_settings['SWIFT_VERSION'] = '5'
        end
    end
end
