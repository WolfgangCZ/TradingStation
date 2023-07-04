#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

#include <NumberSeries.mqh>

class ConditionManager
{
    private:
        uint passedConditions;
        uint totalConditions;

    public:
        ConditionManager()
        {
            passedConditions = 0;
            totalConditions = 0; 
        }

        bool IsPeak(NumberSeries* numbers)
        {
            numbers.update();
            totalConditions++;
            if((numbers.firstNumber < numbers.secondNumber) && (numbers.secondNumber > numbers.thirdNumber))
            {
                Print("Long trade conditions fullfilled");
                passedConditions++;
                return true;
            }
            else 
                return false;
        }   
        bool IsValley(NumberSeries* numbers)
        {
            numbers.update();
            totalConditions++;
            if((numbers.firstNumber > numbers.secondNumber) && (numbers.secondNumber < numbers.thirdNumber))
            {
                Print("Short trade conditions fullfilled");
                passedConditions++;
                return true;
            }
            else 
            {
                passedConditions = 0;
                totalConditions = 0;
                return false;
            }
        }  
        bool AllConditionsPassed()
        {
            Print("Inside all conditions passed");
            Print("Passed conditions" + string(passedConditions) + " total conditions: " + string(totalConditions));
            if(passedConditions == totalConditions && totalConditions != 0)
            {
                passedConditions = 0;
                totalConditions = 0;
                return true;
            }
            else
            {
                passedConditions = 0;
                totalConditions = 0;
                return false;
            } 
        }
        double PercentageConditionsPassed()
        {
            if(totalConditions != 0 && passedConditions != 0)
            {
                double percentage = passedConditions / totalConditions;
                totalConditions = 0;
                passedConditions = 0;
                return percentage;
            }    
            else 
                return 0;
        }
        //cross under
        //cross over
};