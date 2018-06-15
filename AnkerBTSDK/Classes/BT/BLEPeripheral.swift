//
//  BTManager..swift
//
//
//  Created by Bruce on 2016/3/7.
//  Copyright © 2016年 Bruce. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol characteristicChangeDelegate {
    func characteristicChange( char :  CBCharacteristic) -> Bool
    func peripheralActivityChange(activePeripheral: CBPeripheral?)
}

class BLEPeripheral :  NSObject, CBPeripheralDelegate {
    
    //singleton
    static let sharedInstance = BLEPeripheral()
    fileprivate override init() {}
    
    //member
    fileprivate weak var activePeripheral: CBPeripheral?
    fileprivate var _charList = [CBCharacteristic]()
    fileprivate var _charListSetNotification = [CBCharacteristic:Bool]()
    fileprivate var _notifyInsideDelegate = [String : characteristicChangeDelegate]()
    fileprivate var _foundServiceCount = 0
    //
    //  set / release  peripherial to this calss
    //
    func setPeripheral(_ peripheral: CBPeripheral){
        
        //assign new one
        activePeripheral = peripheral
        activePeripheral?.delegate = self
        
        /*****reset******/
        _charList.removeAll()
        _charListSetNotification.removeAll()
        _foundServiceCount = 0
        /*****reset******/
    
        //start discovery
        activePeripheral?.discoverServices(nil)
        notifyPeripheralActivityChange()
    }
    
    func releasePeripheral(){
        _charList.removeAll()
        _charListSetNotification.removeAll()
        activePeripheral?.delegate = nil
        activePeripheral = nil
        _foundServiceCount = 0
        //CMDQueue.sharedInstance.clearCmdQueue()
        notifyPeripheralActivityChange()
    }
    
    @objc func readRSSI() {
        if activePeripheral != nil {
            activePeripheral?.readRSSI()
        } else {
        }
    }
    
    //
    //  notificaion functions , get List
    //
    func regCharacteristicChangeDelegate(_ name:String ,  delegate: characteristicChangeDelegate) {
        _notifyInsideDelegate[name] = delegate
    }
    
    func notifyCharacteristicChange(_ char:CBCharacteristic) {
        var airohaDefined = false
        for (_ , delegate) in _notifyInsideDelegate {
            if delegate.characteristicChange(char: char) == true {
                airohaDefined = true
                break
            }
        }
        if airohaDefined == false {
            //ZFramework.sharedInstance._controlModule.AirohaNotDefinedResp(characteristic: char)
        }
    }
    
    func notifyPeripheralActivityChange() {
        for delegate in _notifyInsideDelegate {
            delegate.1.peripheralActivityChange(activePeripheral: activePeripheral)
        }
    }
    
    func getCharList() -> [CBCharacteristic] {
        return _charList
    }
    
    func getCharByUUID(_ UUID:String) -> CBCharacteristic? {
        for node in _charList {
            
            if node.uuid.uuidString == UUID {
                return node
            }
        }
        return nil
    }
    
    func isPeripheralValid() -> Bool {
        return self.activePeripheral == nil ? false : true
    }
    
    func setNotificationValue(enabled:Bool, characteristic:CBCharacteristic) {
        
        activePeripheral?.setNotifyValue(enabled, for: characteristic)
        _charListSetNotification.updateValue(enabled, forKey: characteristic)
    }
    
    func getNotificationValueEnabled(characteristic:CBCharacteristic) -> Bool {
        if let char = _charListSetNotification[characteristic] {
            return char
        }
        return false
        
    }
    
    //
    //  write char
    //
    func writeCharacteristics(_ key: String, data: Data) {
        if let node = getCharByUUID(key) {
            let cutLength = 150
            var count: Int = 0
            let dataLen: Int = data.count
            if (dataLen > cutLength) {
                while(count < dataLen && dataLen - count > cutLength) {
                    activePeripheral?.writeValue(data.subdata(in: count..<count+cutLength), for: node , type: .withoutResponse)
                    print("[WriteData_F] <\(data.subdata(in: count..<count+cutLength).hexEncodedString())>")
                    count += cutLength
                }
            }
            if (count < dataLen) {
                activePeripheral?.writeValue(data.subdata(in: count..<dataLen), for: node, type: .withoutResponse)
                print("[WriteData_D] <\(data.subdata(in: count..<dataLen).hexEncodedString())>")
            }
        }
    }
    
    // for
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        if let name = peripheral.name {
            print("peripheralDidUpdateName \(name)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        if let name = peripheral.name {
            print("didModifyServices \(name)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services {
                if SupportedService.sharedInstance.isSupportService(serv_uuid: service.uuid.uuidString) {
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        print("didDiscoverIncludedServicesForService \(service.uuid)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("didDiscoverCharacteristicsForService \(service.uuid.uuidString)")
        if service.characteristics == nil {
            return
        }
        _foundServiceCount += 1
        for characteristic in service.characteristics! as [CBCharacteristic] {
            // only care supported
            if ( SupportedService.sharedInstance.getSupportService(serv_uuid: service.uuid.uuidString ,  char_uuid: characteristic.uuid.uuidString) == ""){
                continue
            }
            _charList.append(characteristic)
            print("characteristic uuid: \(characteristic.uuid.uuidString)")
            if characteristic.properties.contains(CBCharacteristicProperties.broadcast) {
                print("Properties Broadcast")
            }
            if characteristic.properties.contains(CBCharacteristicProperties.read) {
                print("Properties Read")
            }
            if characteristic.properties.contains(CBCharacteristicProperties.write) {
                print("Properties Write ")
            }
            if characteristic.properties.contains(CBCharacteristicProperties.writeWithoutResponse) {
                print("Properties WriteWithoutResponse")
            }
            if characteristic.properties.contains(CBCharacteristicProperties.notify) {
                print("Properties Notify")
                setNotificationValue(enabled: true, characteristic: characteristic)
            }
            if characteristic.properties.contains(CBCharacteristicProperties.indicate) {
                print("Properties Indicate")
            }
            if characteristic.properties.contains(CBCharacteristicProperties.authenticatedSignedWrites) {
                print("Properties AuthenticatedSignedWrites")
            }
        }
        if _foundServiceCount == SupportedService.sharedInstance.supportedServiceList().count {
            //ZFramework.sharedInstance._serviceManager.didDiscoverCharacteristic(charList: _charList, discoverAllSupportedService: true)
        } else {
            //ZFramework.sharedInstance._serviceManager.didDiscoverCharacteristic(charList: _charList, discoverAllSupportedService: false)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let resp = characteristic.value {
            print("[didUpdateValue] \(resp.hexEncodedString())  ")
        }
        notifyCharacteristicChange(characteristic)
        
    }
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("发送错误：\(error!)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let value = characteristic.value {
            print("didUpdateNotificationStateForCharacteristic \(characteristic.uuid)  => \(value.hexEncodedString()) ")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        print("didDiscoverDescriptorsForCharacteristic \(characteristic.uuid)")
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        print("didUpdateValueForDescriptor \(descriptor.uuid)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        print("didWriteValueForDescriptor \(descriptor.uuid)")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        
    }
    
    
}
