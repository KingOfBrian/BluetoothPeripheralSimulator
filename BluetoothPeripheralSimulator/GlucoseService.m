//
//  GlucoseService.m
//  BluetoothPeripheralSimulator
//
//  Created by bking on 2/15/14.
//  Copyright (c) 2014 Brian King. All rights reserved.
//

#import "GlucoseService.h"
#import "BluetoothDefines.h"


@interface GlucoseService()

@property (nonatomic, assign) struct BluetoothGlucoseFeatureFlags glucoseFeatureFlags;

@property (nonatomic, strong) CBMutableCharacteristic *racp;
@property (nonatomic, strong) CBMutableCharacteristic *glucoseMeasurement;
@property (nonatomic, strong) CBMutableCharacteristic *glucoseFeature;

@property (nonatomic, strong) NSMutableArray *glucoseValues;
@property (nonatomic, assign) NSUInteger recordID;


@property (nonatomic, strong) NSMutableArray *racpSubscribers;
@property (nonatomic, strong) NSMutableArray *measurementSubscribers;

@end

@implementation GlucoseService

+ (CBUUID *)glucoseServiceUUID
{
    return [CBUUID UUIDWithString:@"1808"];
}

+ (CBUUID *)glucoseRacpCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"2a52"];
}

+ (CBUUID *)glucoseMeasurementCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"2a18"];
}

+ (CBUUID *)glucoseFeatureCharacteristicUUID
{
    return [CBUUID UUIDWithString:@"2a51"];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.glucoseValues = [@[] mutableCopy];
        self.recordID = 1;
        
        self.service = [[CBMutableService alloc] initWithType:[self.class glucoseServiceUUID]
                                                      primary:YES];
        
        CBAttributePermissions permission = CBAttributePermissionsWriteEncryptionRequired;
        CBCharacteristicProperties properties = CBCharacteristicPropertyIndicateEncryptionRequired;
        
        self.racp = [[CBMutableCharacteristic alloc] initWithType:[self.class glucoseRacpCharacteristicUUID]
                                                                     properties:properties
                                                                          value:nil
                                                                    permissions:permission];

        permission = CBAttributePermissionsReadEncryptionRequired;
        properties = CBCharacteristicPropertyNotifyEncryptionRequired;
        
        self.glucoseMeasurement = [[CBMutableCharacteristic alloc] initWithType:[self.class glucoseMeasurementCharacteristicUUID]
                                                                            properties:properties
                                                                                 value:nil
                                                                           permissions:permission];
        
        properties = CBCharacteristicPropertyRead;
        self.glucoseFeature = [[CBMutableCharacteristic alloc] initWithType:[self.class glucoseFeatureCharacteristicUUID]
                                                                 properties:properties
                                                                      value:nil
                                                                permissions:permission];
        
        self.service.characteristics = @[
                                         self.racp,
                                         self.glucoseMeasurement,
                                         self.glucoseFeature
                                         ];
        
        self.name = @"glucose";

    }
    return self;
}

- (NSData *)glucoseFeatureData
{
    return [NSData dataWithBytes:&_glucoseFeatureFlags length:sizeof(struct BluetoothGlucoseFeatureFlags)];
}

