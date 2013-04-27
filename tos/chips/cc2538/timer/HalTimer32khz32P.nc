
/**
 * Instantiates a couple commands that generic Alarms and whatnot need that
 * the HPL from the sleep timer just doesn't have.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

module HalTimer32khz32P {
  provides {
    interface HalTimer<uint32_t>;
  }
  uses {
    interface HplSleepTimer;
  }
}

implementation {
  async command void HalTimer.enable () {
    call HplSleepTimer.enable();
  }

  async command void HalTimer.disable () {
    call HplSleepTimer.disable();
  }

  async command bool HalTimer.isEnabled () {
    return call HplSleepTimer.isEnabled();
  }

  async command uint32_t HalTimer.get () {
    return call HplSleepTimer.get();
  }

  async command uint32_t HalTimer.getTimerFrequency () {
    return 32768;
  }

  async command void HalTimer.setEvent (uint32_t t0) {
    call HplSleepTimer.setCompare(t0);
  }

  async command void HalTimer.setEventFromNow (uint32_t dt) {
    uint32_t now;

    now = call HplSleepTimer.get();
    call HplSleepTimer.setCompare(now + dt);
  }

  async command uint32_t HalTimer.getEvent () {
    return call HplSleepTimer.getCompare();
  }

  async event void HplSleepTimer.fired () {
    signal HalTimer.fired();
  }
}
