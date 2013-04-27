
/**
 * Collection of all of the timer interrupt handlers and the events they
 * trigger.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

#include "interrupt.h"
#include "hw_ints.h"

module HplTimerEventP {
  provides {
    interface HplTimerEvent as SleepTimerEvent;
  }
}

implementation {

  // Interrupt handler for the sleep timer. Specified in vector table directly.
  void SleepTimerIrqHandler() @C() @spontaneous() {
    signal SleepTimerEvent.fired();
  }

}
