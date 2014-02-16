//
//  AppDelegate.m
//  BluetoothPeripheralSimulator
//
//  Created by bking on 2/15/14.
//  Copyright (c) 2014 Brian King. All rights reserved.
//

#import "AppDelegate.h"

#import <RoutingHTTPServer/RoutingHTTPServer.h>

#import "PeripheralController.h"
#import "GlucoseService.h"
#import "DeviceInformationService.h"

@interface AppDelegate()
@property (nonatomic, strong) RoutingHTTPServer *server;
@property (nonatomic, strong) PeripheralController *peripheral;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.server = [[RoutingHTTPServer alloc] init];
    [self.server setPort:8000];


    self.peripheral = [[PeripheralController alloc] init];
    [self.peripheral addServiceController:[[GlucoseService alloc] init]];
    [self.peripheral addServiceController:[[DeviceInformationService alloc] init]];
    
    [self.peripheral registerWithServer:self.server];
    
    NSError *error = nil;
    [self.server start:&error];
    NSAssert(error == nil, @"");
}

@end
