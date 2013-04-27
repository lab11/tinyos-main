
/**
 * Lowest level control of the sleep timer.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

#include "interrupt.h"
#include "sleepmode.h"
#include "hw_ints.h"
#include "gpio.h"

generic module HplSleepTimerP () {
  provides {
    interface Init;
    interface HplSleepTimer;
  }
  uses {
    interface HplTimerEvent;
  }
}

implementation {

  bool is_enabled = FALSE;
  uint32_t compare_val = 0;

  command error_t Init.init () {
    GPIOIntWakeupEnable(GPIO_IWE_SM_TIMER);
    return SUCCESS;
  }

  async event void HplTimerEvent.fired () {
    signal HplSleepTimer.fired();
  }

  async command void HplSleepTimer.enable () {
    atomic is_enabled = TRUE;
    IntEnable(INT_SMTIM);
  }

  async command void HplSleepTimer.disable () {
    atomic is_enabled = FALSE;
    IntDisable(INT_SMTIM);
  }

  async command bool HplSleepTimer.isEnabled () {
    atomic return is_enabled;
  }

  async command uint32_t HplSleepTimer.get () {
    return SleepModeTimerCountGet();
  }

  async command void HplSleepTimer.setCompare (uint32_t compare) {
    SleepModeTimerCompareSet(compare);
  }

  async command uint32_t HplSleepTimer.getCompare () {
    return compare_val;
  }

}
