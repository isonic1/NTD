
https://github.com/googlesamples/android-AccelerometerPlay

https://stackoverflow.com/questions/37442566/android-console-authentication-required
# https://stackoverflow.com/questions/3921467/how-can-i-simulate-accelerometer-in-android-emulator
https://stackoverflow.com/questions/42559993/how-to-simulate-user-movement-for-an-android-activity
https://github.com/tzutalin/adb-event-record
https://source.android.com/devices/sensors/sensor-types#tilt_detector
https://medium.com/@jasonhite/testing-on-android-sensor-events-5757bd61e9b0

https://developer.android.com/studio/run/emulator-console
https://developer.android.com/studio/run/emulator#extended

https://alvinalexander.com/android/start-android-command-line-adb-shell
https://github.com/jackpal/Android-Terminal-Emulator/wiki/Android-Shell-Command-Reference
https://developer.android.com/studio/command-line/avdmanager



***https://developer.android.com/studio/run/emulator-console

sensor = Sensors.new(5554)
sensor.enabled
v = sensor.get_value 'acceleration'
sensor.set_value 'acceleration', 0.14, 7.62, -6.17
sensor.set_value 'acceleration', v[:x], v[:y], v[:z]
sensor.set_value 'acceleration', 0.14, 7.62, 6.17
#When not in VR mode. Really fucking close...
#left horizonal
sensor.set_value('gyroscope', '0', '1', '0'); sleep 6.279999999; sensor.set_value 'gyroscope', '0', '0', '0'
#right
sensor.set_value('gyroscope', '0', '-1', '0'); sleep 6.27999998; sensor.set_value 'gyroscope', '0', '0', '0'

sensor.set_value('gyroscope', '0', '-1', '0'); sleep 6.2785; sensor.set_value 'gyroscope', '0', '0', '0'

#up 90 verticle
sensor.set_value('gyroscope-uncalibrated', 2.5, 0, 0)
sensor.set_value('acceleration', 0, 0, 9.55081)
#down 90 verticle
sensor.set_value('gyroscope-uncalibrated', -2.5, 0, 0)
sensor.set_value('acceleration', 0, 0, -9.55081)
#return to level horizonal
sensor.set_value('gyroscope-uncalibrated', 0, 0, 0)

sensor.close



https://eyes.applitools.com/app/test-results/00000251859639245521/00000251859639245318/steps/1/edit?accountId=6aMzO9JqKUmjcRkCqOUicg~~

https://eyes.applitools.com/app/test-results/00000251859638960887/00000251859638960637/steps/1/edit?accountId=6aMzO9JqKUmjcRkCqOUicg~~


{:x_axis=>"-9.81", :y_axis=>"-4.1008e-05", :z_axis=>"-2.38419e-06"}


10.times { sleep 1; puts sensor.get_value 'acceleration' }

1234B@mb00

values = {}
10.times do |x|
  sensor.enabled.each { |s| sleep 1; values.merge!( { :"#{s}#{x}"=> sensor.get_value(s) } ) }
end

def pause
  2.times { driver.find_element(:id, 'com.google.android.youtube:id/watch_player_container').click }
end


android.widget.LinearLayout
  id: com.google.android.youtube:id/action_bar_root

android.widget.FrameLayout
  id: android:id/content

android.widget.FrameLayout
  id: com.google.android.youtube:id/accessibility_layer_container

android.view.ViewGroup
  id: com.google.android.youtube:id/watch_while_layout

android.view.View
  desc: 0:02 of 0:06

android.widget.FrameLayout
  id: com.google.android.youtube:id/player_fragment_container

android.widget.FrameLayout
  id: com.google.android.youtube:id/watch_player_container

android.view.ViewGroup
  desc: Expand Mini Player
  id: com.google.android.youtube:id/watch_player

android.widget.RelativeLayout
  id: com.google.android.youtube:id/controls_layout

android.widget.TextView
  text: Visit advertiser
  id: com.google.android.youtube:id/player_learn_more_button

android.widget.LinearLayout
  id: com.google.android.youtube:id/bottom_ui_container

android.widget.LinearLayout
  id: com.google.android.youtube:id/fast_forward_rewind_triangles

android.widget.LinearLayout
  id: com.google.android.youtube:id/ad_title_layout

android.widget.TextView
  text: Ad · 0:03
  id: com.google.android.youtube:id/ad_text

android.widget.FrameLayout
  id: com.google.android.youtube:id/video_info_fragment

android.widget.RelativeLayout
  id: com.google.android.youtube:id/watch_panel

android.view.ViewGroup
  desc: Live chat
  id: com.google.android.youtube:id/live_chat

android.widget.FrameLayout
  id: com.google.android.youtube:id/video_info_loading_layout

android.support.v7.widget.RecyclerView
  id: com.google.android.youtube:id/watch_list

android.widget.GridLayout
  id: com.google.android.youtube:id/view_container

android.view.View
  id: com.google.android.youtube:id/expand_click_target

  #######################
  
android.widget.LinearLayout
  id: com.google.android.youtube:id/action_bar_root

android.widget.FrameLayout
  id: android:id/content

android.widget.FrameLayout
  id: com.google.android.youtube:id/accessibility_layer_container

android.view.ViewGroup
  id: com.google.android.youtube:id/watch_while_layout

android.view.View
  desc: 01:02 of 05:07

android.widget.FrameLayout
  id: com.google.android.youtube:id/player_fragment_container

android.widget.FrameLayout
  id: com.google.android.youtube:id/watch_player_container

android.view.ViewGroup
  desc: Expand Mini Player
  id: com.google.android.youtube:id/watch_player
  
  
  
  
