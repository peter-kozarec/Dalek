//+------------------------------------------------------------------+
//|                                                   aggregator.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//+------------------------------------------------------------------+
#ifndef DALEK_AGGREGATOR_MQH
#define DALEK_AGGREGATOR_MQH
//+------------------------------------------------------------------+
#include "defs.mqh"
#include "logger.mqh"
#include <Generic\HashMap.mqh>
//+------------------------------------------------------------------+
namespace aggregator
{
//+------------------------------------------------------------------+
//| Contains timestamp of last bars for aggregator subscribers       |
//+------------------------------------------------------------------+
CHashMap<string, datetime> last_bars_;
//+------------------------------------------------------------------+
//| Definition of callback called when new bar is aggregated         |
//+------------------------------------------------------------------+
typedef void (*on_aggregate_def)(ENUM_TIMEFRAMES);
//+------------------------------------------------------------------+
//| Call in on_tick event to aggregate ticks to the period to wich   |
//| EA is attached to and calls callback passed                      |
//+------------------------------------------------------------------+
void aggregate_ticks(on_aggregate_def aggregate_cb,
                     ENUM_TIMEFRAMES time_frame,
                     string aggregator_identifier)
  {
//---- Set initial datetime values
   if(!last_bars_.ContainsKey(aggregator_identifier))
     {
      last_bars_.Add(aggregator_identifier, iTime(_Symbol, time_frame, 0));
     } // if(!last_bars_.ContainsKey(id))

//---- Retrieve last bars datetime.
   datetime last_bar_time;
   if(!last_bars_.TryGetValue(aggregator_identifier, last_bar_time))
     {
      logger::log_warning(
         "Could not retrieve last bar time for " + 
         aggregator_identifier                   + 
         ". Therefore unable to aggregate bars");
      return;
     } // if(!last_bars.TryGetValue(aggregator_identifier, last_bar_time))

//--- Retrieve current bar time
   datetime curr_bar_tim = iTime(_Symbol, time_frame, 0);

//--- If the last bar time is not equal to current bar time, new bar created
   if(last_bar_time != curr_bar_tim)
     {
      //--- Set last bar time as current bar time
      last_bars_.TrySetValue(aggregator_identifier, curr_bar_tim);

      logger::log_debug("New bar aggregated - " + (string)time_frame);
      //--- Callback
      aggregate_cb(time_frame);
     } // if(last_bar_time != curr_bar_tim)
  } // aggregator::aggregate_ticks
//+------------------------------------------------------------------+
}; // namespace aggregator
//+------------------------------------------------------------------+
#endif // DALEK_AGGREGATOR_MQH