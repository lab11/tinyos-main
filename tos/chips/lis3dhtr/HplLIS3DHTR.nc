interface HplLIS3DHTR {
    command error_t power_down(); //low power mode
    event void power_down_done();
    command error_t set_default_mode();
    event void set_default_mode_done();
}