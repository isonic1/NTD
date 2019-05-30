# Nordic Testing Days 2019

### Code examples for the talk I gave on automating virtual reality apps.

# Disclaimer
* I'm not an expert in VR 

### Prerequisites
* Android Studio installed with at least one emulator or device with API level 26 or greater.
* Appium and all of it's dependencies installed.
    * ```npm install -g appium```
* [cmake](https://cmake.org/download/)
* OpenCV installed
    * ```npm i -g opencv4nodejs```
* FFmpeg installed
    * ```brew install ffmpeg```
* An [Applitools](https://www.applitools.com) account. Free accounts are available!

### Setup Process:
* ```$ git clone https://github.com/isonic1/NTD.git```
* ```$ bundle install```

### Examples 

* vr_web_test.rb: 
    * Set your Applitools APIKey as environment variable. e.g export APPLITOOLS_API_KEY="your apikey"
    * Example: ```rspec vr_web_test.rb```
    
* vr_cities_non_vr.rb: 
    * Create Baselines Example: ```BASELINES=1 rspec vr_cities_non_vr.rb```
    * Validate Baselines Example: ```rspec vr_cities_non_vr.rb```
    
* vr_cities_vr.rb: 
    * Create Baselines Example: ```BASELINES=1 rspec vr_cities_vr.rb```
    * Validate Baselines Example: ```rspec vr_cities_vr.rb```
    
* video_to_image.rb: 
    * Set your Applitools APIKey as environment variable. e.g export APPLITOOLS_API_KEY="your apikey"
    * Example: ```ruby video_to_image.rb 'https://www.usatoday.com/vrstories/assets/media/blueangels.mp4' 'VR Video Frames' 'VR Example'```



