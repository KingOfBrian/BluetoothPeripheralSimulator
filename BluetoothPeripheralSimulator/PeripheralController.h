//
//  PeripheralController.h
//  BluetoothPeripheralSimulator
//
//  Created by bking on 2/15/14.
//  Copyright (c) 2014 Brian King. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOBluetooth/IOBluetooth.h>
#import <RoutingHTTPServer/RoutingHTTPServer.h>

#import "ServiceController.h"


@interface PeripheralController : NSObject

@property (nonatomic, strong) CBPeripheralManager *peripheral;

- (void)addServiceController:(ServiceController *)serviceController;

- (void)registerWithServer:(RoutingHTTPServer *)server;

@property (nonatomic, assign) BOOL encrypted;

@end
