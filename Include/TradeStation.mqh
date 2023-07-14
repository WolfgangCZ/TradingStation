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
    private:
        TradeManager* tradeManager;
        ConditionManager* conditionManager;
        NumberSeries* numberSeries;
        SimpleMA* simpleMA;       

    public:

        TradeStation(const UserInputManager *userInputManager)
        {
            tradeManager = new TradeManager(userInputManager);
            conditionManager = new ConditionManager();
            numberSeries = new NumberSeries();
            
            //OPTIONAL
            simpleMA = new SimpleMA(userInputManager);
        }
        ~TradeStation()
        {
            delete tradeManager;
            delete conditionManager;
            delete numberSeries;
            delete simpleMA;

        }
        void DoSomething()
        {

            ConditionCounter conditionCounter;
            conditionCounter.totalConditions = 0;
            conditionCounter.passedConditions = 0;
            numberSeries = simpleMA;
            
            //OPEN LONG TRADES LOGIC
            conditionManager.SlopeUp(simpleMA, conditionCounter);
            // Print("long condition checked");
            if(conditionManager.AllConditionsPassed(conditionCounter))
            {
                tradeManager.OpenLongTrade();
            }

            //OPEN SHORT TRADES LOGIC
            conditionManager.SlopeDown(simpleMA, conditionCounter);
            // Print("short condition checked");
            if(conditionManager.AllConditionsPassed(conditionCounter))
            {
                tradeManager.OpenShortTrade();
            }    

        }
};
