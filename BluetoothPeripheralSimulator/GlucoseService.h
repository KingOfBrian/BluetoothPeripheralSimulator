//
//  GlucoseService.h
//  BluetoothPeripheralSimulator
//
//  Created by bking on 2/15/14.
//  Copyright (c) 2014 Brian King. All rights reserved.
//

#import "ServiceController.h"

/*
 * A simulated glucose service as defined by:
 *     https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.glucose.xml
 *
 * - Create a new glucose value.   A new record ID will be provided
 * POST /service/glucose?value=V&timestamp=TS&timestampOffset=TO
 *
 * - Get all configured glucose values
 * GET /service/glucose
 *
 * - Delete specific glucose values using the specified record ID
 * DELETE /service/glucose/:id
 *
 * - Configure the features of the glucose service
 * PUT /service/glucose/feature/:feature?status=[on|off]
 *    Where :feature is:
 *        lowBatteryDurringMeasurementDetection
 *        sensorMalfunctionDetection
 *        sensorSampleSizeSupported
 *        sensorStripInsertionErrorDetectionSupported
 *        sensorResultHighLowDetectionSupported
 *        sensorTemperatureHighLowDetectionSupported
 *        sensorReadInterruptDetectionSupported
 *        generalDeviceFaultSupported
 *        timeFaultSupported
 *        multipleBondSupported
 *
 */
@interface GlucoseService : ServiceController

@end
