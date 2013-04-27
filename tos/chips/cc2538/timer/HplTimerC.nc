
/**
 * Presents all of the hardware timers as parametrized interfaces.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

configuration HplTimerC {
  provides {
    interface HplSleepTimer[uint8_t id];
  }
}

implementation {
  components MainC;
  components HplTimerEventP;
  components new HplSleepTimerP() as HplSleepTimer0;

  MainC.SoftwareInit -> HplSleepTimer0.Init;
  HplSleepTimer0.HplTimerEvent -> HplTimerEventP.SleepTimerEvent;

  HplSleepTimer[0] = HplSleepTimer0.HplSleepTimer;

  // add in the general purpose timers
  // components HplGpTimerP()

}
