#include "printf.h"
#include "OpoRx.h"

configuration OpoRxC {}

implementation {
    components OpoRxP, MainC, LedsC, PrintfC, SerialStartC;
    OpoRxP.Boot -> MainC.Boot;
    OpoRxP.Leds -> LedsC.Leds;

    components Ds2411C, RandomC;
    OpoRxP.IdReader -> Ds2411C;
    OpoRxP.Random -> RandomC;

    components OpoC;
    OpoRxP.Opo -> OpoC.Opo;

    components ActiveMessageC;
    components new AMSenderC(OPO) as OpoRfSend;
    components new AMReceiverC(OPO) as OpoRfReceive;

    OpoRxP.Packet -> ActiveMessageC.Packet;
    OpoC.AMSend -> OpoRfSend;
    OpoC.AMReceive -> OpoRfReceive;
    OpoC.RfControl -> ActiveMessageC.SplitControl;

    components CC2420ControlC;
    OpoRxP.CC2420Config -> CC2420ControlC.CC2420Config;

    components At45dbPowerC;
    OpoRxP.At45dbPower -> At45dbPowerC;

    components new TimerMilliC() as RxTimer;
    OpoRxP.RxTimer -> RxTimer;
}