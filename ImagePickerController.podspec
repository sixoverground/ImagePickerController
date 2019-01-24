Pod::Spec.new do |s|
  s.name             = "ImagePickerController"
  s.version          = "0.2.4"
  s.summary          = "A simple, single-view camera and photo picker."
  s.homepage         = "https://github.com/sixoverground/ImagePickerController"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = "Six Overground"
  s.platform         = :ios, "8.0"
  s.source           = { :git => "https://github.com/sixoverground/ImagePickerController.git", :tag => s.version.to_s }
  s.source_files     = "Classes/**/*"
  s.resource_bundles = { "ImagePickerController" => ["Images/*.{png}"] }
  s.framework        = "AVFoundation"
  s.requires_arc     = true
  s.swift_version    = "4.2"
end
