#include "OpoBase.h"
#include "printf.h"

module OpoBaseP {
  uses {
    interface Receive as OpoReceive;
    interface Receive as BlinkReceive;
    interface Receive as VisualReceive;
    interface SplitControl as RfControl;
    interface AMPacket;
    interface Boot;
    interface Leds;
  }
}

implementation {

  event void Boot.booted() {
    call RfControl.start();
    printf("Booted\n");
    printfflush();
  }

  event message_t* OpoReceive.receive(message_t *msg, void *payload, uint8_t len) {
    opo_bmsg_t *data = (opo_bmsg_t *) payload;
    int i;
    uint32_t total_time = 0;
    printf("RANGE:%u\n", data->rec.range);
    printf("SEQ:%u\n", data->rec.sequence);
    printf("RX_ID:0x");
    for(i = 0; i < 6; i++) {
      printf("%x", data->m_id[i]);
    }
    printf("\n");
    printf("TX_ID:0x");
    for(i = 0; i < 6; i++) {
      printf("%x", data->rec.o_id[i]);
    }
    printf("\n");
    printf("RSSI:%i\n", data->rec.rssi);
    printf("TX_PWR:%u\n", data->rec.tx_pwr);
    total_time += data->rec.seconds;
    total_time += data->rec.minutes * 60;
    total_time += data->rec.hours * 60 * 60;
    printf("TIME:%u\n", total_time);
    printfflush();
    return msg;
  }

  event message_t* BlinkReceive.receive(message_t *msg, void *payload, uint8_t len) {
    oblink_base_msg_t *data = (oblink_base_msg_t *) payload;
    int i;

    printf("Range: %u\n", data->range);
    printf("M_ID: 0x");
    for(i=0; i < 6; i++) {
      printf("%x", data->m_id[i]);
    }
    printf("\n");
    printf("O_ID: 0x");
    for(i=0; i < 6; i++) {
      printf("%x", data->o_id[i]);
    }
    printf("\n");

    printfflush();
    return msg;
  }

  event message_t* VisualReceive.receive(message_t *msg, void *payload, uint8_t len) {
    ovis_base_msg_t *data = (ovis_base_msg_t *) payload;
    int i;
    uint32_t total_time;

    printf("GID: 2\n");
    printf("RANGE: %lu\n", data->range);
    printf("RX_ID: 0x");
    for(i=0; i < 6; i++) {
      printf("%x", data->rx_id[i]);
    }
    printf("\n");
    printf("TX_ID: 0x");
    for(i=0; i < 6; i++) {
      printf("%x", data->tx_id[i]);
    }
    printf("\n");

    total_time = data->sec;
    total_time += data->min * 60;
    total_time += data->h * 3600;

    printf("TIME: %lu\n", total_time);

    printfflush();
    return msg;
  }

  event void RfControl.startDone(error_t err) {
    printf("RfStartDone\n");
    printfflush();
  }
  event void RfControl.stopDone(error_t err) {}

}