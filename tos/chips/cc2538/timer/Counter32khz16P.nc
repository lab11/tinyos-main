
/**
 * Whole stupid class to do a cast of a uint32_t to uint16_t.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

module Counter32khz16P {
  provides {
    interface Counter<T32khz, uint16_t>;
  }
  uses {
    interface Counter<T32khz, uint32_t> as CounterFrom;
  }
}

implementation {
  async command uint16_t Counter.get () {
    return (uint16_t) call CounterFrom.get();
  }

  async command bool Counter.isOverflowPending () {
    return call CounterFrom.isOverflowPending();
  }

  async command void Counter.clearOverflow () {
    call CounterFrom.clearOverflow();
  }

  async event void CounterFrom.overflow () {
    signal Counter.overflow();
  }
}
