module OpoPowerP {
    uses {
        interface Boot;
        interface SplitControl as RfControl;
        interface SplitControl as FlashPower;
        interface Timer<TMilli> as PowerTimer;
        interface HplMsp430GeneralIO as VPIN;
    }

}

implementation {

    enum {IDLE, RFP, FLASHP} pstate;

    event void Boot.booted() {
        call VPIN.makeOutput();
        call VPIN.clr();
        LPM3;
        //LPM3;
        //call FlashPower.stop();
        //call RfControl.stop();
    }

    event void RfControl.startDone(error_t err) {}

    event void RfControl.stopDone(error_t err) {
        pstate = RFP;
        //call PowerTimer.startOneShot(60);
    }

    event void FlashPower.startDone(error_t err) {}

    event void FlashPower.stopDone(error_t err) {
        LPM3;
        //pstate = FLASHP;
        //call PowerTimer.startOneShot(60);
    }

    event void PowerTimer.fired() {
        if(pstate == RFP) {
            call FlashPower.stop();
        }
        else {
            LPM3;
        }
    }

}