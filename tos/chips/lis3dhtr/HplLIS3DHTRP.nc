#include "HplLIS3DHTR.h"
module HplLIS3DHTRP {
    provides {
        interface HplLIS3DHTR;
    }
    uses {
        interface I2CPacket<TI2CBasicAddr>;
        interface Resource as I2CResource;
    }
}

implementation {
    uint8_t i2c_write_buffer[17];

    enum {
        LIS3DHTR_POWER_DOWN,
        LIS3DHTR_POWER_DOWN_DONE,
        LIS3DHTR_SET_DEFAULT,
        LIS3DHTR_SET_DEFAULT_DONE
    } lis3dhtr_state;

    event void I2CResource.granted() {
        switch(lis3dhtr_state) {
            case LIS3DHTR_POWER_DOWN:
                lis3dhtr_state = LIS3DHTR_POWER_DOWN_DONE;
                i2c_write_buffer[0] = CTRL_REG1;
                i2c_write_buffer[1] = 0x08;
                call I2CPacket.write( (I2C_START | I2C_STOP),
                      LIS3DHTR_ADDR,
                      2,
                      &i2c_write_buffer);
                break;

            case LIS3DHTR_SET_DEFAULT:
                lis3dhtr_state = LIS3DHTR_SET_DEFAULT_DONE;
                i2c_write_buffer[0] = CTRL_REG1;
                i2c_write_buffer[1] = 0x07;
                call I2CPacket.write( (I2C_START | I2C_STOP),
                      LIS3DHTR_ADDR,
                      2,
                      &i2c_write_buffer);
                break;
        }

    }

    async event void I2CPacket.readDone(error_t error,
                                        uint16_t addr,
                                        uint8_t length,
                                        uint8_t* data) {

    }

    async event void I2CPacket.writeDone(error_t error,
                                         uint16_t addr,
                                         uint8_t length,
                                         uint8_t* data) {
        switch(lis3dhtr_state) {
            case LIS3DHTR_POWER_DOWN_DONE:
                signal HplLIS3DHTR.power_down_done();
                break;

            case LIS3DHTR_SET_DEFAULT_DONE:
                signal HplLIS3DHTR.set_default_mode_done();
                break;
        }
    }

    command error_t HplLIS3DHTR.power_down() {
        lis3dhtr_state = LIS3DHTR_POWER_DOWN;
        call I2CResource.request();
    }

    command error_t HplLIS3DHTR.set_default_mode() {
        lis3dhtr_state = LIS3DHTR_SET_DEFAULT;
        call I2CResource.request();
    }
}