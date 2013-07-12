#include "OpoBase.h"
#include "printf.h"

configuration OpoBaseC {}

implementation {
  components MainC, OpoBaseP, LedsC;
  OpoBaseP.Boot -> MainC.Boot;
  OpoBaseP.Leds -> LedsC;

  components PrintfC;
  components SerialStartC;

  components ActiveMessageC;
  components new AMSenderC(OPO_ACK) as OpoAckSend;
  components new AMReceiverC(OPO_PROBE) as ProbeReceive;
  components new AMReceiverC(OPO_DATA) as DataReceive;

  OpoBaseP.ProbeReceive -> ProbeReceive;
  OpoBaseP.OpoAckSend -> OpoAckSend;
  OpoBaseP.DataReceive -> DataReceive;
  OpoBaseP.RfControl -> ActiveMessageC.SplitControl;
  OpoBaseP.AMPacket -> ActiveMessageC.AMPacket;

}
