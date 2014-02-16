//
//  BluetoothDefines.m
//  cirrus
//
//  Created by Brian King on 3/19/13.
//
//

#import "BluetoothDefines.h"

NSDate *NSDateFromBluetoothTime(struct BluetoothTime time)
{
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.year   = time.year;
    components.month  = time.month;
    components.day    = time.day;
    components.hour   = time.hour;
    components.minute = time.minute;
    components.second = time.second;

    NSDate *date = [[NSCalendar currentCalendar] dateFromComponents:components];
    return date;
}

NSDictionary *GlucoseRecordFromData(NSData *value)
{
    struct BluetoothGlucoseMeasurementFlags flags;
    UInt16 sequnce_number;
    struct BluetoothTime bt_time;
    UInt16 offset;
    struct BluetoothSFloat concentration;
    struct BluetoothNibblePair typeAndLocation;
    UInt16 sensorAnnunciation;
    
    [value getBytes:&flags range:NSMakeRange(0, 1)];
    [value getBytes:&sequnce_number range:NSMakeRange(1, 2)];
    [value getBytes:&bt_time range:NSMakeRange(3, 7)];
    
    //        if (flags.timeOffsetPresent)
    [value getBytes:&offset range:NSMakeRange(10, 2)];
    //        if (flags.glucoseConcentrationPresent)
    {
        [value getBytes:&concentration range:NSMakeRange(12, 2)];
        [value getBytes:&typeAndLocation range:NSMakeRange(14, 1)];
        
        // Convert to display size
        //            concentration.exponent -= flags.concentrationInMMOL ? 3 : 5;
        //            Odd, this works though!
        concentration.exponent = 0;
    }
    //        if (flags.sensorStatusAnnunciationPresent)
    [value getBytes:&sensorAnnunciation range:NSMakeRange(15, 2)];
    
    NSDecimalNumber *dn = [[NSDecimalNumber alloc] initWithMantissa:concentration.mantissa
                                                           exponent:concentration.exponent
                                                         isNegative:NO];
    NSDate *date = NSDateFromBluetoothTime(bt_time);
    
    NSDictionary *record = @{
                             @"concentration":dn,
                             @"date":date,
                             @"sequence_number":@(sequnce_number)
                             };
    return record;
}

NSData *DataFromGlucoseRecord(NSDictionary *value)
{
    return nil;
}

