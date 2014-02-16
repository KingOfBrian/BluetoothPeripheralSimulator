#import <Foundation/Foundation.h>


struct BluetoothGlucoseMeasurementFlags {
    UInt8 timeOffsetPresent : 1;
    UInt8 glucoseConcentrationPresent : 1;
    UInt8 concentrationInMMOL : 1;
    UInt8 sensorStatusAnnunciationPresent : 1;
    UInt8 reserved : 4;
};

struct BluetoothGlucoseFeatureFlags {
    UInt8 lowBatteryDurringMeasurementDetection : 1;
    UInt8 sensorMalfunctionDetection : 1;
    UInt8 sensorSampleSizeSupported : 1;
    UInt8 sensorStripInsertionErrorDetectionSupported : 1;
    UInt8 sensorResultHighLowDetectionSupported : 1;
    UInt8 sensorTemperatureHighLowDetectionSupported : 1;
    UInt8 sensorReadInterruptDetectionSupported : 1;
    UInt8 generalDeviceFaultSupported : 1;
    UInt8 timeFaultSupported : 1;
    UInt8 multipleBondSupported : 1;
    UInt8 reserved : 5;
};


struct BluetoothTime {
    UInt16 year;
    UInt8 month;
    UInt8 day;
    UInt8 hour;
    UInt8 minute;
    UInt8 second;
};


NSDate *NSDateFromBluetoothTime(struct BluetoothTime time);

NSDictionary *GlucoseRecordFromData(NSData *value);
NSData *DataFromGlucoseRecord(NSDictionary *value);

struct BluetoothNibblePair {
    UInt8 low : 4;
    UInt8 high  : 4;
};

struct BluetoothSFloat {
    unsigned mantissa : 12;
    unsigned exponent : 3;
};


struct BluetoothRACP {
    UInt8 procedureOpCode;
    UInt8 procedureOperator;
};

enum BluetoothRACPProcedureOpCode {
    BluetoothRACPProcedureOpCodeUndefined = 0,
    BluetoothRACPProcedureOpCodeReportRecords,
    BluetoothRACPProcedureOpCodeDeleteRecords,
    BluetoothRACPProcedureOpCodeAbort,
    BluetoothRACPProcedureOpCodeReportRecordCount,
    BluetoothRACPProcedureOpCodeResponseReportRecordCount,
    BluetoothRACPProcedureOpCodeResponse
};

enum BluetoothRACPProcedureOperator {
    BluetoothRACPProcedureOperatorNull = 0,
    BluetoothRACPProcedureOperatorAll,
    BluetoothRACPProcedureOperatorLessThanOrEqual,
    BluetoothRACPProcedureOperatorGreaterThanOrEqual,
    BluetoothRACPProcedureOperatorWithinRange,
    BluetoothRACPProcedureOperatorFirst,
    BluetoothRACPProcedureOperatorLast
};

enum BluetoothRACPProcedureResponseCode {
    BluetoothRACPProcedureResponseCodeSuccess = 1,
    BluetoothRACPProcedureResponseCodeOpCodeNotSupported,
    BluetoothRACPProcedureResponseCodeInvalidOperator,
    BluetoothRACPProcedureResponseCodeOperatorNotSupported,
    BluetoothRACPProcedureResponseCodeInvalidOperand,
    BluetoothRACPProcedureResponseCodeNoRecordsFound,
    BluetoothRACPProcedureResponseCodeAbortUnsuccessful,
    BluetoothRACPProcedureResponseCodeProcedureNotCompleted,
    BluetoothRACPProcedureResponseCodeOperandNotSupported,
};


enum BluetoothRACPFilterType {
    BluetoothRACPFilterTypeUndefined = 0,
    BluetoothRACPFilterTypeSequenceNumber = 0x01,
    BluetoothRACPFilterTypeUserFacingTime = 0x02
};


