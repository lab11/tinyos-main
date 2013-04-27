
configuration Counter32khz32C {
  provides {
    interface Counter<T32khz,uint32_t> as Counter;
  }
}

implementation {
  components HalCounter32khz32C;
  Counter = HalCounter32khz32C.Counter;
}
