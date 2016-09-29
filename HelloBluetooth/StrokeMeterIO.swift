// Simple BlueTooth I/O management class. Created from an original project by Nebojsa Petrovic on April 2016.
// The base project can be found at https://github.com/nebs/hello-bluetooth
//
// As part of my A-Level project to build an StrokeMeter for rowing coaching which uses bluetooth to connect to an IOS
// device I have made enhanced the code to do the following functions:
//
// The StrokeMeterDevice Class uses iOS Core BlueTooth to offer the following methods:
// 1.  Search for devices advertising with the correct UUID indicating that they are Stroke Meter Devices
// 2.  Create list of devices for selection (Need to build this currently just connecting to device found))
// 3.  Connect to the selected device (Need to build currently just connecting to the device found)
// 4.  Discover Services that the Stroke Meter is using
// 5.  Discover the Characteristics including ideintifying the writable characteristics
// 6.  Provide a method .writeValue to allow writing a value to the Stroke Meter Device
// 7.  Provide a delegate method for managing a value sent by the Stroke Meter device


import CoreBluetooth

protocol StrokeMeterIODelegate: class {
    func didReceiveValue(_ StrokeMeterIO: StrokeMeterIO, value: Int8)
}

class StrokeMeterIO: NSObject {
    
    let serviceUUID: String
    weak var delegate: StrokeMeterIODelegate?

    var centralManager: CBCentralManager!
    var connectedPeripheral: CBPeripheral?
    var targetService: CBService?
    var writableCharacteristic: CBCharacteristic?

    init(serviceUUID: String, delegate: StrokeMeterIODelegate?) {
        self.serviceUUID = serviceUUID
        self.delegate = delegate

        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func writeValue(_ value: Int8) {
        guard let peripheral = connectedPeripheral, let characteristic = writableCharacteristic else {
            return
        }

        let data = NSData.dataWithValue(value: value)
        peripheral.writeValue(data as Data, for: characteristic, type: .withResponse)
    }

}

extension StrokeMeterIO: CBCentralManagerDelegate {
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        connectedPeripheral = peripheral

        if let connectedPeripheral = connectedPeripheral {
            connectedPeripheral.delegate = self
            centralManager.connect(connectedPeripheral, options: nil)
        }
        centralManager.stopScan()
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [CBUUID(string: serviceUUID)], options: nil)
        }
    }
}

extension StrokeMeterIO: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }

        targetService = services.first
        if let service = services.first {
            targetService = service
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }

        for characteristic in characteristics {
            if characteristic.properties.contains(.write) || characteristic.properties.contains(.writeWithoutResponse) {
                writableCharacteristic = characteristic
            }
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let data: NSData = characteristic.value as NSData?, let delegate = delegate else {
            return
        }

        delegate.didReceiveValue(self, value: data.int8Value())
    }
}
