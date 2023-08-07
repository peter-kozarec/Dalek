//+------------------------------------------------------------------+
//|                                                     strategy.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef DALEK_STRATEGY_MQH
#define DALEK_STRAGEGY_MQH
//+------------------------------------------------------------------+
//| Detect breakout                                                  |
//+------------------------------------------------------------------+
void detect_breakout(ENUM_TIMEFRAMES tf);
//+------------------------------------------------------------------+
//| Detect trend                                                     |
//+------------------------------------------------------------------+
void detect_trend(ENUM_TIMEFRAMES tf);
//+------------------------------------------------------------------+
#endif