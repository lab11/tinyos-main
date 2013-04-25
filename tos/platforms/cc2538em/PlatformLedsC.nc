#include "hardware.h"

configuration PlatformLedsC {
  provides {
    interface GeneralIO as Led0;
    interface GeneralIO as Led1;
    interface GeneralIO as Led2;
  }
  uses {
    interface Init;
  }
}
implementation {
  // PlatformP will now specifically
  // call the Init interface of PlatformLeds.
  components PlatformP;
  components PlatformLedsP;
  components HplCC2538GeneralIOC as GeneralIOC;

  components new CC2538GpioC() as Led0Impl;
  components new CC2538GpioC() as Led1Impl;
  components new CC2538GpioC() as Led2Impl;

  Init = PlatformP.LedsInit;

  Led0Impl.IO -> GeneralIOC.HplPinC0;
  Led1Impl.IO -> GeneralIOC.HplPinC1;
  Led2Impl.IO -> GeneralIOC.HplPinC2;

  // Wire through PlatformLedsP because we need to invert clr & set
  PlatformLedsP.LedIn0 -> Led0Impl.GeneralIO;
  PlatformLedsP.LedIn1 -> Led1Impl.GeneralIO;
  PlatformLedsP.LedIn2 -> Led2Impl.GeneralIO;

  Led0 = PlatformLedsP.Led0;
  Led1 = PlatformLedsP.Led1;
  Led2 = PlatformLedsP.Led2;
}
