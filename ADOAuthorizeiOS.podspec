Pod::Spec.new do |s|
  s.name         = 'ADOAuthorizeiOS'
  s.version      = '0.0.1'
  s.summary      = 'An attempt to abstract OAuth details away for iPhone development'
  s.author       = { 'Adam Duke' => 'adam.v.duke+github@gmail.com' }
  s.source       = { :git => 'https://github.com/adamvduke/ADOAuthorizeiOS.git', :commit => 'f33740d37eab2aca56c17ece1c6fca62f668761f' }
  s.source_files = 'Classes/ViewController/*.{h,m}'
  s.dependency 'OAuthConsumer', :git => "https://github.com/adamvduke/OAuthConsumer.git", :commit => "8647a2d9534fb95ab7edb7993205969ca3f839b3"
  s.dependency 'ObjCMacros', :git => "https://github.com/adamvduke/ObjCMacros.git", :commit => "75facaeb736feabd62bfb934b54c35a5397b2b43"
end