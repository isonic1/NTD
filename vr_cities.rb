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

  def swipe_right
    size = @window_size
    start_x = (size[0] / 2).to_f
    start_y = (size[1] / 2).to_f
    end_x = (size[0] - 60).to_f
    end_y = (size[1] / 2).to_f
    swipe_device({x:start_x,y:start_y}, {x:end_x,y:end_y})
  end

  def swipe_left
    size = @window_size
    start_x = (size[0] - 60).to_f
    start_y = (size[1] / 2).to_f
    end_x = (size[0] / 2).to_f
    end_y = (size[1] / 2).to_f
    swipe_device({x:start_x,y:start_y}, {x:end_x,y:end_y})
  end

  def swipe_down
    size = @window_size
    start_x = size[0] / 2
    start_y = size[1] / 2
    end_x = size[0] / 2
    end_y = size[1] - 60
    swipe_device({x:start_x,y:start_y}, {x:end_x,y:end_y})
  end

  def swipe_up
    size = @window_size
    start_x = size[0] / 2
    start_y = size[1] / 2
    end_x = size[0] / 2
    end_y = 60
    swipe_device({x:start_x,y:start_y}, {x:end_x,y:end_y})
  end

  def move_to coord
    size = @window_size
    end_x = (size[0] / 2).to_f
    end_y = coord[:y]
    swipe_device(coord, {x:end_x, y:end_y})
  end

  #swipe_device(screen_center, {:x=>895, :y=>496})
  #
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

  # driver.action.move_to_location(500, 500).pointer_down(:left).move_to_location(0, 700).release.perform
  # Appium::TouchAction.new.swipe(start_x: 897 , start_y: 540, end_x: 817, end_y: 719, duration:0).perform


  def center_image image
    start = Time.now
    x = screen_center[:x]
    y = screen_center[:y]
    #screen_center.values.zip(driver.find_element_by_image(image).location.to_a).map { |v| v.inject(:-).abs }.inject(:+).abs < 5
    # driver.find_element_by_image(image).location.to_h[:x].between?((x-3), (x+3))
    until driver.find_element_by_image(image).location.to_h == screen_center
      center_screen driver.find_element_by_image(image).location.to_h
      break if Time.now - start > 60
    end
  end

  def screen_center
    { x: @window_size[0] / 2, y: @window_size[1] / 2 }
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

  def validate_view baseline_path, checkpoint_path
    driver.save_screenshot(checkpoint_path)
    score = driver.get_images_similarity first_image: File.read(baseline_path), second_image: File.read(checkpoint_path)
    puts "\nImage Comparison Score: #{score}\n"
    return score
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

  def set_sensor_values_to hash
    hash.each do |sensor, values|
      puts "Sensor: #{sensor} - Values: #{values}"
      @sensors.set_value sensor.to_s, values
    end
  end

  def get_orientation_value
    @sensors.get_value 'orientation'
  end

  def force_orientation_to_landscape
    until get_orientation_value[:z] == "1.5708"
      puts "Forcing Device Rotation to Landscape..."
      @sensors.rotate rescue nil
      sleep 1
    end
  end

  def force_orientation_to_portrait
    until get_orientation_value[:z] == "0"
      puts "Forcing Device Rotation to Portrait..."
      @sensors.rotate rescue nil
      sleep 1
    end
  end

  def create_baselines
    false
  end

  def rotate direction
    @sensors.set_value 'acceleration', {x: -0.39, y: -0.00, z: (9.80 * direction)}
    sleep 2 #give screen time to settle rotation
  end


  before(:all) do
    caps = { caps: 
      {
        platformName: 'Android',
        deviceName:   'Android',
        appPackage:  'com.Smart2it.VR.Smart2VR.VRCities',
        appActivity: "com.unity3d.player.UnityPlayerActivity",
        #orientation: 'LANDSCAPE',
        newCommandTimeout: 9999,
        automationName: 'uiautomator2'
      },
      appium_lib: { wait: 0 }
    }
    
    Appium::Driver.new(caps).start_driver
    Appium.promote_appium_methods Object

    binding.pry
        
    @sensors = Sensors.new(5554)
    
    if @sensors.enabled.empty?
      @sensors = Sensors.new(5554)
    end

    @sensors.enabled.each { |s| puts "Enabled Sensors: #{s}" }
        
    @eyes = Applitools::Selenium::Eyes.new
    @eyes.api_key = ENV['APPLITOOLS_API_KEY']
    @eyes.log_handler = Logger.new(STDOUT)

    #binding.pry
    wait_true(15) { id('com.android.packageinstaller:id/permission_allow_button').displayed? rescue false }
    id('com.android.packageinstaller:id/permission_allow_button').click
    wait_true(45) { driver.find_element_by_image('./images/close_overlay.png').displayed? rescue false }
    driver.find_element_by_image('./images/close_overlay.png').click
    wait_true(10) { driver.find_element_by_image('./images/venice_tile.png').displayed? rescue false }
    driver.find_element_by_image('./images/venice_tile.png').click
    wait_true(10) { driver.find_element_by_image('./images/first_venice_tile.png').displayed? rescue false }
    driver.find_element_by_image('./images/first_venice_tile.png').click

    force_orientation_to_landscape
    sleep 15
  end
  
  after(:all) do
    force_orientation_to_portrait
    @sensors.close
    driver.quit
    @eyes.abort_if_not_closed
  end
  
  before(:each) do
    #Get all sensor values
    @sensor_values = get_sensor_values
    @window_size = driver.manage.window.size.to_a 
  end

  # it 'Non-VR Visual Validation' do |e|
  #
  #   driver.find_element_by_image('./images/venice_no_vr_mode_button.png').click
  #   sleep 5
  #
  #   binding.pry
  #
  #   orient_screen_from_image("./images/center_orient.png")
  #
  #   if create_baselines
  #     driver.save_screenshot("./images/baselines/level.png")
  #   else
  #     driver.save_screenshot("./images/checkpoints/level.png")
  #     score = driver.get_images_similarity first_image: File.read('./images/baselines/level.png'), second_image: File.read("./images/checkpoints/level.png")
  #     puts "\nLevel Score: #{score}\n"
  #   end
  #
  #   swipe_up
  #   sleep 1
  #
  #   orient_screen_from_image("./images/up_image.png")
  #
  #   if create_baselines
  #     driver.save_screenshot("./images/baselines/up.png")
  #   else
  #     driver.save_screenshot("./images/checkpoints/up.png")
  #     score = driver.get_images_similarity first_image: File.read('./images/baselines/up.png'), second_image: File.read("./images/checkpoints/up.png")
  #     puts "\nUp Score: #{score}\n"
  #   end
  #
  #   2.times { swipe_down; sleep 1 }
  #
  #   orient_screen_from_image("./images/down_image.png")
  #
  #   if create_baselines
  #     driver.save_screenshot("./images/baselines/down.png")
  #   else
  #     driver.save_screenshot("./images/checkpoints/down.png")
  #     score = driver.get_images_similarity first_image: File.read('./images/baselines/down.png'), second_image: File.read("./images/checkpoints/down.png")
  #     puts "\nDown Score: #{score}\n"
  #   end
  #
  #   swipe_up
  #   sleep 1
  #   swipe_right
  #   sleep 1
  #
  #   orient_screen_from_image("./images/right1_image.png")
  #
  #   if create_baselines
  #     driver.save_screenshot("./images/baselines/right1.png")
  #   else
  #     driver.save_screenshot("./images/checkpoints/right1.png")
  #     score = driver.get_images_similarity first_image: File.read('./images/baselines/right1.png'), second_image: File.read("./images/checkpoints/right1.png")
  #     puts "\nRight1 Score: #{score}\n"
  #   end
  #
  #   swipe_right
  #   sleep 1
  #
  #   orient_screen_from_image("./images/right2_image.png")
  #
  #   if create_baselines
  #     driver.save_screenshot("./images/baselines/right2.png")
  #   else
  #     driver.save_screenshot("./images/checkpoints/right2.png")
  #     score = driver.get_images_similarity first_image: File.read('./images/baselines/right2.png'), second_image: File.read("./images/checkpoints/right2.png")
  #     puts "\nRight2 Score: #{score}\n"
  #   end
  # end
  
  it 'VR Visual Validation' do |e|

    driver.find_element_by_image('./images/venice_no_vr_mode_button.png').click
    sleep 5

    orient_screen_from_image("./images/center_orient.png")

    driver.find_element_by_image('./images/venice_vr_mode_button.png').click

    binding.pry

    rotate 1
    rotate -1

    1.times do
      @sensors.set_value('gyroscope', {x:'-1', y:'0', z:'0'})
      sleep (6.2785/3)
      @values = {}
      @sensor_values.map { |x| x.keys }.flatten.each do |s|
        v = @sensors.get_value(s.to_s)
        puts "Sensor #{s.to_s}: #{v}"
        #@values << { "#{s}":v }
        @values[s] = v
      end
      #@sensors.set_value('magnetic-field', {:x=>"5.9", :y=>"-46.5943", :z=>"-13.0971"})
      #@sensors.set_value 'gyroscope', {x:'0', y:'0', z:'0'}
      @sensors.set_value 'gyroscope', {x:'0', y:'0', z:'0'}
    end



    # @eyes.open(driver: driver, app_name: 'VR Cities', test_name: "Android VR")
    # @eyes.check_window 'level'
    # swipe_up
    # sleep 1
    # @eyes.check_window 'up'
    # 2.times { swipe_down; sleep 1 }
    # @eyes.check_window 'down'
    # swipe_up
    # sleep 1
    # swipe_right
    # sleep 1
    # @eyes.check_window 'right 1'
    # swipe_right
    # sleep 1
    # @eyes.check_window 'right 2'
    # @eyes.close(false)
  end
end


# @sensors = Sensors.new(5554)
# @sensors.enabled.each { |s| puts "Enabled Sensors: #{s}" }
#
# @sensors.rotate
#
# puts "\nRotating Left!\n".yellow
# @sensors.set_value 'gyroscope', {x:'1', y:'0', z:'0'}
# sleep 1
#
#
# puts "\nRotating Right!\n".yellow
# @sensors.set_value 'gyroscope', {x:'-1', y:'0', z:'0'}
# sleep 1
# puts "\nRotating Down!\n".yellow
# @sensors.set_value 'gyroscope', {x:'0', y:'1', z:'0'}
# sleep 1
# puts "\nRotating Up!\n".yellow
# @sensors.set_value 'gyroscope', {x:'0', y:'-1', z:'0'}
# sleep 1
# puts "\nResetting Rotation!\n".yellow
# @sensors.set_value 'gyroscope', {x:'0', y:'0', z:'0'}
# sleep 1
# puts "\nSaving Sensor Values\n".green
# @save_sensor_values = get_sensor_values