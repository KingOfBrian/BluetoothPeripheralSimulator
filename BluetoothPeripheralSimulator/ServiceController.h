//
//  ServiceController.h
//  BluetoothPeripheralSimulator
//
//  Created by bking on 2/15/14.
//  Copyright (c) 2014 Brian King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import <RoutingHTTPServer/RoutingHTTPServer.h>

@interface ServiceController : NSObject <CBPeripheralManagerDelegate>

@property (nonatomic, strong) CBPeripheralManager *peripheral;
@property (nonatomic, strong) CBMutableService *service;

@property (nonatomic, assign) BOOL encrypted;
@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, copy) NSString *name;

- (void)registerWithServer:(RoutingHTTPServer *)server;

- (BOOL)respondWithJSON:(id)object forResponse:(RouteResponse *)response;
@end
