# BluetoothPeripheralSimulator

Simulate various Bluetooth services which can be configured via a HTTP rest-ish interface.   Currently only supports Mac OSX, although iOS support is planned.  Once the app is started, an HTTP server is started on port 8000.   This HTTP server can configure both the glucose and device_information profile.  More profiles can be added easily.

# HTTP Documentation

## Peripheral Configuration

### Add / Remove services.

    POST peripheral/services/:service
    DELETE peripheral/services/:service
    
    Where :service is 'glucose' or 'device_information'.
 
### Advertise
Update advertisement status

    PUT peripheral/advertise?status=[on|off]&localName=<advertiseName>


## Device Information Service

A simulated [Device Information Service](https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.device_information.xml)
  
 

### Configure

    PUT /service/device_information/:infokey?value=<STRING>

    Where :infokey is:
        manufacturerName
        modelNumber
        serialNumber
        hardwareRevision
        firmwareRevision
        softwareRevision
        systemID

### Fetch

    GET /service/device_information/


## Glucose Service

A simulated [Glucose Service](https://developer.bluetooth.org/gatt/services/Pages/ServiceViewer.aspx?u=org.bluetooth.service.glucose.xml)
  
 
### Create Glucose Record  
Create a new glucose value.   A new record ID will be provided

    POST /service/glucose?value=V&timestamp=TS&timestampOffset=TO

### Fetch Glucose Records
Get all configured glucose values

    GET /service/glucose
 
### Delete Glucose Records
Delete specific glucose values using the specified record ID

    DELETE /service/glucose/:id
 
### Configure Glucose Service
Configure the features of the glucose service.  Currently this just configures the returned data,
although it could modify the behavior of the simulated glucose service in the future.

    PUT /service/glucose/feature/:feature?status=[on|off]

    Where :feature is:
        lowBatteryDurringMeasurementDetection
        sensorMalfunctionDetection
        sensorSampleSizeSupported
        sensorStripInsertionErrorDetectionSupported
        sensorResultHighLowDetectionSupported
        sensorTemperatureHighLowDetectionSupported
        sensorReadInterruptDetectionSupported
        generalDeviceFaultSupported
        timeFaultSupported
        multipleBondSupported

