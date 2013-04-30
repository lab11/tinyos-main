
/**
 * Converts a hardware timer to the generic Alarm interface.
 *
 * @author Brad Campbell <bradjc@umich.edu>
 */

generic configuration AlarmMicro32C () {
  provides {
  	interface Init;
    interface Alarm<TMicro,uint32_t>;
  }
}

implementation {
  components new HalTimerMicro32C() as HardwareTimerMicro32;
  components new HalAlarmP(TMicro, 32, uint32_t) as AlarmMicro32;

  Init = AlarmMicro32.Init;
  Alarm = AlarmMicro32.Alarm;

  AlarmMicro32.HalTimer -> HardwareTimerMicro32.HalTimer;
}
