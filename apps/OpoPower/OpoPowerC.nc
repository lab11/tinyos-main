#include "printf.h"
configuration OpoPowerC {}

implementation {
    components MainC, PrintfC, SerialStartC, OpoPowerP;
    OpoPowerP.Boot -> MainC.Boot;

    components ActiveMessageC;
    OpoPowerP.RfControl -> ActiveMessageC.SplitControl;

    components At45dbPowerC;
    OpoPowerP.FlashPower -> At45dbPowerC.SplitControl;

    components new TimerMilliC() as PowerTimer;
    OpoPowerP.PowerTimer -> PowerTimer;

    components HplMsp430GeneralIOC;
    OpoPowerP.VPIN -> HplMsp430GeneralIOC.Port45;



}