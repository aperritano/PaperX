source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

target 'PaperX' do
  pod 'Koloda'
  pod 'Material', '~> 1.0'
  pod 'RandomKit', '~> 1.6.0'
  pod 'Dollar'
  pod 'performSelector-swift'
  pod 'UIColor+FlatColors'
  pod 'Cartography'
  pod 'ReactiveUI'
end

post_install do |installer|
    `find Pods -regex 'Pods/pop.*\\.h' -print0 | xargs -0 sed -i '' 's/\\(<\\)pop\\/\\(.*\\)\\(>\\)/\\"\\2\\"/'`
end






