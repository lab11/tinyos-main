
/**
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration CounterMilli32C {
  provides interface Counter<TMilli,uint32_t>;
}
implementation {
  components HalCounter32khz32C as HalCounter;
  components new TransformCounterC(TMilli,uint32_t,T32khz,uint32_t,5,uint32_t) as Transform;
  Counter = Transform.Counter;

  Transform.CounterFrom -> HalCounter.Counter;
}
