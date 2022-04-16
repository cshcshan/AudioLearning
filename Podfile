# Uncomment the next line to define a global platform for your project
platform :ios, '10.2'
# ignore all warnings from all pods
inhibit_all_warnings!

target 'AudioLearning' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for AudioLearning
  pod 'RxSwift'
  pod 'RxCocoa'
  pod 'RealmSwift'

  target 'AudioLearningTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RxBlocking'
    pod 'RxTest'
  end

  target 'AudioLearningUITests' do
#    inherit! :search_paths
    inherit! :complete
    # Pods for testing
  end

end
