
/**
 * Converts the 32 bit micro second gptimer to the standard HalTimer interface.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

generic configuration HalTimerMicro32C () {
  provides {
    interface HalTimer<uint32_t>;
  }
}

implementation {
  components new HalTimerMicroP(uint32_t);
  components HplTimerC;

  // Wire to the hardware timer.
  enum { ALARM_ID = unique("TimerMicroC") };
  HalTimerMicroP.HplGpTimer -> HplTimerC.HplGpTimer32[ALARM_ID];

  HalTimer = HalTimerMicroP.HalTimer;
}
