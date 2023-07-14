#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <TradeStation.mqh>

//TODO how to propagate parameters to trade manager without declaring variables twice?? 
//forward input manager to trademanager without declaring it in tradestation?????


//base user inputs

input double userRiskRewardRatio = 0.01;
input double userAtrStopLossMultiplier = 5;
input int userMagicNumber = 111;
input int userBaseATR = 100;

//optional userinputs

input uint userSimpleMAPeriod = 100;


//implementation

TradeStation *tradeStation;
UserInputManager *userInputManager;

int OnInit()
{
    userInputManager = new UserInputManager();
    userInputManager.atrSLMultiplier = userAtrStopLossMultiplier;
    userInputManager.rewardRiskRatio = userRiskRewardRatio;
    userInputManager.magicNumber = userMagicNumber;
    userInputManager.baseATR = userBaseATR;
    userInputManager.simpleMAPeriod = 200;

    tradeStation = new TradeStation(userInputManager);
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    delete tradeStation;
    delete userInputManager;
}

void OnTick()
{  
    tradeStation.DoSomething();
}
