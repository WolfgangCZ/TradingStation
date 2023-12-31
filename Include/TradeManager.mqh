#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

#include <UserInputManager.mqh>

class TradeManager
{
// TODO implemtn trailing stoploss
// TODO implement pyramiding in
// TODO implement event SL and event TP
// TODO close last trade
// TOOD close all trades
// TODO implement magic number here instead of condition manager

    private:
        int tradeID;
        UserInputManager *parameters;

    public:
        //constructor
        TradeManager(UserInputManager *userParameters);

        void CalculateStopLoss();
        void SetRRR(double rrr);
        double GetLongATRStopLossPrice(double currentAtr, double entryPrice);
        double GetShortATRStopLossPrice(double currentAtr, double entryPrice);
        void OpenLongTrade(bool allowed);
        void OpenShortTrade(bool allowed);
        void CloseAllOpenTrades();
        //void closeLastTrade();
};

//======================================================================================
//=======================DEFINITIONS====================================================
//======================================================================================

        TradeManager::TradeManager(UserInputManager *userParameters) 
        {
            parameters = userParameters;
        }
        void TradeManager::SetRRR(double rrr)
        {
            parameters.rewardRiskRatio = rrr;
        }

        void TradeManager::CalculateStopLoss()
        {
            
        }
        double TradeManager::GetLongATRStopLossPrice(double currentAtr, double entryPrice)
        {
            return entryPrice - currentAtr;
        } 
        double TradeManager::GetShortATRStopLossPrice(double currentAtr, double entryPrice)
        {
            return entryPrice + currentAtr;
        } 
        //maybe do those two ambigously (if thats the word) i mean do one switchable function for both 
        void  TradeManager::OpenShortTrade(bool allowed)
        {
            if(allowed)
            {
                double atr = iATR(NULL,NULL, parameters.baseATR, 0);
                double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(parameters.atrSLMultiplier*atr, Bid), Digits);
                double profitPrice = NormalizeDouble(GetLongATRStopLossPrice(parameters.atrSLMultiplier * atr * parameters.rewardRiskRatio, Bid), Digits);
                tradeID = OrderSend(NULL, OP_SELL, 0.01, Bid, 10, stopLossPrice, profitPrice, "Short trade", parameters.magicNumber, 0, 0);
            }
        }
        void TradeManager::OpenLongTrade(bool allowed)
        {
            if(allowed)
            {
                double atr = iATR(NULL,NULL,100,0);
                double stopLossPrice = NormalizeDouble(GetLongATRStopLossPrice(parameters.atrSLMultiplier*atr, Ask), Digits);
                double profitPrice = NormalizeDouble(GetShortATRStopLossPrice(parameters.atrSLMultiplier*atr*parameters.rewardRiskRatio, Ask), Digits);
                tradeID = OrderSend(NULL, OP_BUY, 0.01, Ask, 10, stopLossPrice, profitPrice, "Long trade", parameters.magicNumber, 0, 0);
            }
        }
        void TradeManager::CloseAllOpenTrades()
        {
            Print("checking if there are some open orders");
            int totalOrders = OrdersTotal();
            for(int i = 0; i < totalOrders; i++)
            {
                if(OrderSelect(i,SELECT_BY_POS)==true)
                {
                    Print("inside order close - someorders are open and should be closed now");
                    int orderTicket = OrderTicket();
                    double orderLots = OrderLots();
                    if(OrderType() == 0)
                    {
                        bool success = OrderClose(orderTicket, orderLots, Bid, 10, 0);
                        Print("Long trade closed");
                    }
                    else
                    {
                        bool success = OrderClose(orderTicket, orderLots, Ask, 10, 0);
                        Print("Short trade closed");
                    } 
                }
            }
        }
