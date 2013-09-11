#include "OpoVisualDemo.h"

#ifdef OPO_DEBUG
#include "printf.h"
#endif

module OpoVisualDemoP {
    uses {
        interface Boot;
        interface Leds;
        interface Random;
        interface ReadId48 as IdReader;
        interface SplitControl as FlashPower;
        interface Packet;
        interface Opo;
        interface Timer<TMilli> as TxTimer;
        interface Timer<TMilli> as RxTimer;
        interface PacketAcknowledgements as PacketAcks;
        interface AMSend as BaseSend;
        interface SplitControl as RfControl;
        interface HplRV4162;
        interface CC2420Config;
    }
}

implementation {
    message_t packet;
    message_t base_packet;
    ovis_base_msg_t *bp;
    uint32_t tx_interval_min = 0;
    uint8_t m_id[6];
    uint32_t guard;
    uint32_t dt;
    uint32_t t0;
    uint32_t tn;
    uint32_t rt;

    enum {ENABLE_RX, BASE_SEND} ovis_rx_state = ENABLE_RX;

    void setGuardTime();
    uint16_t getInteractions(message_t* msg);

    event void Boot.booted() {
        uint8_t i;
        ovis_msg_t *p;

        call Opo.setup_pins();
        call IdReader.read(&m_id[0]);
        call PacketAcks.noAck(&packet);
        call PacketAcks.noAck(&base_packet);
        setGuardTime();

        p = (ovis_msg_t*) call Packet.getPayload(&packet,
                                                   sizeof(ovis_msg_t));
        bp = (ovis_base_msg_t*) call Packet.getPayload(&base_packet,
                                                         sizeof(base_packet));
        for(i = 0; i < 6; i++) {
            p -> tx_id[i] = m_id[i];
            bp -> rx_id[i] = m_id[i];
        }

        call RxTimer.startOneShot(70);
        call TxTimer.startOneShot(2000 + guard);

        #ifdef OPO_DEBUG
        printf("Booted\n");
        printfflush();
        #endif
    }

    event void RxTimer.fired() {
        #ifdef OPO_DEBUG
        printf("RXT\n");
        printfflush();
        #endif

        if(ovis_rx_state == ENABLE_RX) {
            call Opo.enable_receive();
        }
        else if (ovis_rx_state == BASE_SEND) {
            call RfControl.start();
        }
    }

    event void TxTimer.fired() {
        #ifdef OPO_DEBUG
        printf("TXT\n");
        printfflush();
        #endif

        call Opo.transmit(&packet, sizeof(ovis_msg_t));
    }

    event void Opo.transmit_done() {
        #ifdef OPO_DEBUG
        printf("TxD\n");
        printf("G: %lu\n", guard);
        printfflush();
        #endif

        call RxTimer.stop();
        setGuardTime();
        call TxTimer.startOneShot(1500 + (guard*40));
        call RxTimer.startOneShot(200);
    }

    event void Opo.transmit_failed() {
        #ifdef OPO_DEBUG
        printf("TxF\n");
        printfflush();
        #endif

        call TxTimer.startOneShot(500 + (guard*2));
    }

    event void Opo.receive(uint32_t range, message_t* msg) {
        #ifdef OPO_DEBUG
        printf("Range: %lu\n", range);
        printfflush();
        #endif

        call TxTimer.stop();
        tn = call TxTimer.getNow();
        t0 = call TxTimer.gett0();
        dt = call TxTimer.getdt();
        rt = dt - (tn - t0);

        ovis_rx_state = BASE_SEND;
        call RxTimer.startOneShot(5 + guard);
    }

    event void Opo.receive_failed() {
        #ifdef OPO_DEBUG
        printf("RxF\n");
        printfflush();
        #endif

        call RxTimer.startOneShot(100);
    }

    event void Opo.enable_receive_failed() {
        #ifdef OPO_DEBUG
        printf("RxEF\n");
        printfflush();
        #endif

        call RxTimer.startOneShot(100);
    }

    event void BaseSend.sendDone(message_t *msg, error_t err) {
        #ifdef OPO_DEBUG
        printf("BSD\n");
        printfflush();
        #endif

        call CC2420Config.setChannel(OPO_CHANNEL);
        call RfControl.stop();
    }

    event void RfControl.startDone(error_t err) {
        if(ovis_rx_state == BASE_SEND) {
            call CC2420Config.setChannel(BASE_CHANNEL);
            call BaseSend.send(AM_BROADCAST_ADDR,
                               &base_packet,
                               sizeof(ovis_base_msg_t));
        }
    }

    event void RfControl.stopDone(error_t err) {
        if(ovis_rx_state == BASE_SEND) {
            ovis_rx_state = ENABLE_RX;
            call RxTimer.startOneShot(70);
            call TxTimer.startOneShot(rt);
        }
    }

    event void HplRV4162.readFullTimeDone(error_t err, uint8_t *fullTime) {}

    event void HplRV4162.writeSTBitDone(error_t err) {}

    event void HplRV4162.setTimeDone(error_t err) {}

    event void HplRV4162.resetTimeDone(error_t err) {}

    event void FlashPower.startDone(error_t err) {}
    event void FlashPower.stopDone(error_t err) {}

    event void CC2420Config.syncDone(error_t error) {}

    inline void setGuardTime() {
        guard = call Random.rand32();
        guard = (guard % 51);
    }

}