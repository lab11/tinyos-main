#include "OpoADCTest.h"
#include "Msp430Adc12.h"

module OpoADCTestP {
	uses {
		interface Timer<TMilli> as RxTimer;
		interface Timer<TMilli> as RfTimer;
		interface Msp430Adc12SingleChannel as ReadSingleChannel;
		interface Resource as AdcResource;
		interface HplMsp430GeneralIO as UCapGpIO;
		interface HplMsp430GeneralIO as SFDCapGpIO;
		interface HplMsp430GeneralIO as SFDLatch;
		interface HplMsp430GeneralIO as TxRxSel;
		interface HplMsp430GeneralIO as TxGate;
		interface HplMsp430GeneralIO as Adc0;
		interface HplMsp430GeneralIO as TimingLatch;
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
	uint16_t m_buffer[M_SAMPLES];
	uint16_t *COUNT(M_SAMPLES) bp = m_buffer;
	uint8_t i;
	uint16_t t0;
	uint16_t t1;
	uint8_t buffer_index;
	message_t packet;

	task void start_radio() {
		call RfTimer.startOneShot(100);
	}

	msp430adc12_channel_config_t config = {
	    inch:         INPUT_CHANNEL_A0,
	    sref:         REFERENCE_AVcc_AVss,
	    ref2_5v:      REFVOLT_LEVEL_NONE,
	    adc12ssel:    SHT_SOURCE_SMCLK,
	    adc12div:     SHT_CLOCK_DIV_1,
	    sht:          SAMPLE_HOLD_4_CYCLES,
	    sampcon_ssel: SAMPCON_SOURCE_SMCLK,
	    sampcon_id:   SAMPCON_CLOCK_DIV_1
	};

	event void Boot.booted() {
		call TxGate.makeOutput();
	    call TxGate.set();
	    call TxRxSel.makeOutput();
	    call TxRxSel.clr();
	    call Adc0.makeInput();
	    call Adc0.selectModuleFunc();
	    call TimingLatch.makeOutput();
	    call TimingLatch.clr();

	    call UCapGpIO.selectModuleFunc();
	    call UCapGpIO.makeInput();
	    call UCapControl.setControlAsCapture(1);
	    call UCapControl.enableEvents();
	    call UCapControl.clearPendingInterrupt();
	    call UltrasonicCapture.setEdge(MSP430TIMER_CM_NONE);

	    call AdcResource.request();
	}

	async event void UltrasonicCapture.captured(uint16_t time) {
	    call UltrasonicCapture.setEdge(MSP430TIMER_CM_NONE);
	    call UCapControl.clearPendingInterrupt();
	    t0 = time;
	    call TimingLatch.clr();
	    call ReadSingleChannel.getData();
  	}

  	async event error_t ReadSingleChannel.singleDataReady(uint16_t data) {
  		m_buffer[i] = data;
  		i += 1;
  		if(i < 20) {
  			call ReadSingleChannel.getData();
  		}
  		else {
  			t1 = call TimerB.get();
  			call Leds.led0On();
  			post start_radio();
  		}
  		return SUCCESS;
  	}

  	async event uint16_t* COUNT_NOK(numSamples)
  	ReadSingleChannel.multipleDataReady(uint16_t *COUNT(numSamples) buffer,
    uint16_t numSamples) {
    	t1 = call TimerB.get();
    	call Leds.led0Toggle();
    	call TimingLatch.set();
    	post start_radio();
    	return buffer;
  	}

  	event void AdcResource.granted () {
  		//call ReadSingleChannel.configureSingle(&config);
    	call ReadSingleChannel.configureMultiple(&config, bp, M_SAMPLES, 0);
    	call RxTimer.startOneShot(2000);
  	}

  	event void RfControl.startDone(error_t err) {
  		opo_adc_msg_t *p;
        p = (opo_adc_msg_t*) call AMSend.getPayload(&packet,
                                                    sizeof(opo_adc_msg_t));

        for(i = 0; i < 12; i++) {
            p->readings[i] = m_buffer[i];
        }

        p->t0 = t0;
        p->t1 = t1;
        buffer_index += 12;
        call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(opo_adc_msg_t));
    }

    event void RfControl.stopDone(error_t err) {
    	call RxTimer.startOneShot(2000);
    }

    event void AMSend.sendDone(message_t *msg, error_t err) {
       	if(buffer_index < M_SAMPLES) {
    		opo_adc_msg_t *p;
        	p = (opo_adc_msg_t*) call AMSend.getPayload(&packet,
                                                    sizeof(opo_adc_msg_t));
    		for(i = 0; i < 12; i++) {
            	p->readings[i] = m_buffer[buffer_index + i];
        	}
        	buffer_index += 12;
        	call AMSend.send(AM_BROADCAST_ADDR, &packet, sizeof(opo_adc_msg_t));
    	}
    	else {
    		buffer_index = 0;
    		i = 0;
        	call RfControl.stop();
        }
    }

	event void RxTimer.fired() {
		call UltrasonicCapture.setEdge(MSP430TIMER_CM_RISING);
	}

	event void RfTimer.fired() {
		call RfControl.start();
	}

	async event void TimerB.overflow() {}
}