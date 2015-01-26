#!/usr/bin/ruby

require 'rubygems'
require 'net/http'
require 'json'
require 'pp'
require 'base64'
require 'open3'
require 'date'
#require 'Zlib'

module SensorStream
  def self.host_name=(new_name)
    @host_name = new_name
  end

  def self.host_name
    return @host_name
  end

  def self.port_number=(new_port)
    @port_number = new_port
  end

  def self.port_number
    return @port_number
  end

  # Allows the SensorStream server to be overridden
  def self.set_default_server
    @host_name = "sensorstream.coas.oregonstate.edu"
    @port_number = 80
  end
  
  # Internally used to wrap HTTP puts with the requires headers
  def self.make_http_post(request = "", body_dict = {}, header_dict = {}, timeout = 600, debug = false)
    # Ensure that the hostname and port are set
    self.set_default_server unless !@host_name.nil?
  
    # Make sure that, at a minimum, the content type is set in the header
    header_dict["Content-Type"] = "application/json";
    
    uri  = URI.parse("http://" + @host_name + request);
    if (debug)
      puts "POST to #{uri.to_s}"
      puts "Header: #{header_dict}"
      puts "Body: #{JSON.generate(body_dict)}"
    end

    http = Net::HTTP.new(@host_name, @port_number);
    http.read_timeout = timeout; # 10 minute default timeout
    retval = http.post(uri.request_uri, JSON.generate(body_dict), header_dict);

    return retval
