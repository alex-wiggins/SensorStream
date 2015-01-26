#!/usr/bin/ruby

require_relative 'lib/SensorStream'

# Create a new device for a G300
# device = SensorStream.create_device("wdillon", "Scanner", "Police radio scanner");
# if(device.nil?)
#     puts "Unable to create device.";
#     exit;
# end
# 
# puts "Got a new device GUID: " + device.key + "\n\n";
# 
# Create all the streams for the saved data

device = SensorStream.get_device_by_name("Scanner");
if (device.nil?)
  puts "Unable to find scanner device"
  exit
end

device.key = "7fa80564-e6bb-4b80-a0c8-82574f9f4f66"

# Location complex stream
streamTypes = [{"Type" => "Blob", "Units" => "audio/wav", "Name" => "Audio"},
               {"Type" => "Text", "Units" => "none", "Name" => "Text" }];
stream = device.create_stream("OSU", "OSU Public Safety", streamTypes);

if(stream.nil?)
    puts "Unable to create complex stream for location events";
    exit
end
