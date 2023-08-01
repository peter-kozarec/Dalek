//+------------------------------------------------------------------+
//|                                                     strategy.mq5 |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "strategy.mqh"
#include "configuration.mqh"
#include "trend.mqh"
#include "logger.mqh"
//+------------------------------------------------------------------+
//| Entry point of a strategy called on new aggregated bar           |
//+------------------------------------------------------------------+
void on_bar_aggregated()
  {
   MqlRates rates[];

   if(CopyRates(_Symbol, _Period, 1, TREND_DETECTION_BAR_COUNT, rates) <= 0)
     {
      log_error("Could not retrieve rates.");
      return;
     }

   static bool was_uptrend = false;
   if(is_uptrend(rates))
     {

      if(!was_uptrend)
        {
         log_info("Uptrend started");
         was_uptrend = true;
        }
     }
   else
     {
      if(was_uptrend)
        {
         log_info("Uptrend ended");
         was_uptrend = false;
        }
     }

   static bool was_downtrend = false;
   if(is_downtrend(rates))
     {

      if(!was_downtrend)
        {
         log_info("Downtrend started");
         was_downtrend = true;
        }
     }
   else
     {
      if(was_downtrend)
        {
         log_info("Downtrend ended");
         was_downtrend = false;
        }
     }
  }
//+------------------------------------------------------------------+
