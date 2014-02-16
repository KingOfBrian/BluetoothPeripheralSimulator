//
//  Peripheral.m
//  BluetoothPeripheralSimulator
//
//  Created by bking on 2/15/14.
//  Copyright (c) 2014 Brian King. All rights reserved.
//

#import "PeripheralController.h"

@interface PeripheralController() <CBPeripheralManagerDelegate>

@property (nonatomic, strong) NSMutableArray *serviceControllers;

@end

@implementation PeripheralController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.peripheral = [[CBPeripheralManager alloc] initWithDelegate:self queue:nil];
        self.serviceControllers = [@[] mutableCopy];
    }
    return self;
}

- (void)addServiceController:(ServiceController *)serviceController
{
    serviceController.peripheral = self.peripheral;
    [self.serviceControllers addObject:serviceController];
}

- (void)registerWithServer:(RoutingHTTPServer *)server
{
    [server post:@"/peripheral/services/:service" withBlock:^(RouteRequest *request, RouteResponse *response) {
        ServiceController *serviceController = [self serviceControllerNamed:[request param:@"service"]];
        BOOL ok = serviceController && serviceController.enabled == NO;
        if (ok)
        {
            [self.peripheral addService:serviceController.service];
            serviceController.enabled = YES;
        }
        [response setStatusCode:ok ? 200 : 404];
    }];
    
    [server delete:@"/peripheral/services/:service" withBlock:^(RouteRequest *request, RouteResponse *response) {
        ServiceController *serviceController = [self serviceControllerNamed:[request param:@"service"]];
        BOOL ok = serviceController && serviceController.enabled == YES;

        if (ok)
        {
            [self.peripheral removeService:serviceController.service];
            serviceController.enabled = NO;

        }
        [response setStatusCode:ok ? 200 : 404];
    }];
    [server put:@"/peripheral/advertise" withBlock:^(RouteRequest *request, RouteResponse *response) {
        BOOL start = [[request param:@"status"] isEqualToString:@"on"];
        NSString *localName = [request param:@"localName"] ? [request param:@"localName"] : @"Peripheral Simulator";
        
        if (start)
        {
            [self.peripheral startAdvertising:@{CBAdvertisementDataLocalNameKey:localName}];
        }
        else
        {
            [self.peripheral stopAdvertising];
        }

        [response setStatusCode:200];
    }];
    
    for (ServiceController *serviceController in self.serviceControllers)
    {
        [serviceController registerWithServer:server];
    }
}

- (ServiceController *)serviceControllerForCharacteristic:(CBCharacteristic *)characteristic
{
    for (ServiceController *serviceController in self.serviceControllers)
    {
        if ([serviceController.service.characteristics containsObject:characteristic])
        {
            return serviceController;
        }
    }
    return nil;
}

- (ServiceController *)serviceControllerForService:(CBService *)service
{
    for (ServiceController *serviceController in self.serviceControllers)
    {
        if ([serviceController.service isEqual:service])
        {
            return serviceController;
        }
    }
    return nil;
}

- (ServiceController *)serviceControllerNamed:(NSString *)name
{
    for (ServiceController *serviceController in self.serviceControllers)
    {
        if ([serviceController.name isEqual:name])
        {
            return serviceController;
        }
    }
    return nil;
}


#pragma mark CBPeripheralManagerDelegate

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral
{
    
}

- (void)peripheralManagerDidStartAdvertising:(CBPeripheralManager *)peripheral error:(NSError *)error
{
    for (ServiceController *serviceController in self.serviceControllers)
    {
        [serviceController peripheralManagerDidStartAdvertising:peripheral error:error];
    }
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didAddService:(CBService *)service error:(NSError *)error
{
    [[self serviceControllerForService:service] peripheralManager:peripheral didAddService:service error:error];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didSubscribeToCharacteristic:(CBCharacteristic *)characteristic
{
    [[self serviceControllerForCharacteristic:characteristic] peripheralManager:peripheral
                                                                        central:central
                                                   didSubscribeToCharacteristic:characteristic];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral central:(CBCentral *)central didUnsubscribeFromCharacteristic:(CBCharacteristic *)characteristic
{
    [[self serviceControllerForCharacteristic:characteristic] peripheralManager:peripheral
                                                                        central:central
                                               didUnsubscribeFromCharacteristic:characteristic];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveReadRequest:(CBATTRequest *)request
{
    ServiceController *serviceController = [self serviceControllerForCharacteristic:request.characteristic];
    [serviceController peripheralManager:peripheral didReceiveReadRequest:request];
}

- (void)peripheralManager:(CBPeripheralManager *)peripheral didReceiveWriteRequests:(NSArray *)requests
{
    CBATTRequest *request = [requests lastObject];
    ServiceController *serviceController = [self serviceControllerForCharacteristic:request.characteristic];

    [serviceController peripheralManager:peripheral didReceiveWriteRequests:requests];
}

- (void)peripheralManagerIsReadyToUpdateSubscribers:(CBPeripheralManager *)peripheral
{
    for (ServiceController *serviceController in self.serviceControllers)
    {
        [serviceController peripheralManagerIsReadyToUpdateSubscribers:peripheral];
    }
}

@end
