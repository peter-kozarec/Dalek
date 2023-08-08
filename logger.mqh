//+------------------------------------------------------------------+
//|                                                       logger.mqh |
//|                                    Copyright 2023, Peter Kozarec |
//+------------------------------------------------------------------+
#ifndef DALEK_LOGGER_MQH
#define DALEK_LOGGER_MQH
//+------------------------------------------------------------------+
namespace logger
{
//+------------------------------------------------------------------+
//| Logs debug message                                               |
//+------------------------------------------------------------------+
void log_debug(string message)
  {
   if(configuration::logger_level <= defs::DEBUG)
     {
      Print("[DEBUG] " + message);
     } // if(configuration::logger_level <= defs::DEBUG)
  } // logger::log_debug
//+------------------------------------------------------------------+
//| Logs info message                                                |
//+------------------------------------------------------------------+
void log_info(string message)
  {
   if(configuration::logger_level <= defs::INFO)
     {
      Print("[INFO] " + message);
     } // if(configuration::logger_level <= defs::INFO)
  } // logger::log_info
//+------------------------------------------------------------------+
//| Logs warning message                                             |
//+------------------------------------------------------------------+
void log_warning(string message)
  {
   if(configuration::logger_level <= defs::WARNING)
     {
      Print("[WARNING] " + message);
     } // if(configuration::logger_level <= defs::WARNING)
  } // logger::log_warning
//+------------------------------------------------------------------+
//| Logs error message                                               |
//+------------------------------------------------------------------+
void log_error(string message)
  {
   if(configuration::logger_level <= defs::ERROR)
     {
      Print("[ERROR] " + message);
     } // if(configuration::logger_level <= defs::ERROR)
  } // logger::log_error
//+------------------------------------------------------------------+
//| Logs fatal message                                               |
//+------------------------------------------------------------------+
void log_fatal(string message)
  {
   if(configuration::logger_level <= defs::FATAL)
     {
      Print("[FATAL] " + message);
     } // if(configuration::logger_level <= defs::FATAL)
  } // logger::log_fatal
//+------------------------------------------------------------------+
}; // namespace logger
//+------------------------------------------------------------------+
#endif // DALEK_LOGGER_MQH