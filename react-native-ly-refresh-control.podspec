require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-ly-refresh-control"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.homepage     = package["homepage"]
  s.license      = package["license"]
  s.authors      = package["author"]

  s.platforms    = { :ios => "10.0" }
  s.source       = { :git => "https://github.com/syanbo/react-native-ly-refresh-control.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,m,mm}"
  
#  s.resource_bundles = {
#    'LYRefreshControl' => ['ios/Assets/*.png']
#  }

  s.dependency "React-Core"
  s.dependency "MJRefresh"

end
