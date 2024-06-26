//+------------------------------------------------------------------+
//|                                                       writer.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//+------------------------------------------------------------------+
#ifndef DALEK_WRITTER_MQH
#define DALEK_WRITTER_MQH
//+------------------------------------------------------------------+
#include <Arrays\ArrayString.mqh>
//+------------------------------------------------------------------+
namespace writter
{
//+------------------------------------------------------------------+
//| File writter class                                               |
//+------------------------------------------------------------------+
class FileWritter
  {
   //+------------------------------------------------------------------+
   //| Contains buffer                                                  |
   //+------------------------------------------------------------------+
   CArrayString lines_;
public:
   //+------------------------------------------------------------------+
   //| Add line to the buffer                                           |
   //+------------------------------------------------------------------+
   void add_line(string line)
     {
      lines_.Add(line);
     }
   //+------------------------------------------------------------------+
   //| Flush lines into file                                            |
   //+------------------------------------------------------------------+
   bool flush(string filename)
     {
      int file_handle = FileOpen(filename,
                                 FILE_READ | FILE_WRITE | FILE_CSV);

      if(file_handle == INVALID_HANDLE)
        {
         logger::log_fatal("Could not open or create file " + filename);
         return false;
        } // if(file_handle == INVALID_HANDLE)

      for(int i = 0; i < lines_.Total(); i++)
        {
         FileWriteString(file_handle, lines_.At(i));
        } // for(int i = 0; i < lines_.Total(); i++)

      FileClose(file_handle);
      return true;
     }
   //+------------------------------------------------------------------+
  }; // class FileWritter
//+------------------------------------------------------------------+
}; // namespace writter
//+------------------------------------------------------------------+
#endif // DALEK_WRITTER_MQH