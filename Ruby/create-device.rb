#!/usr/bin/ruby

require_relative 'lib/SensorStream'

DEVICE_NAME = "Launchpad 1"

# Test creating a new device, verifies SensorStream.create_device
device = SensorStream.create_device("wdillon", DEVICE_NAME, "Stellaris Connected Launchpad")
if device.nil?
    puts "Unable to create device.  API test failed. "
    exit
else
  puts "Got a new testing device: #{device.key}\n\n"
end

# Test whether the device was created, and whether we can query for it
# also tests whether the SensorStream.device.initialize method works
devices = SensorStream.get_devices
found = false
devices.each { |test_device|
  if (test_device.device_name == DEVICE_NAME)
    found = true
  end
}

if !found
    puts "Sensor stream said the device was created, but wasn't present in query."
    SensorStream.delete_device(device)
    exit
end

