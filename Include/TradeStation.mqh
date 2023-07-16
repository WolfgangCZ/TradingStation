#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property version   "1.00"
#property strict

#include <TradeManager.mqh>
#include <UserInputManager.mqh>
#include <NumberSeries.mqh>
#include <ConditionManager.mqh>
#include <UserInputManager.mqh>
    
class TradeStation
{
    public:
        TradeManager* tradeManager;
        ConditionManager* conditionManager;
        NumberSeries* numberSeries; //virtual class used only for pointer
        UserInputManager *parameters;
        //OPTIONAL
        SimpleMA* simpleMA;       

        //METHODS
        TradeStation(UserInputManager *userParameters);
        ~TradeStation();
        void Tester();
};

TradeStation::TradeStation(UserInputManager *userParameters)
{
    tradeManager = new TradeManager(userParameters);
    conditionManager = new ConditionManager();
    
    //OPTIONAL
    simpleMA = new SimpleMA(userParameters);
}
TradeStation::~TradeStation()
{
    delete tradeManager;
    delete conditionManager;
    delete simpleMA;
}
void TradeStation::Tester()
{
    numberSeries = simpleMA;
    
    //OPEN LONG TRADES LOGIC
    conditionManager.IsValley(simpleMA);
    bool tradeLong = conditionManager.AllConditionsPassed();
    tradeManager.OpenLongTrade(tradeLong);

    //OPEN SHORT TRADES LOGIC
    conditionManager.IsPeak(simpleMA);
    bool tradeShort = conditionManager.AllConditionsPassed();
    tradeManager.OpenShortTrade(tradeShort);
}