platform :ios, '16.0'
use_frameworks!

target 'PawPal' do
  pod 'CleverTap-iOS-SDK'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '16.0'
    end
  end
  installer.aggregate_targets.each do |target|
    target.user_project.build_configurations.each do |config|
      config.build_settings['ENABLE_USER_SCRIPT_SANDBOXING'] = 'NO'
    end
    target.user_project.save
  end
end
