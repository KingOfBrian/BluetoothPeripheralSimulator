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


/*
 * A basic controller for the state of the simulated peripheral.   
 *
 * It adds routes for basic configuration of the peripheral:
 *
 * - Add and remove services.   service can be 'glucose' or 'device_information'
 * POST peripheral/services/:service
 * DELETE peripheral/services/:service
 *
 * - Update advertisement status
 * PUT peripheral/advertise?status=[on|off]&localName=<advertiseName>
 *
 */
@interface PeripheralController : NSObject

@property (nonatomic, strong) CBPeripheralManager *peripheral;

- (void)addServiceController:(ServiceController *)serviceController;

- (void)registerWithServer:(RoutingHTTPServer *)server;

@property (nonatomic, assign) BOOL encrypted;

@end
