
generic configuration Alarm32khz16C () {
  provides {
    interface Init;
    interface Alarm<T32khz,uint16_t>;
  }
}

implementation {
  components new Alarm32khz32C() as AlarmC;
  components Counter32khz16C as Counter;
  components new TransformAlarmC(T32khz,uint16_t,T32khz,uint32_t,0) as Transform;

  Init = AlarmC.Init;
  Alarm = Transform.Alarm;

  Transform.AlarmFrom -> AlarmC.Alarm;
  Transform.Counter -> Counter.Counter;
}
