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

input double userRewardRiskRatio = 1;
input double userAtrStopLossMultiplier = 5;
input int userMagicNumber = 111;
input int userBaseATR = 100;
input int userMaxOpenTrades = 1;

//optional userinputs

input uint userSimpleMAPeriod = 100;
input uint userExpMAPeriod = 100;


//implementation

TradeStation *tradeStation;
UserInputManager *userInputManager;

int OnInit()
{
    userInputManager = new UserInputManager();
    userInputManager.GrabUserInputs(
        userAtrStopLossMultiplier, 
        userRewardRiskRatio, 
        userMagicNumber, 
        userBaseATR, 
        userMaxOpenTrades, 
        userSimpleMAPeriod
    );
    tradeStation = new TradeStation(userInputManager);
    
    return(INIT_SUCCEEDED);
}


void OnTick()
{  
    tradeStation.Tester();
    
    
    //something like this??
    //tradeStation.OpenTradeLogic();
    //tradeStaton.CloseTradeLogic();
}

void OnDeinit(const int reason)
{
    delete tradeStation;
    delete userInputManager;
}