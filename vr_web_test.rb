require 'eyes_selenium'

def reset_canvas_orientation driver, timeout
  driver.execute_script("var ele = document.querySelector('a.control.tooltip.help'); ele.click();")
  sleep 0.5
  driver.find_element(:css, 'div.action').click
  sleep timeout
end

describe 'Testing Applitools VR' do
  
  attr_accessor :driver, :eyes, :app_name, :viewport, :timeout, :canvas_locator, :canvas
  
  before(:all) do |e|
    self.driver = Selenium::WebDriver.for :chrome
    self.eyes = Applitools::Selenium::Eyes.new
    eyes.api_key = ENV['APPLITOOLS_API_KEY']
    eyes.log_handler = Logger.new(STDOUT)
    eyes.stitch_mode = :CSS
    eyes.hide_scrollbars = true
    eyes.batch  = Applitools::BatchInfo.new("WebVR Rotation Tests")
    self.app_name = "Sketchfab WebVR"
    self.viewport = { width: 1400, height: 1000 }
    self.timeout = 3 #wait for shadows to finish rendering
    
    driver.get("https://sketchfab.com/models/2324f9685404433fa6231c7cb2cd2ff5")
    self.canvas_locator = { css: 'div.viewer-wrapper' }
    self.canvas = driver.find_element(canvas_locator)
    sleep 60
  end
  
  before(:each) { reset_canvas_orientation(driver, timeout) }
  
  after(:each) { eyes.abort_if_not_closed }
  
  after(:all) { driver.quit }

  it 'Horizontal VR Rotation' do |example|
   eyes_driver = eyes.open(driver: driver, app_name: app_name, test_name: example.description, viewport_size: viewport)   
   
   capture_region = eyes_driver.find_element(canvas_locator)
   
   rotate_left = [0, 104.99999, 104.99999, 104.99999, 104.99999, 104.99999]
   rotate_left.each do |rotate|
     driver.action.drag_and_drop_by(canvas, rotate, 0).perform
     sleep timeout #wait for shadows to finish rendering
     target = Applitools::Selenium::Target.region(capture_region).fully
     eyes.check 'VR Canvas Horizonal', target
   end
    eyes.close
  end
  
  it 'Vertical VR Rotation' do |example|
    eyes_driver = eyes.open(driver: driver, app_name: app_name, test_name: example.description, viewport_size: viewport)
    
    capture_region = eyes_driver.find_element(canvas_locator)
    
    #rotate up veritcally 6 times
    6.times do |rotate|
      driver.action.drag_and_drop_by(canvas, 0, 30).perform
      sleep timeout #wait for shadows to finish rendering
      target = Applitools::Selenium::Target.region(capture_region).fully
      eyes.check 'VR Canvas Vertical', target
    end
    
    reset_canvas_orientation(driver, timeout)
    
    #rotate down veritcally 5 times
    5.times do |rotate|
      driver.action.drag_and_drop_by(canvas, 0, -30).perform
      sleep timeout #wait for shadows to finish rendering
      target = Applitools::Selenium::Target.region(capture_region).fully
      eyes.check 'VR Canvas Vertical', target
    end
    eyes.close
  end
end