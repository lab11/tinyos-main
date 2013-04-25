
configuration MoteClockC {
  provides {
  	interface Init as MoteClockInit;
  }
}

implementation {
  components MoteClockP;

  MoteClockInit = MoteClockP.MoteClockInit;
}
