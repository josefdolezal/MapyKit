Pod::Spec.new do |s|
  s.name             = 'MapyKit'
  s.version          = '0.1.0'
  s.summary          = 'Native Mapy.cz maps SDK'

  s.description      = <<-DESC
MapyKit is an native Mapy.cz maps SDK written in Swift.
Backed by Apple MapKit, it allows you to use your current
maps code with custom Mapy.cz overlays.

MapyKit supports multiple map types such as Tourist, Satelite or even Winter.
                       DESC

  s.homepage         = 'https://github.com/josefdolezal/MapyKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'josefdolezal' => 'pepik.ml@gmail.com' }
  s.source           = { :git => 'https://github.com/josefdolezal/MapyKit.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/josefdolezal'
  s.swift_version    = '4.0'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MapyKit/**/*.swift'

  s.frameworks = 'MapKit'
end
