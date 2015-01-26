#!/usr/bin/ruby

require_relative 'lib/SensorStream'

DEVICE_NAME = "rubySinDevice"

# Test creating a new device, verifies SensorStream.create_device
device = SensorStream.create_device("wdillon", DEVICE_NAME, "Ruby API dummy device")
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

# Test creating a new simple stream
simple_stream = device.create_stream("testSimpleStream", "float", "none", "Ruby random numbers")
if(simple_stream.nil?)
    puts "Unable to create simple stream.  API test failed. "
    if(SensorStream.delete_device(device))
        puts "Successfully deleted device after failure."
    end
    exit
end

puts "Created a simple stream (#{simple_stream.streamID} \n"
puts simple_stream.to_s

phi = 0.0

while(true)

  value = Math.sin(phi)
  puts value
  event_time = simple_stream.publish_event(value)
  
  if(event_time.nil?)
    puts "Unable to publish event to simple stream (time omitted).  API test failed. "
    device.delete_stream(simple_stream)
    SensorStream.delete_device(device)
    exit
  end

  phi += 0.04
  
  sleep(1)

end
