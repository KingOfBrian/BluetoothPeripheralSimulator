//
//  DeviceInformationService.m
//  BluetoothPeripheralSimulator
//
//  Created by bking on 2/16/14.
//  Copyright (c) 2014 Brian King. All rights reserved.
//

#import "DeviceInformationService.h"

@interface DeviceInformationService()

@property (nonatomic, copy) NSString *manufacturerName;
@property (nonatomic, copy) NSString *modelNumber;
@property (nonatomic, copy) NSString *serialNumber;
@property (nonatomic, copy) NSString *hardwareRevision;
@property (nonatomic, copy) NSString *firmwareRevision;
@property (nonatomic, copy) NSString *softwareRevision;
@property (nonatomic, copy) NSString *systemID;

@end

@implementation DeviceInformationService

+ (CBUUID *)deviceInformationServiceUUID
{
    return [CBUUID UUIDWithString:@"180a"];
}

+ (CBUUID *)manufacturerNameUUID
{
    return [CBUUID UUIDWithString:@"2a29"];
}

+ (CBUUID *)modelNumberUUID
{
    return [CBUUID UUIDWithString:@"2a24"];
}

+ (CBUUID *)serialNumberUUID
{
    return [CBUUID UUIDWithString:@"2a25"];
}

+ (CBUUID *)hardwareRevisionUUID
{
    return [CBUUID UUIDWithString:@"2a27"];
}

+ (CBUUID *)firmwareRevisionUUID
{
    return [CBUUID UUIDWithString:@"2a26"];
}

+ (CBUUID *)softwareRevisionUUID
{
    return [CBUUID UUIDWithString:@"2a28"];
}

+ (CBUUID *)systemIDUUID
{
    return [CBUUID UUIDWithString:@"2a23"];
}

+ (NSArray *)keysForCharacteristics
{
    return @[
             @"manufacturerName",
             @"modelNumber",
             @"serialNumber",
             @"hardwareRevision",
             @"firmwareRevision",
             @"softwareRevision",
             @"systemID",
             ];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        self.service = [[CBMutableService alloc] initWithType:[self.class deviceInformationServiceUUID]
                                                      primary:YES];
        
        CBAttributePermissions permission = CBAttributePermissionsReadable;
        CBCharacteristicProperties properties = CBCharacteristicPropertyRead;
        
        NSMutableArray *characteristics = [@[] mutableCopy];
        
        for (NSString *key in self.class.keysForCharacteristics)
        {
            CBUUID *UUID = [self.class valueForKey:[key stringByAppendingString:@"UUID"]];
            [characteristics addObject:
             [[CBMutableCharacteristic alloc] initWithType:UUID
                                                properties:properties
                                                     value:nil
                                               permissions:permission]];
        }

        self.service.characteristics = characteristics;
        self.name = @"device_information";
    }
    return self;
}

- (void)registerWithServer:(RoutingHTTPServer *)server
{
    [server put:@"/service/device_information/:infokey" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSString *key = [request param:@"infokey"];
        NSString *value = [request param:@"value"];
        if (key == nil || value == nil)
        {
            [response setStatusCode:400];
            return;
        }
        NSUInteger index = [self.class.keysForCharacteristics indexOfObject:key];
        if (index == NSNotFound)
        {
            [response setStatusCode:400];
            return;
        }
        [self setValue:value forKey:key];
    }];
    
    [server get:@"/service/device_information/" withBlock:^(RouteRequest *request, RouteResponse *response) {
        NSDictionary *values = [self dictionaryWithValuesForKeys:self.class.keysForCharacteristics];
        
        [self respondWithJSON:values forResponse:response];
    }];

}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    NSUInteger index = [self.service.characteristics indexOfObject:request.characteristic];
    if (index != NSNotFound)
    {
        NSString *key = [self.class.keysForCharacteristics objectAtIndex:index];
        NSString *value = [self valueForKeyPath:key];
        request.value = [value dataUsingEncoding:NSUTF8StringEncoding];
        [peripheral respondToRequest:request withResult:CBATTErrorSuccess];
    }
    else
    {
        [peripheral respondToRequest:request withResult:CBATTErrorAttributeNotFound];
    }
}


@end
