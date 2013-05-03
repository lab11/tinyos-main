
/**
 * Converts a hardware timer into a given type of Alarm.
 *
 * author: Brad Campbell <bradjc@umich.edu>
 */

generic module HalAlarmP (typedef frequency_tag,
                          uint32_t freq_multiplier,
                          typedef size_type @integer()) @safe() {
  provides {
    interface Init;
    interface Alarm<frequency_tag,size_type> as Alarm;
  }
  uses {
    interface HalTimer<size_type>;
  }
}

implementation {
  command error_t Init.init () {
    return SUCCESS;
  }

  async command void Alarm.start (size_type dt) {
    call Alarm.startAt(call Alarm.getNow(), dt);
  }

  async command void Alarm.stop () {
    call HalTimer.disable();
  }

  async event void HalTimer.fired () {
    call HalTimer.disable();
    signal Alarm.fired();
  }

  async command bool Alarm.isRunning () {
    return call HalTimer.isEnabled();
  }

  async command void Alarm.startAt (size_type t0, size_type dt) {

    // This line will not always work (say if the clock is very slow.)
    // - but for a 32MHz clock, there are 32 ticks per microsecond, so
    //   we multiply each microsecond by 32.
    // - for a 32kHz clock, there is one tick per 32kHz increment. So
    //   we multiply by 1.
    dt = dt * freq_multiplier;

    atomic {
      size_type now = call HalTimer.get();
      size_type elapsed = now - t0;
      if (elapsed >= dt) {
        call HalTimer.setEventFromNow(5);
      } else {
        size_type remaining = dt - elapsed;
        if (remaining <= 5) {
          call HalTimer.setEventFromNow(5);
        } else {
          call HalTimer.setEvent(now+remaining);
        }
      }
      call HalTimer.enable();
    }
  }

  async command size_type Alarm.getNow () {
    return call HalTimer.get();
  }

  async command size_type Alarm.getAlarm () {
    return call HalTimer.getEvent();
  }

  async event void HalTimer.overflow () { }
}

