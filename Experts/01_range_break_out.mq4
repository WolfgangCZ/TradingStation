
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property version   "1.00"
#property strict

#include <OrderFunctions.mqh>
#include <MarketFunctions.mqh>
#include <TriggerFunctions.mqh>

input int numberCandlesLookback = 5;
input double lastCandleRatio = 4;
input bool isLastCandleCompleted = false;

int shortOrderID = 0;
int longOrderID = 0;
bool isShortOpen = false;
bool isLongOpen = false;
double testLotSize = 0.01;
int magicNumber = 1;

int OnInit()
{
    return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

void OnTick()
{
    double currentATR = iATR(NULL, NULL, 4*numberCandlesLookback, 0);
    if(RangeBreakOut(numberCandlesLookback, lastCandleRatio, isLastCandleCompleted) == 1)
    {
        //openOrderID = OrderSend(NULL,OP_SELLLIMIT,lotSize,Bid,10,stopLossPrice,takeProfitPrice,NULL,magicNB);
        
        if(shortOrderID != 0)
        {
            bool lastOrderSelected = OrderSelect(shortOrderID, SELECT_BY_TICKET, MODE_TRADES);
            bool lastOrderClosed = OrderClose(shortOrderID, OrderLots(), Ask, 10);
            Print("last order was selected: " + string(lastOrderSelected) 
                + ", last order was closed: " + string(lastOrderClosed));
            isShortOpen = false;
            shortOrderID = 0;
        }
        if(isLongOpen == false)
            {
            double stopLossPrice = NormalizeDouble(GetLongATRStopLossPrice(currentATR, Ask),Digits);
            longOrderID = OrderSend(NULL, OP_BUY, testLotSize, Ask, 10, NULL, NULL, NULL, magicNumber);
            isLongOpen = true;
            }
        }
        
    if(RangeBreakOut(numberCandlesLookback, lastCandleRatio, isLastCandleCompleted) == -1)
    {
        if(longOrderID != 0)
        {
            bool lastOrderSelected = OrderSelect(longOrderID, SELECT_BY_TICKET, MODE_TRADES);
            bool lastOrderClosed = OrderClose(longOrderID, OrderLots(), Bid, 10);
            Print("last order was selected: " + string(lastOrderSelected)
                + ", last order was closed: " + string(lastOrderClosed));
            isLongOpen = false;
            longOrderID = 0;
        }
        if(isShortOpen == false)
        {
            double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(currentATR, Bid),Digits);
            shortOrderID = OrderSend(NULL, OP_SELL, testLotSize, Bid, 10, NULL, NULL, NULL, magicNumber);
            isShortOpen = true;
        }
    }
}
//+------------------------------------------------------------------+
