#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

class TradeManager
{
// TODO implemtn trailing stoploss
// TODO implement pyramiding in
// TODO implement event SL and event TP


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
        TradeManager(double rrr, double atrSL, int magicNB) 
        {
            this.riskRewardRatio = rrr;
            this.atrStopLoss = atrSL;
            this.magicNumber = magicNB;
        }


        void CalculateStopLoss()
        {
            
        }
        //void closeLastTrade();
        void SetRRR(double rrr)
        {
            riskRewardRatio = rrr;
        }
        double GetLongATRStopLossPrice(double currentAtr, double entryPrice)
        {
            return entryPrice - currentAtr;
        } 

        double GetShortATRStopLossPrice(double currentAtr, double entryPrice)
        {
            return entryPrice + currentAtr;
        } 

        void OpenLongTrade()
        {
            double atr = iATR(NULL,NULL,100,0);
            double stopLossPrice = NormalizeDouble(GetLongATRStopLossPrice(atrStopLoss*atr, Ask), Digits);
            double profitPrice = NormalizeDouble(GetShortATRStopLossPrice(atrStopLoss*atr, Ask), Digits);
            tradeID = OrderSend(NULL, OP_BUY, 0.01, Ask, 10, stopLossPrice, profitPrice, "Long trade", magicNumber, 0, 0);
        }
        void OpenShortTrade()
        {
            double atr = iATR(NULL,NULL,100,0);
            double stopLossPrice = NormalizeDouble(GetShortATRStopLossPrice(atrStopLoss*atr, Bid), Digits);
            double profitPrice = NormalizeDouble(GetLongATRStopLossPrice(atrStopLoss*atr, Bid), Digits);
            tradeID = OrderSend(NULL, OP_SELL, 0.01, Bid, 10, stopLossPrice, profitPrice, "Long trade", magicNumber, 0, 0);
        }

};
