#include "RV4162.h"

module HplRV4162P {
  provides {
    interface HplRV4162;
  }
  uses {
    interface I2CPacket<TI2CBasicAddr>;
    interface Resource as I2CResource;
  }
}

implementation {
  uint8_t i2c_write_buffer[17];
  uint8_t *i2c_write_buffer_ptr = i2c_write_buffer;
  uint8_t fullTime[9];
  uint8_t *ftPtr = fullTime;
  uint8_t rSec[2];
  uint8_t rMin[2];
  uint8_t rHr[2];
  uint8_t wMin;
  bool startRead = FALSE;
  uint8_t readStartAddr;

  i2c_state_t i2c_state;

  void calculate_time();

  task void I2C_RV4162_TASK() {

      if (!call I2CResource.isOwner()) {
        call I2CResource.request();
        return;
      }

      if(startRead == TRUE) {
        startRead = FALSE;
        call I2CPacket.write( (I2C_START | I2C_STOP),
                              RV4162_ADDR,
                              1,
                              &readStartAddr);
      }
      else {
        switch (i2c_state) {
          case RV_READ_FULL_TIME:
            i2c_state = RV_FULL_TIME_READ;
            call I2CPacket.read( (I2C_START | I2C_STOP),
                                  RV4162_ADDR,
                                  8,
                                  ftPtr);
            break;

          case RV_FULL_TIME_READ:
            i2c_state = RV_IDLE;
            call I2CResource.release();
            signal HplRV4162.readFullTimeDone(SUCCESS, ftPtr);
            break;

          case RV_WRITE_ST_BIT:
            i2c_state = RV_WRITE_ST_BIT_2;
            i2c_write_buffer[0] = 0x01;
            i2c_write_buffer[1] = 0x80;
            call I2CPacket.write( (I2C_START | I2C_STOP),
                                  RV4162_ADDR,
                                  2,
                                  i2c_write_buffer_ptr);
            break;

          case RV_WRITE_ST_BIT_2:
            i2c_state = RV_ST_BIT_WRITTEN;
            i2c_write_buffer[0] = 0x01;
            i2c_write_buffer[1] = 0x00;
            call I2CPacket.write( (I2C_START | I2C_STOP),
                                  RV4162_ADDR,
                                  2,
                                  i2c_write_buffer_ptr);
            break;

          case RV_ST_BIT_WRITTEN:
            i2c_state = RV_IDLE;
            call I2CResource.release();
            signal HplRV4162.writeSTBitDone(SUCCESS);

            break;

          case RV_SET_TIME:
            i2c_state = RV_TIME_SET;
            call I2CPacket.write( (I2C_START | I2C_STOP),
                                  RV4162_ADDR,
                                  9,
                                  i2c_write_buffer);
            break;

          case RV_TIME_SET:
            i2c_state = RV_IDLE;
            call I2CResource.release();
            signal HplRV4162.setTimeDone(SUCCESS);
            break;

          case RV_RESET_TIME:
            i2c_state = RV_TIME_RESET;
            i2c_write_buffer[0] = 0x00;
            i2c_write_buffer[1] = 0x00;
            i2c_write_buffer[2] = 0x00;
            i2c_write_buffer[3] = 0x00;
            i2c_write_buffer[4] = 0x00;
            i2c_write_buffer[5] = 0x01;
            i2c_write_buffer[6] = 0x01;
            i2c_write_buffer[7] = 0x81;
            i2c_write_buffer[8] = 0x00;
            call I2CPacket.write( (I2C_START | I2C_STOP),
                                   RV4162_ADDR,
                                   9,
                                   i2c_write_buffer);
            break;

          case RV_TIME_RESET:
            i2c_state = RV_IDLE;
            call I2CResource.release();
            signal HplRV4162.resetTimeDone(SUCCESS);
            break;
        }
      }
  }

  event void I2CResource.granted() {
    post I2C_RV4162_TASK();
  }

  async event void I2CPacket.readDone(error_t error,
                                      uint16_t addr,
                                      uint8_t length,
                                      uint8_t* data) {
    post I2C_RV4162_TASK();
  }

  async event void I2CPacket.writeDone(error_t error,
                                       uint16_t addr,
                                       uint8_t length,
                                       uint8_t* data) {
    post I2C_RV4162_TASK();
  }

  command error_t HplRV4162.readFullTime() {
    i2c_state = RV_READ_FULL_TIME;
    startRead = TRUE;
    readStartAddr = 0x00;
    post I2C_RV4162_TASK();
    return SUCCESS;
  }

  command error_t HplRV4162.writeSTBit() {
    i2c_state = RV_WRITE_ST_BIT;
    post I2C_RV4162_TASK();
    return SUCCESS;
  }

  command error_t HplRV4162.setTime(uint8_t t[8]) {
    uint8_t i;
    i2c_state = RV_SET_TIME;
    i2c_write_buffer[0] = 0x00;
    for(i=0; i < 7; i++) {
      i2c_write_buffer[i+1] = t[i];
    }
    post I2C_RV4162_TASK();
  }

  command error_t HplRV4162.resetTime() {
    i2c_state = RV_RESET_TIME;
    post I2C_RV4162_TASK();
    return SUCCESS;
  }

  void calculate_time() {
    uint8_t ten_secs;
    uint8_t secs;
    uint8_t mins;
    uint8_t ten_mins;
    uint8_t hours;
    uint8_t ten_hours;
    uint8_t day;
    uint8_t date;
    uint8_t month;
    uint8_t year;
    ten_secs = i2c_write_buffer[1] % 10;
    secs = i2c_write_buffer[1] - (ten_secs * 10);
    ten_mins = i2c_write_buffer[2] % 10;
    mins = i2c_write_buffer[2] - (ten_mins * 10);
    ten_hours = i2c_write_buffer[1] % 10;
    hours = i2c_write_buffer[2] - (ten_hours * 10);
  }

}