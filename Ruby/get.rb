#!/usr/bin/ruby

require_relative 'lib/SensorStream'

# Find the device on the server and get its ruby object representation
device = SensorStream.get_device_by_name("Launchpad 1")
if (device.nil?)
  puts "Unable to find device!"
  exit
end

puts "Got device"

stream = device.get_stream_by_name("testStream")
if (stream.nil?)
  puts "Unable to find stream!"
  exit
end

puts "Got stream"

events = stream.get_events(10000)
if(events.nil? || events.empty?)
  puts "Unable to retreive event from simple stream"
  exit
end  

