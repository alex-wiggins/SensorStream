using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SensorStream
{
    public class Device
    {
        [JsonProperty("username")]
        public string username;

        [JsonProperty("devicename")]
        public string devicename;

        [JsonProperty("guid")]
        public Guid guid;

        [JsonProperty("created")]
        public DateTimeOffset created;

        [JsonProperty("latestip")]
        public string latestip;

        [JsonProperty("description")]
        public string description;

        [JsonProperty("streams")]
        public List<DeviceStream> streams = new List<DeviceStream>();
    }

}
