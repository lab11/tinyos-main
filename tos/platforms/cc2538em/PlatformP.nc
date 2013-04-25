#include "hardware.h"

module PlatformP {
  provides {
    interface Init;
  }
  uses {
    interface Init as MoteClockInit;
    interface Init as LedsInit;
//    interface Leds;
  }
}
implementation {

  command error_t Init.init() {

    call MoteClockInit.init();
    call LedsInit.init();

    return SUCCESS;
  }

  // Fallback interface for LEDs if LedsC is not
  // used.
  default command error_t LedsInit.init() {
    return SUCCESS;
  }

}
