class UserInputManager
{
    public:
        double atrSLMultiplier; //how many atrs is gonna be stoploss
        double rewardRiskRatio;   
        int magicNumber;
        int baseATR;
        int maxOpenTrades; //maximum number of open trades
        uint threshold; //bottom treshold - upper threshold is calculated 100 - x
        uint simpleMAPeriod;
        uint expMAPeriod;
        uint stochaPeriod;
        uint levelSignifacance1;
        uint levelSignifacance2;
        uint levelSignifacance3;
        uint zoneSignificance1;
        uint zoneSignificance2;
        uint zoneSignificance3;

        void GrabUserInputs(double atrMulti, double rrr, int magicNb, int bATR, int maxTrades, uint smaPeriod);
};

        void UserInputManager::GrabUserInputs(double atrMulti, double rrr, int magicNb, int bATR, int maxTrades, uint smaPeriod)
        {
            this.atrSLMultiplier = atrMulti;
            this.rewardRiskRatio = rrr;
            this.magicNumber = magicNb;
            this.baseATR = bATR;
            this.maxOpenTrades = maxTrades;
            this.simpleMAPeriod = smaPeriod;
        }