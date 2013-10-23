
module SimpleRadioP {
	provides {
		interface SimpleRadio;
	}
	uses {
		interface SpiByte;
		interface Alarm<T32khz,uint16_t> as CC2420StartUpAlarm;
		interface HplMsp430GeneralIO as VREG;
		interface HplMsp430GeneralIO as CSN;
		interface HplMsp430GeneralIO as SFD;
		interface HplMsp430GeneralIO as RESET;
		interface HplMsp430GeneralIO as FIFOP;
		interface HplMsp430GeneralIO as FIFO;
		interface HplMsp430GeneralIO as CCA;
	}
}
implementation {

	enum {vreg_on, osc_on} startup_timer_state = vreg_on;

	async command error_t SimpleRadio.turnOn() {
		call VREG.makeOutput();
		call VREG.set();
		call CC2420StartUpAlarm.start(20);
	}

	async command error_t SimpleRadio.turnOff() {

	}

	event void CC2420StartUpAlarm.fired() {
		if (startup_timer_state == vreg_on) {
			call RESET.clr();
			call RESET.set();
			call SpiByte.write(CC2420_SXOSCON);
			startup_timer_state = osc_on;
			call CC2420StartUpAlarm.start(32000);
		}
		else {
			signal SimpleRadio.turnedOn();
		}
	}

}