Pod::Spec.new do |s|
s.name              = 'Sendios'
s.version           = '1.1.0'
s.summary           = 'Use the Sendios SDK to design and send push notifications in your application.'
s.homepage          = 'https://github.com/sendios/ios-sdk'

s.author            = { 'Oleksandr Liashko' => 'oleksandr.liashko@corp.sendios.io' }
s.license           = { :type => 'Apache-2.0', :file => 'LICENSE' }

s.platform          = :ios
s.source            = { :git => 'https://github.com/sendios/ios-sdk.git', :tag => '1.1.0' }

s.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
s.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

s.ios.deployment_target = '10.0'
s.ios.vendored_frameworks = 'Sendios.framework'
end
