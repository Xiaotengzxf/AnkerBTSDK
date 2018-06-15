//
//  supportedService.swift
//  Headset
//
//  Created by 方仁佑 on 2016/5/11.
//  Copyright © 2016年 jayfang. All rights reserved.
//

import Foundation

/**
 supportedService object is a singleton object
 */
@objc class SupportedService :  NSObject {
    
    /// the singleton instance
    @objc static let sharedInstance = SupportedService()
    let option = BTOption()
    
    fileprivate override init() {
        //head code supporting list
        _supportedList["\(option.serviceUUID)_\(option.notifyCharacteristicUUID)"] = option.notifyCharacteristicUUID
        _supportedList["\(option.serviceUUID)_\(option.writeCharacteristicUUID)"] = option.writeCharacteristicUUID
        _supportedServiceList[option.serviceUUID] = option.serviceUUID
    }
    
    //support list
    fileprivate var _supportedList = [String:String]()
    fileprivate var _supportedServiceList = [String:String]()

    /**
     please add client defined serivce and characteristic before call ZFramework.sharedInstance.setPeripheral()
     
     - parameter serviceUUID: string of serivce uuid
     - parameter charUUID: string of characteristic uuid    */
    @objc func addSupportServiceAndCharacteristic( serviceUUID:String, charUUID:String) {
        _supportedServiceList[serviceUUID] = serviceUUID
        _supportedList[serviceUUID + "_" + charUUID] = charUUID
    }
    
    func getSupportService(serv_uuid:String , char_uuid:String) -> String {
        let tmp = serv_uuid + "_" + char_uuid
        
        if( _supportedList[tmp] != nil ) {
            return _supportedList[tmp]!
        } else {
            return ""
        }
    }
    
    func isSupportService(serv_uuid:String) -> Bool {
        if _supportedServiceList[serv_uuid] != nil {
            return true
        }
        return false
    }
    
    func supportedServiceList() -> [String: String] {
        return _supportedServiceList
    }
    
}
