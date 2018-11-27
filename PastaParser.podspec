#
# Be sure to run `pod lib lint PastaParser.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'PastaParser'
  s.version          = '1.0.0'
  s.summary          = 'Simple, extensible, and scalable grammar parsing engine.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
The goal of PastaParser is to provide a lightweight and extensible framework for tokenizing and parsing stream of characters using a user defined grammar definition that can attribute meaning to occurrences and/or sequences of characters that match any number of custom rules belonging to that grammar. Using this framework should allow developers to not only define any number of custom languages without the need for a complete project rebuild (just the addition of a simple XML file or ParserParser grammar package using the .ppgrammar package extension), utilize syntax highlighting, identifier and scope recognition, code recommendation, and much more.

Support to import and convert ANTLR4 grammar files to PastaParser grammar file format is a long term goal of this project, as well.
                       DESC

  s.homepage         = 'https://github.com/NoodleOfDeath/PastaParser'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'NoodleOfDeath' => 'git@noodleofdeath.com' }
  s.source           = { :git => 'https://github.com/NoodleOfDeath/PastaParser.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '10.0'
  s.swift_version = '4.0'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }

  s.source_files = 'src/swift/PastaParser/Classes/**/*{h,m,swift}'
  
  # s.resource_bundles = {
  #   'PastaParser' => ['src/swift/PastaParser/Assets/*.png']
  # }

  # s.public_header_files = 'src/swift/PastaPaster/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'Foundation'
  s.dependency 'SwiftyXMLParser', '4.0'
end
