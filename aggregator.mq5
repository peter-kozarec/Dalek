//+------------------------------------------------------------------+
//|                                                   aggregator.mq5 |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "aggregator.mqh"
#include "logger.mqh"
#include <Generic\HashMap.mqh>
//+------------------------------------------------------------------+
//| Call in on_tick event to aggregate ticks to the period to wich   |
//| EA is attached to and calls callback passed                      |
//+------------------------------------------------------------------+
void aggregate_ticks(on_aggregate_def aggregate_cb, ENUM_TIMEFRAMES tf)
  {
//--- Create last bar time static variable
   static CHashMap<ENUM_TIMEFRAMES, datetime> last_bars;

   if(!last_bars.ContainsKey(tf))
     {
      last_bars.Add(tf, iTime(_Symbol, tf, 0));
     }

   datetime last_bar_time;
   if(!last_bars.TryGetValue(tf, last_bar_time))
     {
      log_warning("Could not retrieve last bar time. Therefore unable to aggregate bars");
      return;
     }

//--- Retrieve current bar time
   datetime curr_bar_tim = iTime(_Symbol, tf, 0);
//--- If the last bar time is not equal to current bar time, new bar
//--- is aggregated
   if(last_bar_time != curr_bar_tim)
     {
      //--- Set last bar time as current bar time
      last_bars.TrySetValue(tf, curr_bar_tim);

      log_debug("New bar aggregated - " + (string)tf);
      //--- Callback
      aggregate_cb(tf);
     }
  }
//+------------------------------------------------------------------+
