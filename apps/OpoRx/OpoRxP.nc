#include "printf.h"
#include "OpoRx.h"

module OpoRxP {
    uses {
        interface Boot;
        interface Leds;
        interface Random;
        interface ReadId48 as IdReader;
        interface SplitControl as At45dbPower;
        interface CC2420Config;
        interface Packet;
        interface Opo;
        interface Timer<TMilli> as RxTimer;
    }
}

implementation {
    message_t packet;
    uint8_t   fcount = 0; // receive failed count
    uint8_t   m_id[6];
    uint8_t   i; // used for for loops

    event void Boot.booted() {
        opo_rf_msg_t *p;
        call IdReader.read(&m_id[0]);

        call At45dbPower.stop();
        printf("Booted\n");
        printfflush();
        call Opo.setup_pins();
        call Opo.enable_receive();
    }

    event void Opo.receive(uint32_t range, message_t* msg) {
        printf("R: %lu\n", range);
        printfflush();
        call RxTimer.startOneShot(50);
    }

    event void Opo.receive_failed() {
        fcount += 1;
        printf("FC: %u\n", fcount);
        printfflush();
        call RxTimer.startOneShot(50);
    }

    event void RxTimer.fired() {
        call Opo.enable_receive();
    }

    event void Opo.transmit_done() {}
    event void Opo.transmit_failed() {}
    event void Opo.enable_receive_failed() {
        printf("ER Failed\n");
        printfflush();
    }

    event void CC2420Config.syncDone(error_t error) {}

    event void At45dbPower.startDone(error_t err) {}
    event void At45dbPower.stopDone(error_t err) {}

}