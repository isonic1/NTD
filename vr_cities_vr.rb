require 'appium_lib'
require_relative 'android_sensor.rb'
require 'pry'

describe 'Android Native Visual VR Assertions' do

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
    set_sensor_values_to @sensor_values
  end

  def set_sensor_values_to hash
    hash.each do |sensor, values|
      puts "Sensor: #{sensor} - Values: #{values}"
      @sensors.set_value sensor.to_s, values
    end
    puts ""
    sleep 45
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
    sleep 25 #Give time for view rotation to stop.
  end

  def force_orientation_to_portrait
    until get_orientation_value[:z] == "0"
      puts "Forcing Device Rotation to Portrait..."
      @sensors.rotate rescue nil
      sleep 1
    end
  end

  def navigate_to_vr_app
    wait_true(15) { id('com.android.packageinstaller:id/permission_allow_button').displayed? rescue false }
    id('com.android.packageinstaller:id/permission_allow_button').click rescue nil
    wait_true(45) { image_displayed?'./images/page_object_images/close_overlay.png' }
    find_image('./images/page_object_images/close_overlay.png').click
    wait_true(10) { image_displayed?'./images/page_object_images/venice_tile.png' }
    find_image('./images/page_object_images/venice_tile.png').click
    wait_true(10) { image_displayed?'./images/page_object_images/first_venice_tile.png' }
    find_image('./images/page_object_images/first_venice_tile.png').click
  end

  def create_baselines
    if ENV["BASELINES"] == "1"
      true
    else
      false
    end
  end

  def compare_images baseline_path, checkpoint_path
    if create_baselines
      driver.save_screenshot(baseline_path)
    else
      image_score = validate_view(baseline_path, checkpoint_path)
      expect(image_score["score"]).to be >= score_threshold
    end
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

  VR_STARTING_SENSOR_VALUES = {
      :acceleration=>{:x=>"0", :y=>"9.77631", :z=>"0.812349"},
      :gyroscope=>{:x=>"0", :y=>"0", :z=>"0"},
      :"magnetic-field"=>{:x=>"0", :y=>"9.88766", :z=>"-47.7452"},
      :orientation=>{:x=>"-0.0829031", :y=>"0", :z=>"0"},
      :"magnetic-field-uncalibrated"=>{:x=>"0", :y=>"9.88766", :z=>"-47.7452"},
      :"gyroscope-uncalibrated"=>{:x=>"0", :y=>"0", :z=>"0"}
  }

  VR_UP_SENSOR_VALUES = {
      :acceleration=>{:x=>"5.76617", :y=>"-9.53674e-07", :z=>"-7.93646"},
      :gyroscope=>{:x=>"0", :y=>"0", :z=>"0"},
      :"magnetic-field"=>{:x=>"-35.6885", :y=>"4.76837e-07", :z=>"-33.222"},
      :orientation=>{:x=>"0.942478", :y=>"0", :z=>"1.5708"},
      :"magnetic-field-uncalibrated"=>{:x=>"-35.6885", :y=>"4.76837e-07", :z=>"-33.222"},
      :"gyroscope-uncalibrated"=>{:x=>"0", :y=>"0", :z=>"0"}
  }

  VR_DOWN_SENSOR_VALUES = {
      :acceleration=>{:x=>"1.53462", :y=>"0", :z=>"9.68922"},
      :gyroscope=>{:x=>"0", :y=>"0", :z=>"0"},
      :"magnetic-field"=>{:x=>"48.7271", :y=>"-1.43051e-06", :z=>"-1.74406"},
      :orientation=>{:x=>"-1.41372", :y=>"0", :z=>"1.5708"},
      :"magnetic-field-uncalibrated"=>{:x=>"48.7271", :y=>"-1.43051e-06", :z=>"-1.74406"},
      :"gyroscope-uncalibrated"=>{:x=>"0", :y=>"0", :z=>"0"}
  }


  VR_RIGHT1_SENSOR_VALUES = {
      :acceleration=>{:x=>"9.81", :y=>"-6.67572e-06", :z=>"0"},
      :gyroscope=>{:x=>"0", :y=>"0", :z=>"0"},
      :"magnetic-field"=>{:x=>"5.90003", :y=>"45.4231", :z=>"16.7124"},
      :orientation=>{:x=>"-3.14159", :y=>"-1.21824", :z=>"-1.5708"},
      :"magnetic-field-uncalibrated"=>{:x=>"5.90003", :y=>"45.4231", :z=>"16.7124"},
      :"gyroscope-uncalibrated"=>{:x=>"0", :y=>"0", :z=>"0"}
  }

  VR_RIGHT2_SENSOR_VALUES = {
      :acceleration=>{:x=>"9.81", :y=>"5.62668e-05", :z=>"-5.24521e-06"},
      :gyroscope=>{:x=>"0", :y=>"0", :z=>"0"},
      :"magnetic-field"=>{:x=>"5.90029", :y=>"-48.361", :z=>"1.94239"},
      :orientation=>{:x=>"3.14158", :y=>"1.53066", :z=>"-1.57079"},
      :"magnetic-field-uncalibrated"=>{:x=>"5.90029", :y=>"-48.361", :z=>"1.94239"},
      :"gyroscope-uncalibrated"=>{:x=>"0", :y=>"0", :z=>"0"}
  }

  def screen_center
    { x: @window_size[0] / 2, y: @window_size[1] / 2 }
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

    set_sensor_values_to VR_STARTING_SENSOR_VALUES

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
    $sensor_values = get_sensor_values #Save current sensor values
    sleep 30
  end

  after(:each) do
    set_sensor_values_to($sensor_values)
  end

  it 'VR Visual Validation' do |e|

    set_sensor_values_to VR_UP_SENSOR_VALUES

    compare_images './images/baselines/vr_cities/up_vr.png', './images/checkpoints/vr_cities/up_vr.png'

    set_sensor_values_to($sensor_values)

    set_sensor_values_to VR_DOWN_SENSOR_VALUES

    compare_images './images/baselines/vr_cities/down_vr.png', './images/checkpoints/vr_cities/down_vr.png'

    set_sensor_values_to($sensor_values)

    set_sensor_values_to VR_RIGHT1_SENSOR_VALUES

    compare_images './images/baselines/vr_cities/right1_vr.png', './images/checkpoints/vr_cities/right1_vr.png'

    set_sensor_values_to($sensor_values)

    set_sensor_values_to VR_RIGHT2_SENSOR_VALUES

    compare_images './images/baselines/vr_cities/right2_vr.png', './images/checkpoints/vr_cities/right2_vr.png'

  end
end