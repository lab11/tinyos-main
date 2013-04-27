
/**
 * Converts the 32 bit 32 kHz hardware sleep timer to the HAL interface.
 * Adds a few functions that the sleep timer doesn't really have to make it
 * look more like the general purpose timers.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

generic configuration HalTimer32khz32C () {
  provides {
    interface HalTimer<uint32_t>;
  }
}

implementation {
  components HalTimer32khz32P;
  components HplTimerC;

  // Wire to the hardware timer.
  enum { ALARM_ID = unique("Timer32khzC") };
  HalTimer32khz32P.HplSleepTimer -> HplTimerC.HplSleepTimer[ALARM_ID];

  HalTimer = HalTimer32khz32P.HalTimer;
}
