
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
    interface HplTimerEvent as GpTimer0AEvent;
    interface HplTimerEvent as GpTimer1AEvent;
    interface HplTimerEvent as GpTimer2Event;
    interface HplTimerEvent as GpTimer3Event;
  }
}

implementation {

  // Interrupt handler for the sleep timer. Specified in vector table directly.
  void SleepTimerIrqHandler() @C() @spontaneous() @hwevent() {
    signal SleepTimerEvent.fired();
  }

  void GpTimer0AIrqHandler() @C() @spontaneous() @hwevent() {
    signal GpTimer0AEvent.fired();
  }

  void GpTimer1AIrqHandler() @C() @spontaneous() @hwevent() {
    signal GpTimer1AEvent.fired();
  }

  void GpTimer2IrqHandler() @C() @spontaneous() @hwevent() {
    signal GpTimer2Event.fired();
  }

  void GpTimer3IrqHandler() @C() @spontaneous() @hwevent() {
    signal GpTimer3Event.fired();
  }

}
