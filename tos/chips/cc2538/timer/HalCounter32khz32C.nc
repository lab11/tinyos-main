
/**
 * Provides a 32khz 32 bit counter from the hardware sleep timer.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration HalCounter32khz32C {
  provides {
    interface Counter<T32khz,uint32_t> as Counter;
  }
}

implementation {
  components HalCounter32khz32P;
  components HplTimerC;

  HalCounter32khz32P.HplSleepTimer -> HplTimerC.HplSleepTimer[0];

  Counter = HalCounter32khz32P.Counter;
}
