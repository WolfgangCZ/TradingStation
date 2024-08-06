//+------------------------------------------------------------------+
//|                                                     EAtester.mq4 |
//|                                                         Wolfgang |
//|                                  https://wolfgangtechnologies.cz |
//+------------------------------------------------------------------+
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <indicators.mqh>
#include <TriggerFunctions.mqh>

datetime LastActionTime = 0;

int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
   // Comparing LastActionTime with the current starting time for the candle.
   if (LastActionTime != Time[0])
   {
      // Code to execute once per bar.
      double lag = iLaguerreFilter(int pos, int period, double gamma)
      
      
      LastActionTime = Time[0];
   }
}
//+------------------------------------------------------------------+
