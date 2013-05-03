
#include "hw_ints.h"
#include "hw_memmap.h"
#include "gpio.h"
#include "interrupt.h"
#include "ioc.h"
#include "hw_ioc.h"
#include "sys_ctrl.h"
#include "gptimer.h"

module TimerMicroP {
  uses {
    interface Boot;
    interface Leds;

    interface Alarm<TMicro,uint32_t>;
  }
}

implementation {

  event void Boot.booted () {
    call Leds.led0On();
    call Leds.led1Off();
    call Alarm.start(10000000);
  }

  async event void Alarm.fired () {
    call Alarm.start(10000000);
    call Leds.led1Toggle();
  }

}
