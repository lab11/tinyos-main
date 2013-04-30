
/**
 * Converts the 16 bit micro second gptimer to the standard HalTimer interface.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

generic configuration HalTimerMicro16C () {
  provides {
    interface HalTimer<uint16_t>;
  }
}

implementation {
  components new HalTimerMicroP(uint16_t);
  components HplTimerC;

  // Wire to the hardware timer.
  enum { ALARM_ID = unique("TimerMicro16C") };
  HalTimerMicroP.HplGpTimer -> HplTimerC.HplGpTimer16[ALARM_ID];

  HalTimer = HalTimerMicroP.HalTimer;
}
