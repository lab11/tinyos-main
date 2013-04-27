
/**
 * Converts a 32 bit counter to 16 bits. Basically a cast.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration Counter32khz16C {
  provides interface Counter<T32khz,uint16_t>;
}
implementation {
  components Counter32khz16P;
  components Counter32khz32C as CounterFrom;

  Counter32khz16P.CounterFrom -> CounterFrom.Counter;

  Counter = Counter32khz16P.Counter;
}

