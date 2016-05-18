Pod::Spec.new do |s|
  s.name     = 'HHJShowBigImage'
  s.version  = '0.0.1'
  s.license  = 'MIT'
  s.author   = {'szulmj' => 'https://github.com/szhonghaijiang' }
  s.homepage = 'https://github.com/szhonghaijiang/HHJShowBigImage'
  s.summary  = 'Show the big images from imageViews or images by swift'  
  s.screenshot = 'https://s3.amazonaws.com/cocoacontrols_production/uploads/control_image/image/1802/IMG_0070.PNG'


  s.source   = { :git => 'https://github.com/szhonghaijiang/HHJShowBigImage.git', :tag => '0.0.1'}
  s.source_files = 'HHJShowBig', 'HHJShowBig/../*.swift'
  s.framework = 'UIKit'
  s.requires_arc = true
  s.platform = :ios
  s.ios.deployment_target = '7.0'

end
