Pod::Spec.new do |s|
  s.name          = "JCBinaryHeap"
  s.version       = "1.0.0"
  s.summary       = "Just an OO-wrapper for CFBinaryHeap"
  s.description   = "Objective-C wrapper for CFBinaryHeap, with as much Cocoa convenience as possible."
  s.homepage      = "<#repository homepage#>"
  s.license       = { :type => 'MIT', :file => 'LICENSE' }
  s.author        = { "Jonathan Crooke" => "jon.crooke@gmail.com" }
  s.source        = { :git => "<#repository#>", :tag => "v" + s.version.to_s }
  s.ios.deployment_target = '4.0'
  s.osx.deployment_target = '6.0'
  s.source_files  = s.name + '/**/*.{h,m}'
  s.frameworks    = 'Foundation'
  s.requires_arc  = true
end
