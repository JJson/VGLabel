#
# `pod lib lint VGLabel.podspec' 
#  GitHub: https://github.com/VeinGuo/VGLabel
#

Pod::Spec.new do |s|
  s.name         = "VGLabel"
  s.version      = "0.0.1"
  s.summary      = "Simple parsing HTML tag rich text reality."
  s.description  = "Simple parsing HTML tag rich text reality by Vein."
  
  s.license      = { :type => 'MIT License', :file => 'LICENSE' }
  s.homepage     = "https://github.com/VeinGuo/VGLabel"
  s.author       = { "VeinGuo" => "https://github.com/VeinGuo" }

  s.ios.deployment_target = "8.0"
  s.platform     = :ios, "8.0"
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.source       = { :git => "https://github.com/VeinGuo/VGLabel.git", :tag => s.version }
  s.source_files = 'VGLabel/Classes/*.*', 'VGLabel/Classes/**/*.*'
  s.requires_arc = true
  s.frameworks   = 'UIKit', 'CoreText', 'Foundation'

end

