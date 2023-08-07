//+------------------------------------------------------------------+
//|                                                         defs.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef DALEK_DEFS_MQH
#define DALEK_DEFS_MQH
//+------------------------------------------------------------------+
//| Logging level                                                    |
//+------------------------------------------------------------------+
enum LogLevel
  {
   DEBUG    = 0,
   INFO     = 1,
   WARNING  = 2,
   ERROR    = 3,
   FATAL    = 4,
   NO_LOGS  = 5
  };
//+------------------------------------------------------------------+
//| Trend direction                                                  |
//+------------------------------------------------------------------+
enum TrendDirection
  {
   UNKNOWN = 0,
   RISING = 1,
   CONSOLIDATING = 2,
   FALLING = 3
  };
//+------------------------------------------------------------------+
#endif
