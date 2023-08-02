//+------------------------------------------------------------------+
//|                                                        trend.mq5 |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "trend.mqh"
#include "math.mqh"
#include "logger.mqh"
#include "configuration.mqh"
//+------------------------------------------------------------------+
//| Check if is downtrend                                            |
//+------------------------------------------------------------------+
bool is_downtrend(const vector & lr, const double r_squared)
  {
   if(r_squared >= TREND_DETECTION_FIT_R_SQUARED_TRESHOLD)
     {
      if(lr[TREND_DETECTION_BAR_COUNT - 1] < lr[0])
        {
         return (true);
        }
     }
   return (false);
  }
//+------------------------------------------------------------------+
//| Check if is uptrend                                              |
//+------------------------------------------------------------------+
bool is_uptrend(const vector & lr, const double r_squared)
  {
   if(r_squared >= TREND_DETECTION_FIT_R_SQUARED_TRESHOLD)
     {
      if(lr[TREND_DETECTION_BAR_COUNT - 1] > lr[0])
        {
         return (true);
        }
     }
   return (false);
  }
//+------------------------------------------------------------------+
