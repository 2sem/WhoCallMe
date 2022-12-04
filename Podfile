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
  
  pod 'KakaoOpenSDK'
  pod 'LSExtensions' #, :path => '~/Projects/leesam/pods/LSExtensions/src/LSExtensions'
  pod 'GADManager' #, :path => '~/Projects/leesam/pods/GADManager/src/GADManager'
  #pod 'LSCircleProgressView'
  pod 'LSCircleProgressView' #, :path => '~/Projects/leesam/pods/LSCircleProgressView/src/LSCircleProgressView'
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  
  pod 'StringLogger'
  
#  pod 'Fabric'
#  pod 'Crashlytics'
  
  #  post_install do |installer|
  #    installer.pods_project.build_configurations.each do |config|
  #      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  #    end
  #  end
  
  target 'WhoCallMeUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
