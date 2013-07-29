#include "Opo.h"

module OpoP() {
  provides {
    interface Opo;
  }

  uses {
    /* DS2411 ID reader */
    interface ReadId48 as IdReader;
    /* Timers */
    interface Timer<TMilli> as TxTimer;
    interface Timer<TMilli> as RxTimer;
    interface Timer<TMilli> as SetupTimer;
    interface Timer<TMilli> as ResetTimeTimer;
    /* Pin setup */
    interface HplMsp430GeneralIO as SFDLatch;
    interface HplMsp430GeneralIO as UCapGpIO;
    interface HplMsp430GeneralIO as SFDCapGpIO;
    interface HplMsp430GeneralIO as TxRxSel;
    interface HplMsp430GeneralIO as TxGate;
    interface HplMsp430GeneralIO as Amp3_ADC;
    /* Ultrasonic Stuff */
    interface SplitControl as UltrasonicTx;
    /*RF Stuff */
    interface AMSend as OpoRfTx;
    interface Receive as OpoRfRx;
    interface SplitControl as RfControl;
    /* Timer Controls */
    interface Msp430Capture as SFDCapture;
    interface Msp430Capture as UltrasonicCapture;
    interface Msp430TimerControl as SFDCapControl;
    interface Msp430TimerControl as UCapControl;
    /* Random Random Stuff */
    interface Random;
    interface ParameterInit<uint32_t> as RandInit;
  }
}

implementation OpoP() {
  enum {TX_WAKE, TX_WAKE_STOP, TX_RANGE, IDLE} opo_tx_state;
  enum {RX_WAKE, RX_RANGE, IDLE} opo_rx_state;
  enum {TX, RX} opo_state;
  int i; // Used in for loops
  message_t* tx_packet;
  message_t* rx_msg;
  uint32_t range;
  size_t tx_psize;

  command error_t transmit(message_t* packet, size_t psize) {
    opo_state = TX;
    opo_tx_state = TX_WAKE;
    tx_packet = packet;
    tx_psize = psize;
    call TxTimer.startOneShot(1);
    return SUCCESS:
  }

  event void TxTimer.fired() {
    if(opo_tx_state == TX_WAKE) {
      call SFDLatch.set();
      call UltrasonicTx.start();

      opo_tx_state == TxWakeStop;
      call TxTimer.startOneShot(5);
    }
    else if(opo_tx_state == TX_WAKE_STOP) {
      call SFDLatch.clr();
      call UltrasonicTx.stop();

      opo_tx_state == TxRange;
      call TxTimer.startOneShot(45);
    }
    else if(opo_tx_state == TX_RANGE) {
      call RfControl.start();
    }
    else if(opo_tx_state == IDLE) {
      printf("ERR: TX STATE IDLE\n");
      printfflush();
    }
  }

  event void OpoRfTx.sendDone(message_t* bufPtr, error_t error) {
    range_sequence++;
    call RfControl.stop();
  }

  event void RfControl.startDone(error_t err) {
    if(opo_state == TX) {
      call SFDCapture.setEdge(MSP430TIMER_CM_RISING);
      call OpoRfTx.send(AM_BROADCAST_ADDR,
                        tx_packet,
                        tx_psize);
    }
    else if (opo_state == RX) {
      call RxGuardTimer.startOneShot(15);
    }
  }

  event void RfControl.stopDone(error_t err) {
    if(opo_state == TX) {
      call SFDLatch.clr();
      call UltrasonicTx.stop();
      opo_tx_state = IDLE;
    }
    else if(opo_state == RX) {
      opo_rx_state = IDLE;
      signal Opo.Receive(range, );
    }
  }

  event void RfControl.stopDone(error_t err) {
    call SFDCapture.setEdge(MSP430TIMER_CM_NONE);
    if (m_state == RX_RANGE || m_state == RX_WAKE) {
      setRandGuard();
      call WakeStartTimer.startOneShot(wakestartmin + randguard);
      call RxResetTimer.startOneShot(25);
    }
  }



  async event void SFDCapture.captured(uint16_t time) {
    call SFDCapture.setEdge(MSP430TIMER_CM_NONE);
    call SFDCapControl
    if(opo_state == RX && sfd_time == 0) {
      sfd_time = time;
      call UltrasonicCapture.setEdge(MSP430TIMER_CM_RISING);
    }
    else if(opo_state == TxStart) {
      call SFDLatch.set();
      opo_state = TxStop;
      call TxTimer.startOneShot(5);
    }

    if (call SFDCapture.isOverflowPending()) {
      call SFDCapture.clearOverflow();
    }
  }

  async event void UltrasonicCapture.captured(uint16_t time) {
    call UltrasonicCapture.setEdge(MSP430TIMER_CM_NONE);
    call UCapControl.clearPendingInterrupt();

    if(opo_rx_state == RX_WAKE) {
      opo_rx_state = RX_RANGE;
      call RfControl.start();
    }
    else if(opo_rx_state == RX_RANGE) {
      if (time > sfd_time && sfd_time != 0) {
        atomic range = (utime - sfd_time) * 10634; // range in um
      }
      if(rfValid == TRUE) {
        signal Opo.receive(range, rx_msg);
      }
    }

    if(call UltrasonicCapture.isOverflowPending()) {
      call UltrasonicCapture.clearOverflow();
    }
  }

  event message_t* OpoRfRx.receive(message_t *msg, void *payload, uint8_t len) {
    call RxTimer.stop();
    call RfControl.stop();
    rx msg = msg;

    if(opo_state == RX) {
      atomic rfValid = TRUE;
      if (range > 0) {
        signal Opo.receive(range, rx_msg);
      }
    }
    return msg;

  }

  event void RxTimer.fired() {
    call RfControl.stop();
  }
}