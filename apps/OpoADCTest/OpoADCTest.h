#ifndef OPO_ADC_H
#define OPO_ADC_H

#define CC2420_DEF_CHANNEL 16

typedef nx_struct opo_adc_msg {
    nx_uint16_t readings[20];
    nx_uint16_t t1;
    nx_uint16_t t2;
} opo_adc_msg_t;

enum {
    OPO_ADC_BASE = 24
};

#endif