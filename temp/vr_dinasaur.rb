gem 'eyes_selenium', '=3.10.1'
require 'eyes_selenium'
require 'appium_lib'
require_relative '../android_sensor.rb'
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

  def screen_center
    { x: @window_size[0] / 2, y: @window_size[1] / 2 }
  end

  def split_screen_centers offset_left = 50, offset_right = 55
    center = screen_center
    # left_screen_bound = { x: 1, y: center[:y]}
    # right_screen_bound = { x: (@window_size[0] - 1), y: center[:y]}
    left_center = { x: (center[:x] / 2 + offset_left), y: center[:y] }
    right_center = { x: (center[:x] / 2 + center[:x] + offset_right), y: center[:y] }
    { left: left_center, right: right_center }
  end

  #'/Users/justin/Desktop/hammer.png'
  #
  def detect_image_side_location coords
    if coords[:x] > screen_center[:x]
      puts "Reference Images is detected on the right side!"
      split_screen_centers[:right]
    else
      puts "Reference Images is detected on the left side!"
      split_screen_centers[:left]
    end
  end

  start = Time.now
  until driver.find_element_by_image("./images/orient_images/center_orient.png").location.to_h[:x] == screen_center[:x]
    #turn :left, 0.2
    @sensors.set_value 'gyroscope', { x: '1', y: '0', z: '0' }
    @sensors.set_value("magnetic-field", {:x=>"5.9", :y=>"-9.53674e-07", :z=>"-48.4"})
    @sensors.set_value("orientation", {:x=>"0", :y=>"0", :z=>"1.5708"})
    @sensors.set_value("magnetic-field-uncalibrated", {:x=>"5.9", :y=>"-9.53674e-07", :z=>"-48.4"})
    @sensors.set_value("acceleration", {:x=>"9.81", :y=>"0", :z=>"0"})
    break if Time.now - start > 30
  end

  def rotate_until_x image
    #side = detect_image_side_location image
    start = Time.now
    #rotate -1
    @sensors.set_value 'acceleration', {x: 9.77, y: -0.00, z: -7.94}
    until (driver.find_element_by_image(image).displayed? rescue false) do
      puts get_sensor_values
      @values = get_sensor_values
      @location = driver.find_element_by_image(image).location.to_h
      @center = detect_image_side_location @location
      break if Time.now - start > 60
    end
    reset_all_sensors
    { center: @center, values: @values, location: @location }
  end

  def center_screen coord
    swipe_device(screen_center, coord)
    puts "Current Coord: #{coord}"
    puts "Screen Center: #{screen_center}"
  end

  def orient_screen_from_image image
    3.times do
      puts "Orienting screen from image..."
      start_x = screen_center[:x]
      start_y = screen_center[:y]
      image_coords = driver.find_element_by_image(image).location.to_h
      get_x_value = (start_x - image_coords[:x])
      end_x = (start_x - get_x_value / 2)
      get_y_value = (start_y - image_coords[:y])
      end_y = (start_y - get_y_value / 2)
      Appium::TouchAction.new.press({x: start_x , y: start_y}).wait(0).move_to({x: end_x, y: end_y}).release.perform
    end
    center_screen driver.find_element_by_image(image).location.to_h
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
    @sensors.enabled.map { |s| { s.to_sym => @sensors.get_value(s) } }.reduce({}, :merge)
  end

  def get_saved_sensor_value sensor
    @sensor_values.find { |x| x.has_key? sensor }.values.reduce
  end

  def reset_sensor_value sensor
    values = get_saved_sensor_value sensor
    @sensors.set_value sensor.to_s, values
  end

  def reset_all_sensors
    @sensor_values.map { |x| x.keys }.flatten.each do |sensor|
      values = get_saved_sensor_value sensor
      @sensors.set_value sensor.to_s, values
    end
  end

  def set_sensor_values hash
    hash.each do |sensor, values|
      puts "Sensor: #{sensor}"
      puts "Values: #{values}"
      @sensors.set_value sensor.to_s, values
    end
  end

  VR_MENU_ITEM_OPTION = {
      :acceleration=>{:x=>"5.76617", :y=>"-1.85273", :z=>"-7.71717"},
      :gyroscope=>{:x=>"0", :y=>"0", :z=>"0"},
      :"magnetic-field"=>{:x=>"-35.6885", :y=>"-7.75553", :z=>"-32.3041"},
      :orientation=>{:x=>"0.942478", :y=>"0.235619", :z=>"1.5708"},
      :temperature=>{:x=>"0", :y=>"0", :z=>"0"},
      :proximity=>{:x=>"1", :y=>"0", :z=>"0"},
      :light=>{:x=>"0", :y=>"0", :z=>"0"},
      :pressure=>{:x=>"1013.25", :y=>"0", :z=>"0"},
      :humidity=>{:x=>"0", :y=>"0", :z=>"0"},
      :"magnetic-field-uncalibrated"=>{:x=>"-35.6885", :y=>"-7.75553", :z=>"-32.3041"},
      :"gyroscope-uncalibrated"=>{:x=>"0", :y=>"0", :z=>"0"}
  }

  def turn direction = {}, time
    case direction
    when :left
      coords = { x: '1', y: '0', z: '0' }
    when :right
      coords = { x: '-1', y: '0', z: '0' }
    when :up
      coords = { x: '0', y: '-1', z: '0' }
    when :down
      coords = { x: '0', y: '1', z: '0' }
    end
    @sensors.set_value 'gyroscope', coords
    sleep time
    @sensors.set_value 'gyroscope', { x: '0', y: '0', z: '0' }
  end

  def blah direction = {}, time
    puts direction
    puts time
  end
  #
  # hammer_location.map { |x| x.keys }.flatten.each do |sensor|
  #   hammer_location
  #   @sensors.set_value sensor.to_s, values
  # end
  #
  # hammer.each do |k,v|
  #   puts "My Key: #{k}"
  #   puts "My Values: #{v}"
  #   @sensors.set_value k.keys[0].to_s, k.values[0]
  # end

  def rotate direction
    @sensors.set_value 'acceleration', {x: -0.39, y: -0.00, z: (9.80 * direction)}
    sleep 2 #give screen time to settle rotation
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
        appPackage:  'com.ammonite.mineforgecardboard',
        appActivity: "com.google.unity.GoogleUnityActivity",
        #orientation: 'LANDSCAPE',
        newCommandTimeout: 9999,
        automationName: 'uiautomator2'
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

    binding.pry

    hammer = get_sensor_values
    items = get_sensor_values
    item_select_back = get_sensor_values
    item_select_forward = get_sensor_values

    normal.each do |k,v|
      puts "My Key: #{k}"
      puts "My Values: #{v}"
      @sensors.set_value k.keys[0].to_s, k.values[0]
    end

    driver.find_element_by_image('/Users/justin/Desktop/dino_play_button.png').click ; `flick video -p android -a start`; sleep 30; `flick video -p android -a stop -n vr_test`
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