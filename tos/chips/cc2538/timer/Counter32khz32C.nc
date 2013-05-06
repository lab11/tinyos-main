
/**
 * HIL layer for the 32 kHz 32 bit counter. Based on the sleep timer.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration Counter32khz32C {
  provides {
    interface Counter<T32khz,uint32_t> as Counter;
  }
}

implementation {
  components HalCounter32khz32C;
  Counter = HalCounter32khz32C.Counter;
}
