//+------------------------------------------------------------------+
//|                                                   aggregator.mq5 |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "aggregator.mqh"
#include "logger.mqh"
//+------------------------------------------------------------------+
//| Call in on_tick event to aggregate ticks to the period to wich   |
//| EA is attached to and calls callback passed                      |
//+------------------------------------------------------------------+
void aggregate_ticks(on_aggregate_def aggregate_cb)
  {
//--- Create last bar time static variable
   static datetime last_bar_time = iTime(_Symbol, _Period, 0);
//--- Retrieve current bar time
   datetime curr_bar_tim = iTime(_Symbol, _Period, 0);
//--- If the last bar time is not equal to current bar time, new bar
//--- is aggregated
   if(last_bar_time != curr_bar_tim)
     {
//--- Set last bar time as current bar time
      last_bar_time = curr_bar_tim;

      log_debug("New bar aggregated");
//--- Callback 
      aggregate_cb();
     }
  }
//+------------------------------------------------------------------+
