gem 'eyes_selenium', '=3.10.1'
require 'eyes_selenium'
require 'appium_lib'
require_relative 'android_sensor.rb'
require 'pry'

#Talk about enabliing touch sensor on android
#npm i -g opencv4nodejs
#https://www.npmjs.com/package/opencv4nodejs
#https://cmake.org/download/
#https://appium.readthedocs.io/en/latest/en/writing-running-appium/image-comparison/
#https://developer.android.com/studio/run/emulator-console

describe 'Android Native Visual VR Assertions' do

  def swipe_device(start_cord = {}, end_cord = {})
    Appium::TouchAction.new.press(start_cord).wait(0).move_to(end_cord).release.perform
  end
  
  def video_start
    tap({:x=>130, :y=>1000})
  end
  
  def fast_forward
    Appium::TouchAction.new.press({:x=>200, :y=>1000}).wait(0).move_to({:x=>1000, :y=>1000}).release.perform
  end
  
  def rewind
    Appium::TouchAction.new.press({:x=>1000, :y=>1000}).wait(0).move_to({:x=>200, :y=>1000}).release.perform
  end
  
  def swipe_down
    size = @window_size
    start_x = size[0] / 2
    start_y = size[1] / 2
    end_x = size[0] / 2
    end_y = size[1] - 200
    swipe_device({x:start_x,y:start_y}, {x:end_x,y:end_y})
  end

  def swipe_up
    size = @window_size
    start_x = size[0] / 2
    start_y = size[1] / 2
    end_x = size[0] / 2
    end_y = 100
    swipe_device({x:start_x,y:start_y}, {x:end_x,y:end_y})
  end

  def swipe_left
    size = @window_size
    start_x = (size[0] - 60).to_f
    start_y = (size[1] / 2).to_f
    end_x = 60.to_f
    end_y = (size[1] / 2).to_f
    swipe_device({x:start_x,y:start_y}, {x:end_x,y:end_y})
  end

  def swipe_right
    size = @window_size
    start_x = 60.to_f
    start_y = (size[1] / 2).to_f
    end_x = (size[0] - 60).to_f
    end_y = (size[1] / 2).to_f
    swipe_device({x:start_x,y:start_y}, {x:end_x,y:end_y})
  end
  
  def move_to coord
    size = @window_size
    end_x = (size[0] / 2).to_f
    end_y = coord[:y]
    swipe_device(coord, {x:end_x, y:end_y})
  end
  
  def center_screen coord
    size = @window_size
    end_x = (size[0] / 2).to_f
    end_y = (size[1] / 2).to_f
    swipe_device(coord, {x:end_x, y:end_y})
  end
  
  def look_for_image image
    start = Time.now
    until (driver.find_element_by_image(image).displayed? rescue false) do
      swipe_right
      sleep 0.5
      if Time.now - start > 60
        puts "Could not find image: #{image}"
        @found = false
        break
      else
        @found = true
      end
    end
    if @found
      puts "Found Image: #{image}"
      sleep 1
      coords = driver.find_element_by_image(image).location.to_h
      center_screen coords
    end
  end
  
  def score_image_diff
    perfect = {"score"=>0.9999993443489075}
  end
  
  def tap args = {}
    begin
      Appium::TouchAction.new.tap(args).release.perform
    rescue
      nil
    end
  end
  
  def play
    #wait_true { id('com.google.android.youtube:id/watch_player_container').displayed? }
    id('com.google.android.youtube:id/player_control_play_pause_replay_button').click
  end

  def enter_full_screen
    # 3.times do
    #   # id('com.google.android.youtube:id/watch_player').click
    #   # id('com.google.android.youtube:id/fullscreen_button').click rescue nil
    #   tap({:x=>975, :y=>521})
    # end
    puts "Entering Full screen..."
    until displayed?({id: "Exit fullscreen"})
      id('com.google.android.youtube:id/watch_player').click
      id('com.google.android.youtube:id/fullscreen_button').location_once_scrolled_into_view rescue nil
    end
    sleep 2
    #id("Exit fullscreen") add check for this
  end

  def hide_overlay_if_displayed
    if displayed?({id: 'com.google.android.youtube:id/player_control_play_pause_replay_button'})
      tap({x:10, y:10}) #random tap screen to remove overlay
    end
  end

  def restart_video
    id('com.google.android.youtube:id/watch_player').click
    id('com.google.android.youtube:id/player_control_play_pause_replay_button').click
    video_start
    sleep 3
    hide_overlay_if_displayed
  end

  # play; video_start; pause; video_start
  # pause; video_start

  def pause
    2.times { play; sleep 0.5 }
  end

  def fe locator
    begin
      find_element(locator)
    rescue
      nil
    end
  end

  def displayed? locator
    begin
      fe(locator).displayed?
    rescue
      false
    end
  end

  def navigate_to_vr_video video_name
    id('com.google.android.youtube:id/menu_search').click
    id('com.google.android.youtube:id/search_edit_text').send_keys video_name
    id("com.google.android.youtube:id/text").click
    wait_true { id('com.google.android.youtube:id/thumbnail').displayed? }
    vr_video = texts.find { |video| video.text.include? video_name }
    vr_video.click
    sleep 5 #Give time for video to start. This can be replaced with an explicity wait.
    #wait_true(15) { text('You can skip ad in 0s') }
  end

  def get_sensor_values
    @sensors.enabled.map { |s| { s.to_sym => @sensors.get_value(s) } }
  end

  def get_saved_sensor_value sensor
    @sensor_values.find { |x| x.has_key? sensor }.values.reduce
  end

  def rotate direction
    @sensors.set_value 'acceleration', {x: -0.39, y: -0.00, z: (9.80 * direction)}
    sleep 2 #give screen time to settle rotation
  end

  def reset_sensor_value sensor
    values = get_saved_sensor_value sensor
    @sensors.set_value sensor.to_s, values
  end

  def get_orientation_value
    @sensors.get_value 'orientation'
  end

  def force_orientation_to_landscape
    puts "Forcing Orientation to Landscape"
    until get_orientation_value[:z] == "-1.5708"
      @sensors.rotate rescue nil
      sleep 1
    end
  end

  before(:all) do
    caps = { caps: 
      {
        platformName: 'Android',
        deviceName:   'Android',
        appPackage:  'com.google.android.youtube',
        appActivity: "com.google.android.apps.youtube.app.WatchWhileActivity",
        #orientation: 'LANDSCAPE',
        newCommandTimeout: 9999,
        #automationName: 'uiautomator2'
      },
      appium_lib: { wait: 0 }
    }
    
    Appium::Driver.new(caps).start_driver
    Appium.promote_appium_methods Object
        
    @sensors = Sensors.new(5554)
    
    if @sensors.enabled.empty?
      @sensors = Sensors.new(5554)
    end
    
    @sensors.enabled.each { |s| puts "Enabled Sensors: #{s}" }
        
    @eyes = Applitools::Selenium::Eyes.new
    @eyes.api_key = ENV['APPLITOOLS_API_KEY']

    #@sensors.rotate rescue nil
  end
  
  after(:all) do
    driver.quit
    @eyes.abort_if_not_closed
  end
  
  before(:each) do
    navigate_to_vr_video("Experience the Blue Angels in 360-degree video")

    enter_full_screen

    force_orientation_to_landscape

    restart_video

    #Get all sensor values
    @sensor_values = get_sensor_values

    @window_size = driver.manage.window.size.to_a 
  end
  
  it 'Visual Validation' do
    @eyes.open(driver: driver, app_name: "VR Test", test_name: "Android VR")
    @eyes.check_window 'normal orientation'
    rotate -1 #rotates orientation up
    @eyes.check_window 'rotated up orientation'
    rotate 1 #rotates orientation down
    @eyes.check_window 'rotated down orientation'
    reset_sensor_value :acceleration
    @eyes.close(false)
  end
end

# if displayed?({id: 'com.google.android.youtube:id/ad_text'})
#   wait_true(15) { !displayed?({id: 'com.google.android.youtube:id/ad_text'}) }
# else
#   wait_true(15) { displayed?({ id: 'com.google.android.youtube:id/skip_ad_text' })  }
#   id('com.google.android.youtube:id/skip_ad_text').click
# end

#wait_true(10) { !fe({id: 'com.google.android.youtube:id/ad_text'}).displayed? }
#wait(10) { displayed?({ id: 'com.google.android.youtube:id/watch_player_container' }) }
#wait_true(15) { displayed?({ id: 'com.google.android.youtube:id/skip_ad_text' })  }
#id('com.google.android.youtube:id/skip_ad_text').click rescue nil
#Pause Video


#
# id('com.google.android.youtube:id/time_bar_current_time')
# id('com.google.android.youtube:id/time_bar_total_time')
#
# id('com.google.android.youtube:id/player_fragment_container').click
#
# id('com.google.android.youtube:id/player_control_play_pause_replay_button')
#
# id('com.google.android.youtube:id/bottom_bar_background').click
#
# #vr_mode
# #id('Enter virtual reality mode').click