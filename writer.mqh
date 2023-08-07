//+------------------------------------------------------------------+
//|                                                       writer.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#ifndef DALEK_WRITER_MQH
#define DALEK_WRITER_MQH
//+------------------------------------------------------------------+
#include <Arrays\ArrayString.mqh>

//|                                                                  |
//+------------------------------------------------------------------+
class writter
  {
   CArrayString      lines_;
public:
   void              add_line(string line);
   bool              flush(string filename);
  };
//+------------------------------------------------------------------+
#endif