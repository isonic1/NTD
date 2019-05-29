require "net/telnet"

class Sensors
  
  attr_accessor :key, :telnet, :sensors
  
  def initialize ip = 'localhost', port
    home_dir = File.expand_path('~')
    key_file = ENV['EMULATOR_AUTH_TOKEN_FILE'] || "#{home_dir}/.emulator_console_auth_token"
    self.key =  File.read(key_file) if key_file_exists? key_file
    self.telnet = Net::Telnet::new("Host" => ip, "Port" => port, "Timeout" => 5, "Prompt" => /OK/n)
    emualtor_authenticate
    self.sensors = device_sensors.uniq
  end
  
  def key_file_exists? file
    puts "\nUsing Auth Token File: #{file}\n"
    if File.exists? file
      true
    else
      puts "\nEmulator Auth Token File Not Found! Aborting..."
      puts "File Not Found: #{file}\n"
      abort
    end
  end
  
  def emualtor_authenticate
    command "auth #{key}", wait
    puts "Authenticaed!"
  end
  
  def wait time = 3
    sleep time
  end
  
  def close
    telnet.close
    puts "Goodbye!"
  end

  def enabled
    sensors.find_all { |s| s.include? "enabled" }.map { |l| l.split(":")[0] }
  end

  def disabled
    sensors.find_all { |s| s.include? "disabled" }.map { |l| l.split(":")[0] }
  end

  def valid_sensor? sensor
    if enabled.include? sensor
      true
    else
      puts "\nUnknown sensor: #{sensor}\nEnabled Sensors: #{enabled}\nDisabled Sensors: #{disabled}\n"
    end
  end

  def get_all_values sensor
    values = {}
    sensor.enabled.each { |s| values.merge!( { s.to_sym => sensor.get_value(s) } ) }
    values
  end

  def reset_values sensor, values
    sensor_keys = values.keys
    sensor_keys.each { |s| sensor.set_value(s.to_s, values[s][:x], values[s][:y], values[s][:z]) }
  end

  def command cmd, options = {}
    telnet.cmd(cmd) { options }
  end
  
  def device_sensors
    #TODO fix this hack later...
    3.times do
      options = command "sensor status"
      @returned_sensors = options.split("\n").map { |o| o.chop }[0..-2]
    end
    @returned_sensors
  end

  def get_value sensor
    if valid_sensor? sensor
      value = command("sensor get #{sensor}").split[2].split(":")
      { x: value[0], y: value[1], z: value[2] }
    end
  end

  def set_value sensor, coords
    x = coords[:x]; y = coords[:y]; z = coords[:z]
    command "sensor set #{sensor} #{x}:#{y}:#{z}" if valid_sensor? sensor
  end

  def rotate
    command("rotate")
  end

  #TODO: Add these to another class
  def avd_name
    command("avd name").split("\n")[0]
  end

  def sms number = "8675309", message
    command("sms send #{phone_number} #{message}")
  end
end