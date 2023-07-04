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
input double atrStopLossMultiplier = 2;
input uint simpleMAPeriod = 5;

TradeManager* tradeManager;
ConditionManager* conditionManager;
NumberSeries* numberSeries;
SimpleMA* simpleMA;

int OnInit()
{
    simpleMA = new SimpleMA(simpleMAPeriod);
    tradeManager = new TradeManager(riskRewardRatio, atrStopLossMultiplier, 111);
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
    //numberSeries = simpleMA;
    conditionManager.IsPeak(simpleMA);
    if(conditionManager.AllConditionsPassed())
    {
        tradeManager.OpenLongTrade();
    }

    conditionManager.IsValley(simpleMA);
    if(conditionManager.AllConditionsPassed())
    {
        tradeManager.OpenShortTrade();
    }    
}
