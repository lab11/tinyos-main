#include "Timer.h"
#include "Opo.h"

/*
  @author William Huang <wwhuang@umich.edu>
*/

module OpoP {
  provides {
    interface Opo;
  }
  uses {
    /* Timers */
    interface Timer<TMilli> as TxTimer;
    interface Timer<TMilli> as RxTimer;
    interface Msp430Timer as TimerB;
    /* Pin setup */
    interface HplMsp430GeneralIO as SFDLatch;
    interface HplMsp430GeneralIO as UCapGpIO;
    interface HplMsp430GeneralIO as SFDCapGpIO;
    interface HplMsp430GeneralIO as TxRxSel;
    interface HplMsp430GeneralIO as TxGate;
    interface HplMsp430GeneralIO as Amp3_ADC;
    /*RF Stuff */
    interface AMSend;
    interface Receive;
    interface SplitControl as RfControl;
    /* Timer Controls */
    interface Msp430Capture as SFDCapture;
    interface Msp430Capture as UltrasonicCapture;
    interface Msp430TimerControl as SFDCapControl;
    interface Msp430TimerControl as UCapControl;
    interface Leds;
  }
}

implementation {

  enum {RX, TX, IDLE} opo_state = IDLE;
  enum {RX_SETUP, RX_WAKE, RX_RANGE, RX_IDLE} opo_rx_state = RX_IDLE;
  enum {TX_WAKE, TX_WAKE_STOP, TX_RANGE, TX_RANGE_STOP, TX_IDLE} opo_tx_state = TX_IDLE;

  message_t *tx_packet;
  size_t tx_psize;
  message_t *rx_msg;

  // Timing and ranging
  uint32_t sfd_time = 0; // SFD trigger time.
  uint32_t range = 0; // Based on ToF difference between rf and ultrasonic

  /* Helper function prototypes */
  void startTransducer(); // starts PWM to drive Ultrasonic Transducers
  void stopTransducer(); // stops PWM driving Ultrasonic Transducers
  void setupUltrasonicPWM(); // Sets up TimerA for PWM
  void setupRx(); // sets up Opo for receiving
  void disableRx(); // disables ultrasoinc capture, timers, etc

  /*============================= Opo Transmit =================================
   1) Ultrasonic Wake Up Pulse
   2) Simultaneous Ultrasonic and RF Pulse
  ============================================================================*/

  command error_t Opo.transmit(message_t* packet, size_t psize) {
    if (opo_state != IDLE) {
      signal Opo.transmit_failed();
    }
    else {
      disableRx();

      call TxRxSel.set();
      call TxGate.clr();

      opo_state = TX;
      opo_tx_state = TX_WAKE;
      setupUltrasonicPWM();

      tx_packet = packet;
      tx_psize = psize;

      call TxTimer.startOneShot(1);
    }
  }

  event void TxTimer.fired() {
    if(opo_tx_state == TX_WAKE) {
      call SFDLatch.set();
      startTransducer();
      opo_tx_state = TX_WAKE_STOP;
      call TxTimer.startOneShot(3);
    }
    else if(opo_tx_state == TX_WAKE_STOP) {
      call SFDLatch.clr();
      stopTransducer();
      opo_tx_state = TX_RANGE;
      call TxTimer.startOneShot(45);
    }
    else if(opo_tx_state == TX_RANGE) {
      opo_tx_state = TX_RANGE_STOP;
      startTransducer();
      call RfControl.start();
    }
    else if(opo_tx_state == TX_RANGE_STOP) {
      call SFDLatch.clr();
      stopTransducer();
      opo_state = IDLE;
      opo_tx_state = TX_IDLE;
      signal Opo.transmit_done();
    }
  }

  event void AMSend.sendDone(message_t* bufPtr, error_t error) {
    call TxTimer.startOneShot(3);
    call RfControl.stop();
  }

  async event void TimerB.overflow() {}

  /*============================= Opo Receive ==================================
   Handles Receieve protocol and resetting upon false positive
  ============================================================================*/

  command error_t Opo.enable_receive() {
    if(opo_state != IDLE) {
      signal Opo.enable_receive_failed();
    }
    else {
      setupRx();
    }
  }

  command error_t Opo.disable_receive() {
    disableRx();
  }

  async event void UltrasonicCapture.captured(uint16_t time) {
    opo_state = RX;
    call UltrasonicCapture.setEdge(MSP430TIMER_CM_NONE);
    call UCapControl.clearPendingInterrupt();

    if(opo_rx_state == RX_WAKE) {
      call RxTimer.startOneShot(25);
    }
    else {
        if (time > sfd_time && sfd_time != 0) {
          range = (time - sfd_time) * 10634; // range in microm
        }
    }

    if (call UltrasonicCapture.isOverflowPending()) {
      call UltrasonicCapture.clearOverflow();
    }
  }

  async event void SFDCapture.captured(uint16_t time) {
    if(opo_rx_state == RX_RANGE && sfd_time == 0) {
      sfd_time = time;
      call UltrasonicCapture.setEdge(MSP430TIMER_CM_RISING);
    }
    else if(opo_state == TX) {
      call SFDLatch.set();
    }

    if (call SFDCapture.isOverflowPending()) {
      call SFDCapture.clearOverflow();
    }
  }

  event message_t* Receive.receive(message_t *msg, void *payload, uint8_t len) {
    if(opo_state == RX) {
      rx_msg = msg;
      call RfControl.stop();
    }

    return msg;
  }

  event void RxTimer.fired() {
    if(opo_rx_state == RX_SETUP) {
      opo_rx_state = RX_WAKE;
      call UltrasonicCapture.setEdge(MSP430TIMER_CM_RISING);
    }
    else if(opo_rx_state == RX_WAKE) {
      call RfControl.start();
    }
    else if(opo_rx_state == RX_RANGE) {
      call RfControl.stop();
    }
  }

  /*================================= RF =======================================
    Rf control stufff
  ============================================================================*/

  event void RfControl.startDone(error_t err) {
    call SFDCapture.setEdge(MSP430TIMER_CM_RISING);
    if(opo_state == TX) {
      call AMSend.send(AM_BROADCAST_ADDR,
                       tx_packet,
                       tx_psize);
    }
    else if(opo_state == RX) {
      opo_rx_state = RX_RANGE;
      call RxTimer.startOneShot(50);
    }
  }

  event void RfControl.stopDone(error_t err) {
    if(opo_state == RX) {
      disableRx();
      if(range > 0 && rx_msg != NULL) {
        signal Opo.receive(range, rx_msg);
      }
      else {
        signal Opo.receive_failed();
      }
    }
  }
  /*============================= Setup ========================================
    Stuff to setup pins and MCU modules.
  ============================================================================*/
  command error_t Opo.setup_pins() {
    call TxGate.makeOutput();
    call TxGate.set();
    call TxRxSel.makeOutput();

    // Sets up SFD Time Capture, although not enabled on any edge
    call SFDCapGpIO.selectModuleFunc();
    call SFDCapGpIO.makeInput();
    call SFDCapControl.setControlAsCapture(1);
    call SFDCapControl.enableEvents();
    call SFDCapControl.clearPendingInterrupt();
    call SFDCapture.setEdge(MSP430TIMER_CM_NONE);

    // set up SFD Latch
    call SFDLatch.makeOutput();

    // Sets up Ultrasonic Time Capture, although not enabled on any edge
    call UCapGpIO.selectModuleFunc();
    call UCapGpIO.makeInput();
    call UCapControl.setControlAsCapture(1);
    call UCapControl.enableEvents();
    call UCapControl.clearPendingInterrupt();
    call UltrasonicCapture.setEdge(MSP430TIMER_CM_NONE);

    return SUCCESS;
  }

  /*============================= Helper =======================================
    Helper functions, primarily for ultrasonic stuff.
  ============================================================================*/

  /*
   * TACCR0 = Compare Register, what the timer counts to before rolling over
   * TACCR1 = Compare register, triggers output changes.
   * Zero these out to disable the ultrasonic PWM
  */
  inline void startTransducer() {
    atomic {
      TACCR0 = 0x000C;
      TACCR1 = 0x0005;
    }
  }

  inline void stopTransducer() {
    atomic {
      TACCR0 = 0x0000;
      TACCR1 = 0x0000;
    }
  }

  /*
   * Sets up Timer A for PWM.
   * Specifically, this sets up TACCTL1, or Timer A Compare Output 1.
  */
  inline void setupUltrasonicPWM() {

    // Sets Port16 to be a Timer A module and an output.
    P1SEL = P1SEL | BIT6;
    P1DIR = P1DIR | BIT6;

    // Timer A PWM signal controlled by TACCR0 and TACCR1
    // See Start and Stop Transducer for more.
    // TACTl = Timer A Control Register
    // TASSEL_2 = Timer A Clock Source select 2 - SMCLK
    // ID_1 = Timer A Input (Clock) Divider - 2
    // MC_1 = Mode Control - Up Mode
    // TAIE = Interrupt Enabled
    TACTL = 0x0000;
    TACTL = TASSEL_2 | ID_1 | MC_1;

    // Timer A Compare register settings
    // CM0 = Capture Mode 0 - Compare instead of Capture
    // CCIS_0 = Capture/compare input select done from CCI1A
    // OUTMOD_3 = Outmode 3, PWM Set on TACCR1, Reset on TACCR0
    // CCIE = Interrupt Enabled
    TACCTL1 = 0x0000;
    TACCTL1 = CM0 | CCIS_0 | OUTMOD_3 | CCIE;
  }

  inline void setupTACTL() {
    TACTL = 0x0000;
    TACTL = TASSEL_2 | ID_1 | MC_1;
  }

  /*
   * Enables Ultrasnoic Pulse capture
   * Sets SPDT to Receive and turns off Tx power gate
   * Sets up default values
   * this and setupTransmit are oppositues, so you
   * cannot receive and transmit at the same time
  */
  inline void setupRx() {
      call TxRxSel.clr();
      call TxGate.set();
      call SFDCapture.setEdge(MSP430TIMER_CM_NONE);

      sfd_time = 0;
      rx_msg = NULL;
      range = 0;
      opo_rx_state = RX_SETUP;

      call RxTimer.startOneShot(30);
  }

  inline void disableRx() {
    call RxTimer.stop();
    call UltrasonicCapture.setEdge(MSP430TIMER_CM_NONE);
    call SFDCapture.setEdge(MSP430TIMER_CM_NONE);
    opo_rx_state = RX_IDLE;
    opo_state = IDLE;
  }

}
