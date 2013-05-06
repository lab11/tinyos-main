
/**
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration CounterMilli16C {
  provides {
  	interface Counter<TMilli,uint16_t>;
  }
}
implementation {
  components Counter32khz16C as HalCounter;
  components new TransformCounterC(TMilli,uint16_t,T32khz,uint16_t,5,uint32_t) as Transform;
  Counter = Transform.Counter;

  Transform.CounterFrom -> HalCounter.Counter;
}
