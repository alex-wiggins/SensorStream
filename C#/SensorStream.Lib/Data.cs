using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SensorStream
{
    public class Data
    {
        [JsonProperty("streamid")]
        public string streamid;

        [JsonProperty("time")]
        public string time;

        [JsonProperty("values")]
        public Dictionary<string, string> values;
    }

    public class DataAddResponse
    {
        [JsonProperty("streamid")]
        public string streamid;

        [JsonProperty("time")]
        public DateTimeOffset time;

        [JsonProperty("status")]
        public string status;
    }
}
