//+------------------------------------------------------------------+
//|                                                       writer.mq5 |
//|                                    Copyright 2023, Peter Kozarec |
//|                                                                  |
//+------------------------------------------------------------------+
#include "writer.mqh"
#include "logger.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void writter::add_line(string line)
  {
   lines_.Add(line);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool writter::flush(string filename)
  {
   int file_handle = FileOpen(filename, FILE_READ | FILE_WRITE | FILE_CSV);

   if(file_handle == INVALID_HANDLE)
     {
      log_fatal("Could not open or create file " + filename);
      return false;
     }

   for(int i = 0; i < lines_.Total(); i++)
     {
      FileWriteString(file_handle, lines_.At(i));
     }

   FileClose(file_handle);
   return true;
  }
//+------------------------------------------------------------------+
