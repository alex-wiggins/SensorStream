#!/usr/bin/ruby

require_relative 'lib/SensorStream'

# Find the device on the server and get its ruby object representation
device = SensorStream.get_device_by_name("Launchpad 1")
if (device.nil?)
  puts "Unable to find device!"
  exit
end

# Set the device key for our device (reqired to modify the device)
device.key = "a26233d4-fb79-4168-b21e-43bc4230669a"

# Create our stream
stream = device.create_stream("testStream", "Stellaris Test", [{"type" => "int", "units" => "degf", "name" => "Temperature2"}])
if(stream.nil?)
    puts "Unable to create stream."
    exit
end

puts "Created a stream (#{stream.streamid}) \n"
puts stream.to_s

# Test publishing data to the simple stream (time omitted)
event_time = stream.publish_event({"Temperature" => "1"})
if(event_time.nil?)
  puts "Unable to publish event to stream."
  exit
end

