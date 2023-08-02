//+------------------------------------------------------------------+
//|                                                   aggregator.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Definition of callback called when new bar is aggregated         |
//+------------------------------------------------------------------+
typedef void (*on_aggregate_def)();
//+------------------------------------------------------------------+
//| Call in on_tick event to aggregate ticks to the period to wich   |
//| EA is attached to and calls callback passed                      |
//+------------------------------------------------------------------+
void aggregate_ticks(on_aggregate_def aggregate_cb);
//+------------------------------------------------------------------+