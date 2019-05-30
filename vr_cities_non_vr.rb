require 'appium_lib'
require_relative 'android_sensor.rb'

describe 'Android Native Visual VR Assertions' do

  def swipe_device(start_cord = {}, end_cord = {})
    Appium::TouchAction.new.press(start_cord).wait(0).move_to(end_cord).release.perform
    sleep 1
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

  def tap args = {}
    begin
      Appium::TouchAction.new.tap(args).release.perform
    rescue
      nil
    end
  end

  def move_to coord
    size = @window_size
    end_x = (size[0] / 2).to_f
    end_y = coord[:y]
    swipe_device(coord, {x:end_x, y:end_y})
  end

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

  def score_threshold
    0.90
  end

  def compare_images baseline_path, checkpoint_path
    if create_baselines
      driver.save_screenshot(baseline_path)
    else
      image_score = validate_view(baseline_path, checkpoint_path)
      expect(image_score["score"]).to be >= score_threshold
    end
  end

  def find_image image_path
    begin
      driver.find_element_by_image(image_path)
    rescue
      nil
    end
  end

  def image_displayed? image_path
    begin
      find_image(image_path).displayed?
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
    set_sensor_values @sensor_values
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
    sleep 15
  end

  def force_orientation_to_portrait
    until get_orientation_value[:z] == "0"
      puts "Forcing Device Rotation to Portrait..."
      @sensors.rotate rescue nil
      sleep 1
    end
  end

  def create_baselines
    if ENV["BASELINES"] == "1"
      true
    else
      false
    end
  end

  def rotate direction
    @sensors.set_value 'acceleration', {x: -0.39, y: -0.00, z: (9.80 * direction)}
    sleep 2 #give screen time to settle rotation
  end

  def navigate_to_vr_app
    wait_true(15) { id('com.android.packageinstaller:id/permission_allow_button').displayed? rescue false }
    id('com.android.packageinstaller:id/permission_allow_button').click
    wait_true(45) { image_displayed?'./images/page_object_images/close_overlay.png' }
    find_image('./images/page_object_images/close_overlay.png').click
    wait_true(10) { image_displayed?'./images/page_object_images/venice_tile.png' }
    find_image('./images/page_object_images/venice_tile.png').click
    wait_true(10) { image_displayed?'./images/page_object_images/first_venice_tile.png' }
    find_image('./images/page_object_images/first_venice_tile.png').click
  end

  before(:all) do
    caps = {
        caps: {
            platformName: 'Android',
            deviceName:   'Android',
            appPackage:  'com.Smart2it.VR.Smart2VR.VRCities',
            appActivity: "com.unity3d.player.UnityPlayerActivity",
            #orientation: 'LANDSCAPE', #This rotates the view and not the device...
            newCommandTimeout: 9999,
            automationName: 'uiautomator2'
        }, appium_lib: { wait: 0 }
    }
    
    Appium::Driver.new(caps).start_driver
    Appium.promote_appium_methods Object

    @sensors = Sensors.new(5554)
    @sensors.enabled.each { |s| puts "Enabled Sensors: #{s}" }

    navigate_to_vr_app
    force_orientation_to_landscape

    @window_size = driver.manage.window.size.to_a
  end
  
  after(:all) do
    force_orientation_to_portrait
    @sensors.close
    driver.quit
  end
  
  before(:each) do
    @sensor_values = get_sensor_values #Get all sensor values
  end

  it 'Non-VR Visual Validation' do |e|

    driver.find_element_by_image('./images/page_object_images/venice_no_vr_mode_button.png').click
    #Give time for app to orient itself in this mode...
    sleep 5

    orient_screen_from_image("./images/orient_images/center_orient.png")

    compare_images './images/baselines/vr_cities/level.png', './images/checkpoints/vr_cities/level.png'

    swipe_up
    orient_screen_from_image("./images/orient_images/up_image.png")

    compare_images './images/baselines/vr_cities/up.png', './images/checkpoints/vr_cities/up.png'

    2.times { swipe_down }
    orient_screen_from_image("./images/orient_images/down_image.png")

    compare_images './images/baselines/vr_cities/down.png', './images/checkpoints/vr_cities/down.png'

    swipe_up
    swipe_right
    orient_screen_from_image("./images/orient_images/right1_image.png")

    compare_images './images/baselines/vr_cities/right1.png', './images/checkpoints/vr_cities/right1.png'

    swipe_right
    orient_screen_from_image("./images/orient_images/right2_image.png")

    compare_images './images/baselines/vr_cities/right2.png', './images/checkpoints/vr_cities/right2.png'
  end

end