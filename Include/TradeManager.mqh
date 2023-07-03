#property copyright "Wolfgang"
#property link      "https://wolfgangtechnologies.cz"
#property strict

//

class TradeManager
{
    public:
        TradeManager()
        {}
        //constructor riskreward
        TradeManager(int number) 
        {
            member = number;
        }

    public:
        int member;
};