
/**
 * Presents all of the hardware timers as parametrized interfaces.
 *
 * There is only 1 32khz timer (the sleep timer).
 * There are 4 general purpose timer blocks. These are configured such that
 * there are 2 16 bit timers and 2 32 bit timers.
 *
 * Connects the event component to the hpl for that specific interrupt.
 *
 * @author: Brad Campbell <bradjc@umich.edu>
 */

#include "gptimer.h"
#include "hw_ints.h"

configuration HplTimerC {
  provides {
    interface HplSleepTimer[uint8_t id];
    interface HplGpTimer<uint16_t> as HplGpTimer16[uint8_t id];
    interface HplGpTimer<uint32_t> as HplGpTimer32[uint8_t id];
  }
}

implementation {
  components MainC;
  components HplTimerEventP as EventP;
  components new HplSleepTimerP() as HplSleepTimer0;

  MainC.SoftwareInit -> HplSleepTimer0.Init;
  HplSleepTimer0.HplTimerEvent -> EventP.SleepTimerEvent;

  HplSleepTimer[0] = HplSleepTimer0.HplSleepTimer;

  // Add in the general purpose timers
  components new HplGpTimerP(GPTIMER0_BASE, GPTIMER_A, SYS_CTRL_PERIPH_GPT0,
                             INT_TIMER0A, uint16_t, 16) as Hpl16Gp0;
  components new HplGpTimerP(GPTIMER1_BASE, GPTIMER_A, SYS_CTRL_PERIPH_GPT1,
                             INT_TIMER1A, uint16_t, 16) as Hpl16Gp1;

  components new HplGpTimerP(GPTIMER2_BASE, GPTIMER_BOTH, SYS_CTRL_PERIPH_GPT2,
                             INT_TIMER2A,  uint32_t, 32) as Hpl32Gp0;
  components new HplGpTimerP(GPTIMER3_BASE, GPTIMER_BOTH, SYS_CTRL_PERIPH_GPT3,
                             INT_TIMER3A,  uint32_t, 32) as Hpl32Gp1;

  Hpl16Gp0.HplTimerEvent -> EventP.GpTimer0AEvent;
  Hpl16Gp1.HplTimerEvent -> EventP.GpTimer1AEvent;

  Hpl32Gp0.HplTimerEvent -> EventP.GpTimer2Event;
  Hpl32Gp1.HplTimerEvent -> EventP.GpTimer3Event;

  HplGpTimer16[0] = Hpl16Gp0.HplGpTimer;
  HplGpTimer16[1] = Hpl16Gp1.HplGpTimer;

  HplGpTimer32[0] = Hpl32Gp0.HplGpTimer;
  HplGpTimer32[1] = Hpl32Gp1.HplGpTimer;
}
