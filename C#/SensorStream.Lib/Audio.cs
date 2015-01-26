using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace SensorStream
{
    public class Audio
    {
        public class AudioData
        {
            [JsonProperty("streamid")]
            public string streamid;

            [JsonProperty("time")]
            public string time;

            [JsonProperty("value")]
            public string value;

            [JsonProperty("speechtotext")]
            public string speechtotext;

            [JsonProperty("words")]
            public List<String> words;

            [JsonProperty("wordscores")]
            public List<double> wordscores;
        }
    }
}