- (void)registerWithServer:(RoutingHTTPServer *)server
{
    [server post:@"/service/glucose" withBlock:^(RouteRequest *request, RouteResponse *response) {
        BOOL ok = [request param:@"value"] && [request param:@"timestamp"] && [request param:@"timestampOffset"];
        if (ok)
        {
            NSDictionary *newValue = @{
                                       @"value" : [request param:@"value"],
                                       @"timestamp" : [request param:@"timestamp"],
                                       @"timestampOffset" : [request param:@"timestampOffset"],
                                       @"recordID" : @(self.recordID++)
                                       };
            
            ok = [self respondWithJSON:newValue forResponse:response];
            [self performSelector:@selector(notifyNewGlucoseValue:) withObject:newValue afterDelay:0.1];
        }
        [response setStatusCode:ok ? 201 : 400];
    }];

    [server get:@"/service/glucose" withBlock:^(RouteRequest *request, RouteResponse *response) {
        BOOL ok = [self respondWithJSON:self.glucoseValues forResponse:response];
        
        [response setStatusCode:ok ? 200 : 400];
    }];
    
    [server delete:@"/service/glucose/:id" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSUInteger recordIndex = NSNotFound;
        for (NSUInteger i = 0; i < [self.glucoseValues count]; i++)
        {
            NSDictionary *glucoseValue = self.glucoseValues[i];
            if ([glucoseValue[@"recordID"] integerValue] == [[request param:@"id"] integerValue])
            {
                recordIndex = i;
                [self.glucoseValues removeObjectAtIndex:recordIndex];
                break;
            }
        }
        [response setStatusCode:recordIndex != NSNotFound ? 200 : 404];
    }];
    
    [server put:@"/service/glucose/feature/:feature" withBlock:^(RouteRequest *request, RouteResponse *response) {
        if ([request param:@"status"] == nil)
        {
            [response setStatusCode:400];
            return;
        }
        BOOL status = [[request param:@"status"] isEqualToString:@"on"];
        NSString *feature = [request param:@"feature"];

        if ([feature isEqualToString:@"lowBatteryDurringMeasurementDetection"])
            _glucoseFeatureFlags.lowBatteryDurringMeasurementDetection = status;
        else if ([feature isEqualToString:@"sensorMalfunctionDetection"])
            _glucoseFeatureFlags.sensorMalfunctionDetection = status;
        else if ([feature isEqualToString:@"sensorSampleSizeSupported"])
            _glucoseFeatureFlags.sensorSampleSizeSupported = status;
        else if ([feature isEqualToString:@"sensorStripInsertionErrorDetectionSupported"])
            _glucoseFeatureFlags.sensorStripInsertionErrorDetectionSupported = status;
        else if ([feature isEqualToString:@"sensorResultHighLowDetectionSupported"])
            _glucoseFeatureFlags.sensorResultHighLowDetectionSupported = status;
        else if ([feature isEqualToString:@"sensorTemperatureHighLowDetectionSupported"])
            _glucoseFeatureFlags.sensorTemperatureHighLowDetectionSupported = status;
        else if ([feature isEqualToString:@"sensorReadInterruptDetectionSupported"])
            _glucoseFeatureFlags.sensorReadInterruptDetectionSupported = status;
        else if ([feature isEqualToString:@"generalDeviceFaultSupported"])
            _glucoseFeatureFlags.generalDeviceFaultSupported = status;
        else if ([feature isEqualToString:@"timeFaultSupported"])
            _glucoseFeatureFlags.timeFaultSupported = status;
        else if ([feature isEqualToString:@"multipleBondSupported"])
            _glucoseFeatureFlags.multipleBondSupported = status;
        else
        {
            [response setStatusCode:404];
            return;
        }

        [response setStatusCode:200];
    }];
}

