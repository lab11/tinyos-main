#include "OpoADCTest.h"
#include "Msp430Adc12.h"

module OpoADCTestP {
	uses {
		interface Timer<TMilli> as RxTimer;
		interface Msp430Adc12SingleChannel as ReadSingleChannel;
		interface HplMsp430GeneralIO as UCapGpIO;
		interface HplMsp430GeneralIO as SFDCapGpIO;
		interface HplMsp430GeneralIO as SFDLatch;
		interface HplMsp430GeneralIO as TxRxSel;
		interface HplMsp430GeneralIO as TxGate;
		interface HplMsp430GeneralIO as Adc0;
		interface SplitControl as RfControl;
		interface AMSend;
		interface Msp430TimerControl as UCapControl;
		interface Msp430Capture as UltrasonicCapture;
		interface Msp430Timer as TimerB;
		interface Boot;
		interface Leds;
	}
}
implementation {
	uint16_t m_buffer[20];
	uint16_t jiffies = 100;
	uint16_t *COUNT(20) bp = m_buffer;
	uint8_t i;
	uint16_t t1;
	uint16_t t2;
	message_t packet;

	msp430adc12_channel_config_t config = {
	    inch:         INPUT_CHANNEL_A0,
	    sref:         REFERENCE_AVcc_AVss,
	    ref2_5v:      REFVOLT_LEVEL_NONE,
	    adc12ssel:    SHT_SOURCE_ACLK,
	    adc12div:     SHT_CLOCK_DIV_1,
	    sht:          SAMPLE_HOLD_16_CYCLES,
	    sampcon_ssel: SAMPCON_SOURCE_ACLK,
	    sampcon_id:   SAMPCON_CLOCK_DIV_1
	};

	event void Boot.booted() {
		/*
		call TxGate.makeOutput();
	    call TxGate.set();
	    call TxRxSel.makeOutput();
	    call TxRxSel.clr();
	    call Adc0.makeInput();
	    call Adc0.selectModuleFunc();

	    call UCapGpIO.selectModuleFunc();
	    call UCapGpIO.makeInput();
	    call UCapControl.setControlAsCapture(1);
	    call UCapControl.enableEvents();
	    call UCapControl.clearPendingInterrupt();
	    call UltrasonicCapture.setEdge(MSP430TIMER_CM_NONE);
	    */

	    call ReadSingleChannel.configureSingle(&config);
	    call ReadSingleChannel.getData();
	    call Leds.led0On();
	    //call RxTimer.startOneShot(100);
	}

	async event void UltrasonicCapture.captured(uint16_t time) {
		error_t m_err;
	    call UltrasonicCapture.setEdge(MSP430TIMER_CM_NONE);
	    call UCapControl.clearPendingInterrupt();
	    call Leds.led0Toggle();
	    t1 = time;
	    m_err = call ReadSingleChannel.getData();
  	}

  	async event error_t ReadSingleChannel.singleDataReady(uint16_t data) {
  		//m_buffer[i] = data;
  		call Leds.led1On();
  		/*i += 1;
  		if(i < 20) {
  			call ReadSingleChannel.getData();
  		}
  		else {
  			t2 = call TimerB.get();
  			call RfControl.start();
  		} */
  		return SUCCESS;
  	}

  	async event uint16_t* COUNT_NOK(numSamples)
  	ReadSingleChannel.multipleDataReady(uint16_t *COUNT(numSamples) buffer,
    uint16_t numSamples) {
    	return NULL;
  	}

  	event void RfControl.startDone(error_t err) {
  		opo_adc_msg_t *p;
        p = (opo_adc_msg_t*) call AMSend.getPayload(&packet,
                                                    sizeof(opo_adc_msg_t));

        for(i = 0; i < 20; i++) {
            p->readings[i] = m_buffer[i];
        }

        p->t1 = t1;
        p->t2 = t2;
        i = 0;
        call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(opo_adc_msg_t));
    }

    event void RfControl.stopDone(error_t err) {
        call RxTimer.startOneShot(100);
    }

    event void AMSend.sendDone(message_t *msg, error_t err) {
        call RfControl.stop();
    }

	event void RxTimer.fired() {
		call UltrasonicCapture.setEdge(MSP430TIMER_CM_RISING);
	}

	async event void TimerB.overflow() {}
}