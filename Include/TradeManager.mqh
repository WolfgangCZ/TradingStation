#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

class TradeManager
{
// TODO implemtn trailing stoploss
// TODO implement pyramiding in
// TODO implement event SL and event TP
// TODO close last trade
// TOOD close all trades
// TODO implement magic number here instead of condition manager

    private:
        double riskRewardRatio;
        double stopLossDistance; //in price quote
        double atrStopLoss;
        int stopLossInPips;
        int takeProfitInPips;
        int tradeID;
        int magicNumber;

    public:
        //constructor riskreward
        TradeManager(double rrr, double atrSL, int magicNB);
        void CalculateStopLoss();
        void SetRRR(double rrr);
        double GetLongATRStopLossPrice(double currentAtr, double entryPrice);
        double GetShortATRStopLossPrice(double currentAtr, double entryPrice);
        void OpenLongTrade();
        void OpenShortTrade();
        void CloseAllOpenTrades();

        //void closeLastTrade();
};

//======================================================================================
//=======================DEFINITIONS====================================================
//======================================================================================

        TradeManager::TradeManager(double rrr, double atrSL, int magicNB) 
        {
            this.riskRewardRatio = rrr;
            this.atrStopLoss = atrSL;
            this.magicNumber = magicNB;
        }
        void TradeManager::SetRRR(double rrr)
        {
            riskRewardRatio = rrr;
        }

        void TradeManager::CalculateStopLoss()
        {
            
        }
        void  TradeManager::OpenShortTrade()
        {
            double atr = iATR(NULL,NULL,100,0);
            double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(atrStopLoss*atr, Bid), Digits);
            double profitPrice = NormalizeDouble(GetLongATRStopLossPrice(atrStopLoss*atr, Bid), Digits);
            tradeID = OrderSend(NULL, OP_SELL, 0.01, Bid, 10, stopLossPrice, profitPrice, "Short trade", magicNumber, 0, 0);
        }
        double TradeManager::GetLongATRStopLossPrice(double currentAtr, double entryPrice)
        {
            return entryPrice - currentAtr;
        } 
        double TradeManager::GetShortATRStopLossPrice(double currentAtr, double entryPrice)
        {
            return entryPrice + currentAtr;
        } 
        void TradeManager::OpenLongTrade()
        {
            double atr = iATR(NULL,NULL,100,0);
            double stopLossPrice = NormalizeDouble(GetLongATRStopLossPrice(atrStopLoss*atr, Ask), Digits);
            double profitPrice = NormalizeDouble(GetShortATRStopLossPrice(atrStopLoss*atr, Ask), Digits);
            tradeID = OrderSend(NULL, OP_BUY, 0.01, Ask, 10, stopLossPrice, profitPrice, "Long trade", magicNumber, 0, 0);
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