- (void)notifyNewGlucoseValue:(NSDictionary *)glucoseValue
{
    BOOL sent = [self.peripheral updateValue:DataFromGlucoseRecord(glucoseValue) forCharacteristic:self.glucoseMeasurement onSubscribedCentrals:nil];
    
    NSAssert(sent == YES, @"Data sent has over-flowed the central buffer.  This is naive and must handled better.");
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    if (characteristic == self.racp)
        [self.racpSubscribers addObject:central];
    else if (characteristic == self.glucoseMeasurement)
        [self.measurementSubscribers addObject:central];
    else
        [NSException raise:NSInvalidArgumentException format:@"Unknown Characteristic"];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    if (characteristic == self.racp)
        [self.racpSubscribers removeObject:central];
    else if (characteristic == self.glucoseMeasurement)
        [self.measurementSubscribers removeObject:central];
    else
        [NSException raise:NSInvalidArgumentException format:@"Unknown Characteristic"];

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    if (request.characteristic == self.glucoseFeature)
    {
        request.value = [self glucoseFeatureData];
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
    else
    {
        [peripheral respondToRequest:request withResult:CBATTErrorAttributeNotFound];

    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    for (CBATTRequest *request in requests)
    {
        if (request.characteristic == self.racp)
            [self handleRacpWriteRequest:request];
        else
        {
            [peripheral respondToRequest:[requests firstObject] withResult:CBATTErrorAttributeNotFound];
            return;
        }
    }
    [peripheral respondToRequest:[requests firstObject] withResult:CBATTErrorSuccess];
}

- (struct BluetoothRACP)racpResponseForOperandData:(NSData *)data forOpCode:(enum BluetoothRACPProcedureOpCode)opCode andOperator:(enum BluetoothRACPProcedureOperator)operator
{
    struct BluetoothRACP racp;
    racp.procedureOpCode = BluetoothRACPProcedureOpCodeResponse;
    racp.procedureOperator = BluetoothRACPProcedureResponseCodeSuccess;
    if (operator == BluetoothRACPProcedureOperatorNull || operator > BluetoothRACPProcedureOperatorLast) {
        racp.procedureOperator = BluetoothRACPProcedureResponseCodeInvalidOperator;
    }
    
    // At this point, the only operator supported is all.   Need to understand filter behavior better before implementing others.
    if (operator != BluetoothRACPProcedureOperatorAll)
    {
        racp.procedureOperator = BluetoothRACPProcedureResponseCodeOperatorNotSupported;
    }
    
    return racp;
}

- (NSArray *)glucoseValuesForOperator:(enum BluetoothRACPProcedureOperator)operator operandData:(NSData *)data
{
    //  At this point, no filters are supported, just return everything.
    return self.glucoseValues;
}

- (void)handleRacpWriteRequest:(CBATTRequest *)request
{
    NSUInteger len = sizeof(struct BluetoothRACP);


    struct BluetoothRACP racp;
    [request.value getBytes:&racp range:NSMakeRange(0, len)];
    NSData *operandData = [request.value subdataWithRange:NSMakeRange(len, [request.value length] - len)];

    enum BluetoothRACPProcedureOpCode opcode = racp.procedureOpCode;
    enum BluetoothRACPProcedureOperator operator = racp.procedureOperator;
   
    switch (opcode)
    {
        case BluetoothRACPProcedureOpCodeDeleteRecords:
        {
            racp.procedureOpCode = BluetoothRACPProcedureOpCodeResponse;
            racp.procedureOperator = BluetoothRACPProcedureResponseCodeOpCodeNotSupported;

            break;
        }
        case BluetoothRACPProcedureOpCodeReportRecords:
        {
            racp = [self racpResponseForOperandData:operandData forOpCode:opcode andOperator:operator];
            if (racp.procedureOperator == BluetoothRACPProcedureResponseCodeSuccess)
            {
                NSArray *glucoseValues = [self glucoseValuesForOperator:operator operandData:operandData];
                
                for (NSDictionary *glucoseValue in glucoseValues)
                {
                    BOOL sent = [self.peripheral updateValue:DataFromGlucoseRecord(glucoseValue)
                                           forCharacteristic:self.glucoseMeasurement
                                        onSubscribedCentrals:@[request.central]];
                    
                    NSAssert(sent == YES, @"Data sent has over-flowed the central buffer.  This is naive and must handled better.");
                }
                
                if ([glucoseValues count] == 0)
                {
                    racp.procedureOperator = BluetoothRACPProcedureResponseCodeNoRecordsFound;
                }
            }
            break;
        }
        case BluetoothRACPProcedureOpCodeReportRecordCount:
        {
            racp = [self racpResponseForOperandData:operandData forOpCode:opcode andOperator:operator];
            if (racp.procedureOperator == BluetoothRACPProcedureResponseCodeSuccess)
            {
                NSArray *glucoseValues = [self glucoseValuesForOperator:operator operandData:operandData];
                
                racp.procedureOpCode = BluetoothRACPProcedureOpCodeResponseReportRecordCount;
                racp.procedureOperator = [glucoseValues count];
            }
            break;
        }
        case BluetoothRACPProcedureOpCodeAbort:
        {
            racp.procedureOpCode = BluetoothRACPProcedureOpCodeResponse;
            racp.procedureOperator = BluetoothRACPProcedureResponseCodeSuccess;

            if (operator != BluetoothRACPProcedureOperatorNull) {
                racp.procedureOperator = BluetoothRACPProcedureResponseCodeInvalidOperator;
            }
        }
        case BluetoothRACPProcedureOpCodeResponseReportRecordCount:
        case BluetoothRACPProcedureOpCodeResponse:
        case BluetoothRACPProcedureOpCodeUndefined:
        default:
        {
            racp.procedureOpCode = BluetoothRACPProcedureOpCodeResponse;
            racp.procedureOperator = BluetoothRACPProcedureResponseCodeOpCodeNotSupported;
            break;
        }
    }
 
    BOOL sent = [self.peripheral updateValue:[NSData dataWithBytes:&racp length:len]
                           forCharacteristic:self.racp
                        onSubscribedCentrals:@[request.central]];
    
    NSAssert(sent == YES, @"Data sent has over-flowed the central buffer.  This is naive and must handled better.");
}


@end
