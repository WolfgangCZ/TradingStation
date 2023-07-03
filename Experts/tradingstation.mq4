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

#include <TradeManager.mqh>
#include <PriceSeries.mqh>


TradeManager tradeManager;


int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{  
    tradeManager.member = 10;
    Print("zkouska member: " + string(tradeManager.member));
}
