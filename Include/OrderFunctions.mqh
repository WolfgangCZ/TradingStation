//+------------------------------------------------------------------+
//|                                               OrderFunctions.mqh |
//|                                                         Wolfgang |
//|                                  https://wolfgangtechnologies.cz |
//+------------------------------------------------------------------+
#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

#include <MarketFunctions.mqh>

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+


//functions in this file
/*
double OptimalLotSize(double maxRiskPrc, int maxLossInPips);
double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss);
bool CheckIfOpenOrdersByMagicNB(int magicNB);
double GetStopLossPrice(bool bIsLongPosition, double entryPrice, int maxLossInPips);
double CalculateTakeProfit(bool isLong, double entryPrice, int pips);
double CalculateStopLoss(bool isLong, double entryPrice, int pips);
*/

//implementations - definitions
double OptimalLotSize(double maxRiskPrc, int maxLossInPips)
{
  double accEquity = AccountEquity();
  //Print("accEquity: " + accEquity);
  
  double lotSize = MarketInfo(NULL,MODE_LOTSIZE);
  //Print("lotSize: " + lotSize);
  
  double tickValue = MarketInfo(NULL,MODE_TICKVALUE);
  
  if(Digits <= 3)
  {
   tickValue = tickValue /100;
  }
  
  //Print("tickValue: " + tickValue);
  
  double maxLossDollar = accEquity * maxRiskPrc;
  //Print("maxLossDollar: " + maxLossDollar);
  
  double maxLossInQuoteCurr = maxLossDollar / tickValue;
  //Print("maxLossInQuoteCurr: " + maxLossInQuoteCurr);
  
  double optimalLotSize = NormalizeDouble(maxLossInQuoteCurr /(maxLossInPips * GetPipValue())/lotSize,2);
  Print("lotSize: " + lotSize);
  return optimalLotSize;
}


double OptimalLotSize(double maxRiskPrc, double entryPrice, double stopLoss)
{
   int maxLossInPips = MathAbs(entryPrice - stopLoss)/GetPipValue();
   
   return OptimalLotSize(maxRiskPrc,maxLossInPips);
}



bool CheckIfOpenOrdersByMagicNB(int magicNB)
{
   int openOrders = OrdersTotal();
   
   for(int i = 0; i < openOrders; i++)
   {
      if(OrderSelect(i,SELECT_BY_POS)==true)
      {
         if(OrderMagicNumber() == magicNB) 
         {
            return true;
         }  
      }
   }
   return false;
}

double GetStopLossPrice(bool bIsLongPosition, double entryPrice, int maxLossInPips)
{
   double stopLossPrice;
   if (bIsLongPosition)
   {
      stopLossPrice = entryPrice - maxLossInPips * 0.0001;
   }
   else
   {
      stopLossPrice = entryPrice + maxLossInPips * 0.0001;
   }
   return stopLossPrice;
}

double CalculateTakeProfit(bool isLong, double entryPrice, int pips)
{
   double takeProfit;
   if(isLong)
   {
      takeProfit = entryPrice + pips * GetPipValue();
   }
   else
   {
      takeProfit = entryPrice - pips * GetPipValue();
   }
   
   return takeProfit;
}

double CalculateStopLoss(bool isLong, double entryPrice, int pips)
{
   double stopLoss;
   if(isLong)
   {
      stopLoss = entryPrice - pips * GetPipValue();
   }
   else
   {
      stopLoss = entryPrice + pips * GetPipValue();
   }
   return stopLoss;
}

double GetLongATRStopLossPrice(float currentAtr, float entryPrice)
{
   return entryPrice - currentAtr;
} 

double GetShortATRStopLossPrice(float currentAtr, float entryPrice)
{
   return entryPrice + currentAtr;
} 
