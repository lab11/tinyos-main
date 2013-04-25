/**
 * Initialization code
 *
 */
#include "hardware.h"

configuration PlatformC {
  provides {
    interface Init;
  }
}
implementation {
  components PlatformP;
  components MoteClockC;
  //components LedsC;

  //PlatformP.Leds -> LedsC;

  PlatformP.MoteClockInit -> MoteClockC.MoteClockInit;

  Init = PlatformP;
}