end

  # Internally used to wrap HTTP gets with the required headers
  def self.make_http_get(request = "", header_dict = {}, timeout = 600, debug = false)
    # Ensure that the hostname and port are set
    self.set_default_server unless !@host_name.nil?

  
    uri  = URI.parse("http://" + @host_name + request);
    if (debug)
      puts "GET from #{uri.to_s}"
      puts "Header: #{header_dict.to_s}"
    end

    http = Net::HTTP.new(@host_name, @port_number);
    http.read_timeout = 600; # 10 minute timeout
    retval = http.get(uri.request_uri, header_dict);

    return retval
  end
  
  # create a new device on the server
  def self.create_device(user_name, device_name, description)
    dict = {"username"    => user_name,
            "devicename"  => device_name,
            "description" => description}
    
    resp = make_http_post("/device.ashx?create=", dict)
    
    if (resp.code != "200")
      STDERR.puts "Error creating SensorStream device! (#{resp.code})\n#{resp.body}"
    else
      SensorStream::Device.new(user_name, device_name, description, [], JSON.parse(resp.body)["guid"])
    end
  end
  
  # Delete a device with a given key from the server
  def self.delete_device_with_key(device_key)
    puts "Deleting device #{device_key}"
    resp = make_http_post("/device.ashx?delete=device", {}, { "key" => device_key })
    
    if (resp.code != "200")
      STDERR.puts "Error deleting SensorStream device! (#{resp.code})\n#{resp.body}"
      return false;
    else
      return true;
    end  
  end
  
  # Deletes a device from the server given a ruby object with a key
  def self.delete_device(device)
    delete_device_with_key(device.key)
  end
  
  # Delete a stream from a device given a streamID and device key
  def self.delete_stream_with_key(streamID, device_key)
    puts "Deleting Stream #{streamID}"
    resp = make_http_post("/stream.ashx?delete=#{streamID}", {}, { "key" => device_key })
    
    if (resp.code != "200")
      STDERR.puts "Error deleting stream #{streamID} (#{resp.code})\n#{resp.body}"
      false
    else
      true
    end
  end
  
  # Reads a list of devices from the server
  def self.get_devices()
    resp = make_http_get("/device.ashx?getdevices=");
    
    if (resp.code != "200")
      return nil;
    else
      devices = [];

      if (resp.body.empty?)
        return nil
      end

      JSON.parse(resp.body).each { |device|
      devices << SensorStream::Device.new(device["username"],
                                          device["devicename"],
                                          device["description"]) }
      return devices;
    end
  end
  
  # Retreives a device given a device name
  def self.get_device_by_name(name)
    devices = SensorStream.get_devices
    if devices.nil?
        return nil
    end

    device = nil
    devices.each { |test_device|
      if (test_device.device_name == name)
        return test_device
      end
    }
    
    return nil
  end
  
  # Implementation of the device class
  class Device
    # Each of the qualities of a device are immutable.
    # The sensor stream API does not support changing device attributes.
    attr_reader :user_name, :device_name, :description
    # It is possible to change the streams and assign a key later, however.
    attr_accessor :streams, :key
    
    # Initialize a new SensorStream device object
    def initialize(newUserName, newDeviceName, newDescription, newStreams = [], newKey = "")
      @key         = newKey
      @device_name = newDeviceName
      @user_name   = newUserName
      @description = newDescription
      @streams     = newStreams
    end

    # Create a useful (to a human) representation of the device for printing
    def to_s
      "Name: #{@device_name} \n\tUser: #{@user_name} \n\tDescription: #{@description} \n\tKey: #{@key}"
    end

    # Create a new stream on this device
    def create_stream(name, description, elements)
    
      # Enforce lower-case values on all given element keys
      tempElements = []
      elements.each { |element|
        new_hash = element.each_with_object({}) do |(k, v), h|
          h[k.downcase] = v
        end
        tempElements << new_hash
      }
      
      dict = {"name"        => name,
              "description" => description,
              "streams"     => tempElements};
      
      resp = SensorStream.make_http_post("/stream.ashx?create=", dict, { "key" => @key })
      
      if (resp.code != "200")
        STDERR.puts "Error creating SensorStream device! (#{resp.code})\n#{resp.body}"
        return nil
      else
        return Stream.new(self, JSON.parse(resp.body)["streamid"], name, description, tempElements)
      end
    end
    
    # Delete a stream from this device using a stream ID    
    def delete_stream_with_id(streamid)
      puts "Deleting Stream #{streamid}"
      resp = SensorStream.make_http_post("/stream.ashx?delete=#{streamid}", {}, { "key" => @key })
    
      if (resp.code != "200")
        STDERR.puts "Error deleting stream #{streamID} (#{resp.code})\n{resp.body}"
        false
      else
        true
      end
    end
    
    # Delete a stream from this device using a ruby object
    def delete_stream(stream)
      delete_stream_with_id(stream.streamid)
    end
    
    # Delete all the streams belonging to this device
    def delete_streams
      puts "Deleting all streams"
      resp = SensorStream.make_http_post("/device.ashx?delete=streams", {}, { "key" => @key }, 600, true)
    
      if (resp.code != "200")
        STDERR.puts "Error deleting stream #{streamid} (#{resp.code})\n{resp.body}"
        false
      else
        true
      end
    end
    
    # Get a list of all the streams for this device
    def get_streams
      resp = SensorStream.make_http_get("/stream.ashx?getstreams=#{URI::encode(@device_name)}&user=#{URI::encode(@user_name)}")
      
      if (resp.code == "200")
        streams = []
        JSON.parse(resp.body)["streams"].each do |streamDict|
          streams << Stream.new(self, streamDict["streamid"], streamDict["name"], streamDict["description"], streamDict["streams"])
        end    
        return streams;
      else
        puts "Unable to get streams from server (#{resp.code})\n#{resp.body}"
        return nil
      end
    end
    
    # Get a stream by name
    def get_stream_by_name(name)
      streams = self.get_streams
      stream = nil
      streams.each { |test_stream|
        if (test_stream.name == name)
          return test_stream
        end
      }
      
      return nil
    end
  end
  
  # The simple stream class is the base class for complex streams
  class Stream
    # Each of the qualities of the stream are immutable.
    # The sensor stream API does not support changing stream attributes.
    attr_reader :device, :streamid, :name, :description, :elements
    
    # Initalize the fields of the stream object    
    def initialize(newDevice, newStreamid, newName, newDescription, newElements)
      @device         = newDevice
      @streamid       = newStreamid
      @name           = newName
      @elements       = newElements
      @description    = newDescription
      @deferredEvents = []
    end
    
    # Create a useful (to a human) representation of the device for printing
    def to_s
      elementsString = "";
      @elements.each do |element|
        elementsString += "\n\t\t#{element["name"]}" +
                          "\n\t\t\tTypes: #{element["type"]}" +
                          "\n\t\t\tUnits: #{element["units"]}"
      end
      
      "Name: #{@name} \n\tStreamID: #{@streamid} " + 
                     "\n\tElements: #{elementsString} " + 
                     "\n\tDescription: #{@description}" +
                     "\n\tDevice: #{device.device_name}"
    end

    # Publish an event immediately.  If it doesn't succeed, add to the deferred queue.
    def publish_event(values, time=nil)    
      dict = {"streamid" => @streamid, "values" => values};
      dict["time"] = time.strftime("%FT%T.%N%:z") unless time.nil?
      attemptTime = Time.now

      resp = SensorStream.make_http_post("/data.ashx?create=", dict, { "key" => @device.key })
      
      if (resp.code != "200")
        STDERR.puts "Error publishing SensorStream event! (#{resp.code})\n#{resp.body} -- deferring message"
        publish_event_deferred(values, attemptTime)
        return nil;
      else
        DateTime.strptime(JSON.parse(resp.body)["time"],"%FT%T.%N%:z")
      end
    end
    
    # Add an event to the deferred message queue
    def publish_event_deferred(values, time=nil)
      time ||= Time.now

      if(@deferred_events.nil?)
        @deferred_events = []
      end

      @deferred_events << { "streamid" => @streamid,
                            "values"   => values,
                            "time"     => time.strftime("%FT%T.%N%:z") }
    end
    
    # Publish all the deferred events (if there are any)
    def publish_deferred_events
      # Ensure that there are deferred messages to send
      if(@deferred_events.nil? || @deferred_events.empty?)
         @deferred_events = [] unless !@deferred_events.nil?
        puts "No events to publish" 
        if (@deferred_events.nil?)
          puts "Deferred events nil."
        elsif (@deferred_events.empty?)
          puts "Deferred events empty."
        end
        return 0
      end

      resp = SensorStream.make_http_post("/data.ashx?create=", @deferred_events, { "key" => @device.key })
      
      # If the send failed, keep the messages
      if resp.code != "200"
        puts "Unable to publish deferred events, keeping events."
        return 0
      else
        count = @deferred_events.count
        @deferred_events = []
        return count
      end
    end

    # Download a list of events from the server from this stream
    def get_events(count = 1, start_time = nil, end_time = nil)
      base = "/data.ashx?getdata=#{@streamid}"
      base += "&start=#{start_time.strftime("%FT%T.%N%:z")}" unless start_time.nil?
      base += "&end=#{    end_time.strftime("%FT%T.%N%:z")}" unless end_time.nil?
      base += "&count=#{count}"

      resp = SensorStream.make_http_get(base, {"Accept-Encoding" => "gzip"}, 600, true)

      if resp.code != "200"
        STDERR.puts  "Unable to load events from stream: #{resp.body}"
        return nil
      end

      if (resp["Content-Encoding"] == "gzip")
        puts "Content was zipped, inflating"
        content = Zlib::Inflate.inflate(resp.body)
        puts resp.body
      elsif
        content = resp.body
      end
      
      # We're only interested in the values and their timestamps
      # but the server gives us the device information anyway
      # Return only the Data array from the dictionary
      streams = (JSON.parse(resp.body)["streams"])
      data = nil;
      streams.each { |stream|
        if (stream["streamid"] == @streamid)
          data = stream["data"]
        end
      }

      if (data.nil?)
        STDERR.puts "Can't find data in get events for this stream"
        return nil
      end

      data.each { |event_dict|
        # Replace the time string with Ruby time objects
        event_dict["time"] = DateTime.strptime(event_dict["time"],"%FT%T.%N%:z")
      }
      return data
    end
  end  
end
