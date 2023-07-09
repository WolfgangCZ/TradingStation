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
#include <NumberSeries.mqh>
#include <ConditionManager.mqh>
    
input double riskRewardRatio = 0.01;
input double atrStopLossMultiplier = 5;
input uint simpleMAPeriod = 100;

input int userMagicNumber = 111;

TradeManager* tradeManager;
ConditionManager* conditionManager;
NumberSeries* numberSeries;
SimpleMA* simpleMA;

int OnInit()
{
    simpleMA = new SimpleMA(simpleMAPeriod);
    tradeManager = new TradeManager(riskRewardRatio, atrStopLossMultiplier, userMagicNumber);
    conditionManager = new ConditionManager();
    //numberSeries = new NumberSeries();
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    delete tradeManager;
    delete conditionManager;
    delete simpleMA;
}

void OnTick()
{  
    numberSeries = simpleMA;
    
    //LONG TRADES LOGIC

    conditionManager.SlopeUp(simpleMA);
    conditionManager.MaxOrdersReached(1);
    if(conditionManager.AllConditionsPassed())
    {
        tradeManager.CloseAllOpenTrades();
        tradeManager.OpenLongTrade();
    }

    //SHORT TRADES LOGIC

    conditionManager.SlopeDown(simpleMA);
    conditionManager.MaxOrdersReached(1);
    if(conditionManager.AllConditionsPassed())
    {
        tradeManager.CloseAllOpenTrades();
        tradeManager.OpenShortTrade();
    }    
}
