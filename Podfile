source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

# ignore all warnings from all pods
#inhibit_all_warnings!

target 'PaperX' do
  pod 'Koloda'
  pod 'Material', '~> 1.0'
  pod 'RandomKit', '~> 1.6.0'
  pod 'Dollar'
  pod 'performSelector-swift'
  pod 'Cartography'
  pod 'ReactiveUI'
  pod 'XCGLogger'
  pod 'GCDKit'
end

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end






