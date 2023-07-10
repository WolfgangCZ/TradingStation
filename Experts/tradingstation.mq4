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
    Print("EA initialized");
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
    Print("EA deinitialized");
}

void OnTick()
{  
    Print("EA started");
    ConditionCounter conditionCounter;
    conditionCounter.totalConditions = 0;
    conditionCounter.passedConditions = 0;
    numberSeries = simpleMA;
    
    //CLOSE LONG TRADE LOGIC
    conditionManager.SlopeUp(simpleMA, conditionCounter);
    conditionManager.IsShortTradeOpen(userMagicNumber, conditionCounter);
    if(conditionManager.AllConditionsPassed(conditionCounter))
    {
        tradeManager.CloseAllOpenTrades();
    }

    //CLOSE SHORT TRADE LOGIC
    conditionManager.SlopeDown(simpleMA, conditionCounter);
    conditionManager.IsLongTradeOpen(userMagicNumber, conditionCounter);
    if(conditionManager.AllConditionsPassed(conditionCounter))
    {
        tradeManager.CloseAllOpenTrades();
    }

    //OPEN LONG TRADES LOGIC
    conditionManager.SlopeUp(simpleMA, conditionCounter);
    conditionManager.IsShortTradeOpen(userMagicNumber, conditionCounter);
    // Print("long condition checked");
    if(conditionManager.AllConditionsPassed(conditionCounter))
    {
        tradeManager.OpenLongTrade();
    }

    //OPEN SHORT TRADES LOGIC
    conditionManager.SlopeDown(simpleMA, conditionCounter);
    conditionManager.IsLongTradeOpen(userMagicNumber, conditionCounter);
    // Print("short condition checked");
    if(conditionManager.AllConditionsPassed(conditionCounter))
    {
        tradeManager.OpenShortTrade();
    }    



}
