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



int OnInit()
{
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{

}

void OnTick()
{  
    int currentHour = TimeHour(TimeCurrent());
    Print("current hour: " + currentHour);
}
