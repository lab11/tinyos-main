
/**
 * Controls the registers for the general purpose timers.
 *
 * base:      address of the timer
 * timer:     offset for timer a, b, or both
 * periph:    #define for the timer peripheral used
 * interrupt: #define for the relevant interrupt
 * size_type: uint16_t or uint32_t
 * width:     number of bits of the timer
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

#include "hw_ints.h"
#include "hw_memmap.h"
#include "gpio.h"
#include "interrupt.h"
#include "ioc.h"
#include "hw_ioc.h"
#include "sys_ctrl.h"
#include "gptimer.h"

generic module HplGpTimerP (uint32_t base,
                            uint32_t timer,
                            uint32_t periph,
                            uint32_t interrupt,
                            typedef size_type @integer(),
                            uint8_t width) {
  provides {
    interface HplGpTimer<size_type>;
  }
  uses {
    interface HplTimerEvent;
interface Leds;
  }
}

implementation {

  bool is_enabled = FALSE;

  void enable_peripheral () {
    SysCtrlPeripheralEnable(periph);
    if (width == 16) {
      TimerConfigure(base, GPTIMER_CFG_SPLIT_PAIR | GPTIMER_CFG_A_ONE_SHOT_UP);
    } else {
      TimerConfigure(base, GPTIMER_CFG_ONE_SHOT_UP);
    }
  }

  async event void HplTimerEvent.fired () {
    TimerIntClear(base, GPTIMER_TIMA_TIMEOUT);
     TimerDisable(base, timer);
    signal HplGpTimer.fired();
  }

  async command void HplGpTimer.enable () {
    atomic is_enabled = TRUE;
    enable_peripheral();
    TimerIntEnable(base, GPTIMER_TIMA_TIMEOUT);
    IntEnable(interrupt);
    TimerEnable(base, timer);
    call Leds.led2On();
  }

  async command void HplGpTimer.disable () {
    atomic is_enabled = FALSE;
    SysCtrlPeripheralDisable(periph);
  }

  async command bool HplGpTimer.isEnabled () {
    atomic return is_enabled;
  }

  async command size_type HplGpTimer.get () {
    return (size_type) TimerValueGet(base, timer);
  }

  async command void HplGpTimer.setCompare (size_type compare) {
    enable_peripheral();
    TimerLoadSet(base, timer, compare);
  }

  async command size_type HplGpTimer.getCompare () {
    return (size_type) TimerLoadGet(base, timer);
  }

  default async event void HplGpTimer.fired () { }

}
