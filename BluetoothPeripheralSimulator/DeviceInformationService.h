//
//  DeviceInformationService.h
//  BluetoothPeripheralSimulator
//
//  Created by bking on 2/16/14.
//  Copyright (c) 2014 Brian King. All rights reserved.
//

#import "ServiceController.h"

/*
 * A simulated device information service as defined by:
 *     https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.device_information.xml
 *
 *
 * - Configure the values of the device information service
 * PUT /service/device_information/:infokey?value=<STRING>
 *    Where :infokey is:
 *        manufacturerName
 *        modelNumber
 *        serialNumber
 *        hardwareRevision
 *        firmwareRevision
 *        softwareRevision
 *        systemID
 *
 * - Return all of the values configured on the device information service.
 * GET /service/device_information/
 *
 */
@interface DeviceInformationService : ServiceController

@end
