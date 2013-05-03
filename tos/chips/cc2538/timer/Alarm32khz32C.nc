
/**
 * Converts a hardware timer to the generic Alarm interface.
 *
 * @author Brad Campbell <bradjc@umich.edu>
 */

generic configuration Alarm32khz32C() {
  provides {
  	interface Init;
    interface Alarm<T32khz,uint32_t>;
  }
}

implementation {
  components new HalTimer32khz32C() as HardwareTimer32khz32;
  components new HalAlarmP(T32khz, 1, uint32_t) as Alarm32khz32;

  Init = Alarm32khz32;
  Alarm = Alarm32khz32;

  Alarm32khz32.HalTimer -> HardwareTimer32khz32.HalTimer;
}
