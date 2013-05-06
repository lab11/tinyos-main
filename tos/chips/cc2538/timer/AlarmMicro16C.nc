
/**
 * Converts a hardware timer to the generic Alarm interface.
 *
 * @author Brad Campbell <bradjc@umich.edu>
 */

generic configuration AlarmMicro16C () {
  provides {
  	interface Init;
    interface Alarm<TMicro,uint16_t>;
  }
}

implementation {
  components new HalTimerMicro16C() as HardwareTimerMicro16;
  components new HalAlarmP(TMicro, 16, uint16_t) as AlarmMicro16;

  Init = AlarmMicro16.Init;
  Alarm = AlarmMicro16.Alarm;

  AlarmMicro16.HalTimer -> HardwareTimerMicro16.HalTimer;
}
