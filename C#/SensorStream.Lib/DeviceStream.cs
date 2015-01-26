using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SensorStream
{
    public class DeviceStream
    {
        [JsonProperty("streamid")]
        public string streamid;

        [JsonProperty("name")]
        public string name;

        [JsonProperty("description")]
        public string description;

        [JsonProperty("statistics")]
        public OverallStreamStatistics statistics;

        [JsonProperty("streams")]
        public List<StreamInfo> streams = new List<StreamInfo>();

        [JsonProperty("units")]
        public string units;

        [JsonProperty("data")]
        public List<Data> data = new List<Data>();
    }

    public class StreamInfo
    {
        [JsonProperty("name")]
        public string name;

        [JsonProperty("units")]
        public string units;

        [JsonProperty("type")]
        public string type;

    }
}
