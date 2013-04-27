
/**
 * Useful BusyWait micro.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration BusyWaitMicroC {
  provides interface BusyWait<TMicro,uint16_t>;
}
implementation {
  components new BusyWaitCounterC(TMicro,uint16_t);
  components HalCounterMicro32C;

  BusyWait = BusyWaitCounterC.BusyWait;
  BusyWaitCounterC.Counter -> HalCounterMicro32C.Counter;
}
