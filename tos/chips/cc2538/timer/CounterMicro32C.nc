
/**
 * HIL layer for 32 bit mircosecond counter.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration CounterMicro32C {
  provides {
    interface Counter<TMicro,uint32_t>;
  }
}

implementation {
  components new HalCounterMicroP(uint32_t) as HalCounterMicro32P;
  components HplTimerC;

  HalCounterMicro32P.HplGpTimer -> HplTimerC.HplGpTimer32[0];

  Counter = HalCounterMicro32P.Counter;
}
