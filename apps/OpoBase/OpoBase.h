#ifndef OPOBASE_H
#define OPOBASE_H

#define CC2420_DEF_CHANNEL 15
#define CC2520_DEF_CHANNEL 15

typedef nx_struct opo_rec_msg {
    nx_uint8_t valid; //validates data read from flash
    nx_uint32_t range; // Range is given in micrometers to avoid decimals
    nx_uint32_t sequence; // Used to match nodes to the same broadcast
    nx_uint16_t id; // ID Taken from Rf Packet Source Address
    nx_int8_t rssi;
    nx_uint8_t tx_pwr;
    nx_uint8_t seconds; 
    nx_uint8_t minutes; 
    nx_uint8_t hours;
} opo_rec_t;

enum {
    OPO_PROBE = 18,
    OPO_ACK = 19,
    OPO_DATA = 20
};

#endif
