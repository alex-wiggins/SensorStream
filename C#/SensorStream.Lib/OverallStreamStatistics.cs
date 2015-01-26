using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SensorStream
{
    public class OverallStreamStatistics
    {
        public string streamid;
        public long count;
        public DateTimeOffset firstentry;
        public DateTimeOffset lastentry;
        public Dictionary<string, IndividualStreamStatistics> streamstats = new Dictionary<string, IndividualStreamStatistics>();
    }

    public class IndividualStreamStatistics
    {
        public string id;
        public long count;
        public double variance;
        public double mean;
        public double m2;
        public double min;
        public double max;
        public double stddev;
    }
}
