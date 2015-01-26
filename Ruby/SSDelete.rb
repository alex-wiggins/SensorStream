#!/usr/bin/ruby
require_relative 'lib/SensorStream'

if(ARGV.count > 1)
    SensorStream.delete_stream_with_key(ARGV[0], ARGV[1])
else
    SensorStream.delete_device_with_key(ARGV[0]);
end