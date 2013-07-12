/**
 * Dallas/Maxim 1wire bus master
 *
 */

configuration OneWireMasterC {
  provides {
    interface OneWireReadWrite as OneWire;
  }
  uses {
    interface GeneralIO as Pin;
  }
}
implementation {
  components OneWireMasterP;

  components new BusyWaitCounterC(TMicro,uint16_t) as WillWait;
  components Msp430CounterMicroC;
  WillWait.Counter -> Msp430CounterMicroC;
  OneWireMasterP.BusyWait -> WillWait;
  OneWireMasterP.Pin = Pin;

  OneWire = OneWireMasterP.OneWire;
}
