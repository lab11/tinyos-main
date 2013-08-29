#include "OpoBase.h"

configuration OpoBaseC {}

implementation {
  components MainC, LedsC, SerialStartC, PrintfC, OpoBaseP;
  OpoBaseP.Boot -> MainC.Boot;
  OpoBaseP.Leds -> LedsC;

  components ActiveMessageC;
  components new AMReceiverC(OPO_DATA) as OpoReceive;
  components new AMReceiverC(OPO_BLINK) as BlinkReceive;

  OpoBaseP.OpoReceive -> OpoReceive;
  OpoBaseP.BlinkReceive -> BlinkReceive;
  OpoBaseP.RfControl -> ActiveMessageC.SplitControl;
  OpoBaseP.AMPacket -> ActiveMessageC.AMPacket;
}
