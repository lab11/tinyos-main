/**
 * Implementation of a BatchUploadLogger using a Atmel AT45DB as the temporary
 * backing store.
 *
 * @param vol_id Volume to use for backing store
 *
 * @author Pat Pannuto 
 */

#include "Storage.h"

generic configuration BatchUploadLoggerC(volume_id_t vol_id) {
  provides {
    interface HandoffLogWrite;
  }
}

implementation {
  enum {
    LOG_ID = unique( "at45db.HandoffLog" );
    VOLUME_ID = unique( "at45db.Volume" );
    RESOURCE = unique(UQ_AT45DB);
  };

  components BatchUploadLoggerP, At45dbStorageManagerC, At45dbC;

  HandoffLogWrite = BatchUploadLoggerP.HandoffLogWrite[LOG_ID];

  BatchUploadLoggerP.At45dbVolume[LOG_ID] -> At45dbStorageManagerC.At45dbVolume[vol_id];
  BatchUploadLoggerP.Resource[LOG_ID] -> At45dbC.Resource[RESOURCE_ID];
}
