
/**
 * Bridges the hardware specific timer to a general counter interface.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

module HalCounter32khz32P {
  provides {
    interface Counter<T32khz,uint32_t> as Counter;
  }
  uses {
    interface HplSleepTimer;
  }
}

implementation {
  async command uint32_t Counter.get() {
    return call HplSleepTimer.get();
  }

  async command bool Counter.isOverflowPending() {
    return FALSE;
  }

  async command void Counter.clearOverflow() { }

  async event void HplSleepTimer.fired () { }
}
