
/**
 * HIL layer for 16 bit mircosecond counter.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration CounterMicro16C {
  provides {
    interface Counter<TMicro,uint16_t>;
  }
}

implementation {
  components new HalCounterMicroP(uint16_t) as HalCounterMicro16P;
  components HplTimerC;

  HalCounterMicro16P.HplGpTimer -> HplTimerC.HplGpTimer16[0];

  Counter = HalCounterMicro16P.Counter;
}
