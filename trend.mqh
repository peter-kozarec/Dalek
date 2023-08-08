//+------------------------------------------------------------------+
//|                                                        trend.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef DALEK_TREND_MQH
#define DALEK_TREND_MQH
//+------------------------------------------------------------------+
namespace trend
{
//+------------------------------------------------------------------+
//| Check if is downtrend                                            |
//+------------------------------------------------------------------+
bool is_downtrend(const vector & estimates, const double r_sqrd)
  {
   return false;
  } // trend::is_downtrend
//+------------------------------------------------------------------+
//| Check if is uptrend                                              |
//+------------------------------------------------------------------+
bool is_uptrend(const vector & estimates, const double r_sqrd)
  {
   return false;
  } // trend::is_uptrend
//+------------------------------------------------------------------+
//| Check if is uptrend                                              |
//+------------------------------------------------------------------+
bool is_consolidating(const vector & estimates, const double r_sqrd)
  {
   return false;
  } // trend::is_consolidating
//+------------------------------------------------------------------+
}; // namespace trend
//+------------------------------------------------------------------+
#endif