
/**
 * Provides a counter interface from an HPL general purpose timer.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

generic module HalCounterMicroP (typedef size_type @integer()) {
  provides {
    interface Counter<TMicro,size_type>;
  }
  uses {
    interface HplGpTimer<size_type>;
  }
}

implementation {
  async command size_type Counter.get () {
    return (size_type) call HplGpTimer.get();
  }

  async command bool Counter.isOverflowPending () {
    return FALSE;
  }

  async command void Counter.clearOverflow () { }

  async event void HplGpTimer.fired () { }
}
