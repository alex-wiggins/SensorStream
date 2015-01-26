#!/usr/bin/ruby

require_relative 'lib/SensorStream'

DEVICE_NAME = "rubyTestDevice"

# Test creating a new device, verifies SensorStream.create_device
device = SensorStream.create_device("github", DEVICE_NAME, "Ruby API test device")
if device.nil?
    puts "Unable to create device.  API test failed. "
    exit
else
  puts "Got a new testing device: #{device.key}\n\n"
end

begin

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

# Test creating a new simple stream (an antiquated idea)
simple_stream = device.create_stream("testSimpleStream", "Ruby API test simple stream", [{"type" => "int", "units" => "none", "name" => "Newtons"}])
if(simple_stream.nil?)
    puts "Unable to create simple stream.  API test failed. "
    if(SensorStream.delete_device(device))
        puts "Successfully deleted device after failure."
    end
    exit
end

puts "Created a simple stream (#{simple_stream.streamid}) \n"
puts simple_stream.to_s

# Test publishing data to the simple stream (time omitted)
event_time = simple_stream.publish_event({"Newtons" => "1"})
if(event_time.nil?)
  puts "Unable to publish event to simple stream (time omitted).  API test failed. "
  device.delete_stream(simple_stream)
  SensorStream.delete_device(device)
  exit
end

puts "\tPublished an event to the simple stream (time omitted) at #{event_time.strftime("%FT%T.%N%:z")}"

# Test publishing data to the simple stream (time provided)
event_time = simple_stream.publish_event({"Newtons" => "2"}, Time.now())
if(event_time.nil?)
    puts "Unable to publish event to simple stream (time provided).  API test failed. "
    device.delete_stream(simple_stream)
    SensorStream.delete_device(device)
    exit
end

puts "\tPublished an event to the simple stream (time provided) at #{event_time.strftime("%FT%T.%N%:z")}"

events = simple_stream.get_events(2)
if(events.nil? || events.empty?)
  puts "Unable to retreive event from simple stream"
  device.delete_stream(simple_stream)
  SensorStream.delete_device(device)
  exit
end  

events.each { |event|
  puts "\tReteieved event from simple stream: value: #{event["value"]} timestamp: #{event["time"].strftime("%FT%T.%3N%:z")}}"
}

# Test creating a complex stream
stream_dicts = [{"Type" => "Float", "units" => "N", "Name" => "Newtons"},
                {"type" => "Int",   "Units" => "Ft", "name" => "Feet"}]
complex_stream = device.create_stream("testComplexStream",
                                      "Ruby API test complex stream",
                                      stream_dicts)
if(complex_stream.nil?)
    puts "Unable to create complex stream.  API test failed. "
    device.delete_stream(simple_stream)
    SensorStream.delete_device(device)
    exit
end

puts "\nCreated a complex stream (#{complex_stream.streamid})\n"
puts complex_stream.to_s

event_dict = {"Newtons" => "0.1", "Feet" => "2"}
event_time = complex_stream.publish_event(event_dict)
if(event_time.nil?)
    puts "Unable to publish event to complex stream (time omitted).  API test failed. "
    device.delete_stream(complex_stream)
    device.delete_stream(simple_stream)
    SensorStream.delete_device(device)
    exit
end

puts "\tPublished an event to the complex stream (time omitted) at #{event_time.strftime("%FT%T.%N%:z")}\n"

event_dict["Newtons"] = "0.2"
event_dict["Feet"] = "4"
event_time = complex_stream.publish_event(event_dict, Time.now())
if(event_time.nil?)
  puts "Unable to publish event to complex stream (time provided).  API test failed. "
  device.delete_stream(complex_stream)
  device.delete_stream(simple_stream)
  SensorStream.delete_device(device)
  exit
end

puts "\tPublished an event to the complex stream (time provided) at #{event_time.strftime("%FT%T.%N%:z")}\n"

events = complex_stream.get_events(1)
if(events.nil? || events.empty?)
  puts "Unable to retreive event from simple stream"
  device.delete_stream(simple_stream)
  device.delete_stream(complex_stream)
  SensorStream.delete_device(device)
  exit
end  

events.each { |event|
  puts "\tReteieved event from complex stream: values: #{event["values"]} timestamp: #{event["time"].strftime("%FT%T.%3N%:z")}}"
}

SensorStream.delete_device(device)

rescue Exception => ex

puts ex.message
puts ex.backtrace.join("\n")

sleep(10)
SensorStream.delete_device(device)

end