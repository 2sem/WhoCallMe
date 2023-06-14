# Uncomment this line to define a global platform for your project
 platform :ios, '13.0'

target 'WhoCallMe' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  # Pods for WhoCallMe
  #pod 'Firebase/Core'
#  pod 'Firebase/AdMob'
  
  # Add the pod for Firebase Crashlytics
  pod 'Firebase/Crashlytics'

  # Recommended: Add the Firebase pod for Google Analytics
  pod 'Firebase/Analytics'
  
  pod 'LSExtensions' #, :path => '~/Projects/leesam/pods/LSExtensions/src/LSExtensions'
  pod 'GADManager' #, :path => '~/Projects/leesam/pods/GADManager/src/GADManager'
  #pod 'LSCircleProgressView'
  pod 'LSCircleProgressView' #, :path => '~/Projects/leesam/pods/LSCircleProgressView/src/LSCircleProgressView'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  
  pod 'StringLogger'
  
#  pod 'Fabric'
#  pod 'Crashlytics'
  
    post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |config|
          config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ''
          config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
          config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
          
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
        end
      end
    end
  
  target 'WhoCallMeUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
