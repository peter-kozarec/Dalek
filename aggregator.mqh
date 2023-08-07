//+------------------------------------------------------------------+
//|                                                   aggregator.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef DALEK_AGGREGATOR_MQH
#define DALEK_AGGREGATOR_MQH
//+------------------------------------------------------------------+
//| Definition of callback called when new bar is aggregated         |
//+------------------------------------------------------------------+
typedef void (*on_aggregate_def)(ENUM_TIMEFRAMES);
//+------------------------------------------------------------------+
//| Call in on_tick event to aggregate ticks to the period to wich   |
//| EA is attached to and calls callback passed                      |
//+------------------------------------------------------------------+
void aggregate_ticks(on_aggregate_def aggregate_cb, ENUM_TIMEFRAMES tf);
//+------------------------------------------------------------------+
#endif