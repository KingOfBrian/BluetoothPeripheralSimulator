//
//  ServiceController.m
//  BluetoothPeripheralSimulator
//
//  Created by bking on 2/15/14.
//  Copyright (c) 2014 Brian King. All rights reserved.
//

#import "ServiceController.h"

@implementation ServiceController

- (void)registerWithServer:(RoutingHTTPServer *)server
{
    [NSException raise:NSInvalidArgumentException format:@"'%@' must be implemented by subclass %@", NSStringFromSelector(_cmd), NSStringFromClass(self.class)];
}

- (BOOL)respondWithJSON:(id)object forResponse:(RouteResponse *)response
{
    NSError *error = nil;
    NSData *body = [NSJSONSerialization dataWithJSONObject:object
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (error)
    {
        NSString *errorString = [NSString stringWithFormat:@"JSON Serialization Error: %@",
                                 [error localizedDescription]];
        [response respondWithString:errorString];
    }
    else
    {
        [response respondWithData:body];
    }

    return error == nil;
}


- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
}


@end
