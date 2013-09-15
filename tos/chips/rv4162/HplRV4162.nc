interface HplRV4162 {

    command error_t readFullTime();

    command error_t writeSTBit();

    command error_t setTime(uint8_t t[8]);

    command error_t resetTime();



    event void readFullTimeDone(error_t err, uint8_t* fullTime);

    event void writeSTBitDone(error_t err);

    event void setTimeDone(error_t err);

    event void resetTimeDone(error_t err);

}