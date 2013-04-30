
/**
 * Instantiates a couple commands that generic Alarms and whatnot need that
 * the HPL from the sleep timer just doesn't have.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

generic module HalTimerMicroP (typedef size_type @integer()) {
  provides {
    interface HalTimer<size_type>;
  }
  uses {
    interface HplGpTimer<size_type>;
  }
}

implementation {
  async command void HalTimer.enable () {
    call HplGpTimer.enable();
  }

  async command void HalTimer.disable () {
    call HplGpTimer.disable();
  }

  async command bool HalTimer.isEnabled () {
    return call HplGpTimer.isEnabled();
  }

  async command size_type HalTimer.get () {
    return call HplGpTimer.get();
  }

  async command uint32_t HalTimer.getTimerFrequency () {
    return 32000000;
  }

  async command void HalTimer.setEvent (size_type t0) {
    call HplGpTimer.setCompare(t0);
  }

  async command void HalTimer.setEventFromNow (size_type dt) {
    size_type now;

    now = call HplGpTimer.get();
    call HplGpTimer.setCompare(now + dt);
  }

  async command size_type HalTimer.getEvent () {
    return call HplGpTimer.getCompare();
  }

  async event void HplGpTimer.fired () {
    signal HalTimer.fired();
  }
}
