
configuration TimerMicroC { }

implementation {
  components TimerMicroP as App;
  components MainC, LedsC;

  App.Boot -> MainC.Boot;
  App.Leds -> LedsC.Leds;

  components new AlarmMicro32C();
  MainC.SoftwareInit -> AlarmMicro32C.Init;

  App.Alarm -> AlarmMicro32C.Alarm;
}
