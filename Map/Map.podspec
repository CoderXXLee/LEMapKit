
Pod::Spec.new do |s|
    s.name             = 'Map'
    s.version          = '0.0.1'
    s.summary          = 'Map是私有库.'

    s.description      = <<-DESC
    TODO: Add long description of the pod here.
    DESC

    s.homepage         = 'http://192.168.1.117:8099/r/Map.git'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'LE' => '551998132@qq.com' }
    s.source           = { :git => 'http://192.168.1.117:8099/r/Map.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

    s.ios.deployment_target = '8.0'

    s.source_files = '**/*.{h,m}'

    #s.resource_bundles = {
    #    'BMAppGlobal' => ['image.bundle']
    #}

    #s.ios.preserve_paths = 'AlicloudUtils.framework','CloudPushSDK.framework','UTDID.framework','UTMini.framework'
    #s.ios.public_header_files = 'AlicloudUtils.framework/Headers/*.h','CloudPushSDK.framework/Headers/*.h','UTDID.framework/Headers/*.h','UTMini.framework/Headers/*.h'
    #s.ios.vendored_frameworks = 'AlicloudUtils.framework','CloudPushSDK.framework','UTDID.framework','UTMini.framework'

    # s.public_header_files = 'Pod/Classes/**/*.h'
    # s.frameworks = 'UIKit', 'MapKit'
    s.frameworks = 'UIKit', 'Foundation'
    #s.libraries = 'libz.tbd','libresolv.tbd','libsqlite3.tbd'
    #s.library = 'z','resolv','sqlite3'
    # s.dependency 'AFNetworking', '~> 3.1.0'
    # s.dependency 'LECategorys', '~> 0.0.4'

    s.subspec 'Map' do |map|
        map.source_files = 'Map/**/*.{h,m}'
        map.resource = 'Map/Source/Commons/MapImage.bundle'
        #map.prefix_header_contents = '#import "ZXingWrapper.h"'
        #map.resource_bundles = {
            #'Map' => ['Map/Source/Gaode/Utils/File/*.data']
        #}
    end

    s.subspec 'MapNavi' do |mapNavi|
        mapNavi.source_files = 'MapNavi/**/*.{h,m}'
        #mapNavi.prefix_header_contents = '#import "ZXingWrapper.h"'
    end

end
