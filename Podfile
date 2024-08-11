# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MobileDeveloperChallenge' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for MobileDeveloperChallenge

  pod 'Alamofire', '~> 5.6.4'
  pod 'IQKeyboardManagerSwift', '6.0.4'
  pod 'Firebase/Core'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  pod 'FirebaseUI/Firestore'
  pod 'Firebase/Messaging'
  pod 'OAuthSwift'

  post_install do |installer|
    # Modifying the xcconfig files
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        xcconfig_path = config.base_configuration_reference.real_path
        xcconfig = File.read(xcconfig_path)
        xcconfig_mod = xcconfig.gsub(/DT_TOOLCHAIN_DIR/, "TOOLCHAIN_DIR")
        File.open(xcconfig_path, "w") { |file| file << xcconfig_mod }
      end
    end

    # Setting IPHONEOS_DEPLOYMENT_TARGET to 13.0
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
  end
end
