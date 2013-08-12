#include "printf.h"
#include "OpoTx.h"

configuration OpoTxC {}

implementation {
    components OpoTxP, MainC, LedsC, PrintfC, SerialStartC;
    OpoTxP.Boot -> MainC.Boot;
    OpoTxP.Leds -> LedsC.Leds;

    components Ds2411C, RandomC;
    OpoTxP.IdReader -> Ds2411C;
    OpoTxP.Random -> RandomC;

    components OpoC;
    OpoTxP.Opo -> OpoC.Opo;

    components ActiveMessageC;
    components new AMSenderC(OPO) as OpoRfSend;
    components new AMSenderC(PREP) as PrepSend;
    components new AMReceiverC(OPO) as OpoRfReceive;

    //OpoTxP.RfControl -> ActiveMessageC.SplitControl;
    OpoTxP.PrepSend -> PrepSend;
    OpoC.AMSend -> OpoRfSend;
    OpoC.AMReceive -> OpoRfReceive;
    OpoC.RfControl -> ActiveMessageC.SplitControl;

    components CC2420ControlC;
    OpoTxP.CC2420Config -> CC2420ControlC.CC2420Config;

    components At45dbPowerC;
    OpoTxP.At45dbPower -> At45dbPowerC;

    components HplMsp430GeneralIOC as GpIO;
    OpoTxP.AMP3_ADC -> GpIO.AMP3_ADC;
    OpoTxP.SFDIntGpio -> GpIO.SFDPIN;

    components new TimerMilliC() as TxTimer;
    OpoTxP.TxTimer -> TxTimer;
}