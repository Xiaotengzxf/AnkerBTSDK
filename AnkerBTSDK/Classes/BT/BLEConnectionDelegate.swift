//
//  BLEConnectionDelegate.swift
//  BLEConnection
//
//  Created by Tool Airoha on 2017/7/26.
//  Copyright © 2017年 Tool Airoha. All rights reserved.
//

import Foundation
/**
 ENUM: BLEConnectResult
 
 success: Connect BLE success
 
 connectFail: Got centralManager didFailToConnect callback
 
 noClassicConnection: There is no classic Bluetooth connection, please connect the BT3.0 first in system page
 
 timeout: connection timeout, cannot find the BLE device
 */
enum BLEConnectResult: Int {
    case unkown
    case success
    case connectFail
    case timeout
}

/**
 Beacause CBManagerState have to use above ios10, so here create a new enum
 */
enum SystemBTState: Int {
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
}

/**
 The BLEConnectionDelegate protocol defines the BLE connection result and RSSI value
 */
protocol BLEConnectionDelegate: NSObjectProtocol {
    /**
     It tells the delegate can start to call connectBLE() API
     */
    func onReadyToConnect()
    /**
     It tells the delegate the result of connectBLE()
     */
    func onBLEConnectFinished(result: BLEConnectResult)
    /**
     It tells the delegate the BLE is disconnected
     */
    func onBLEDisconnected()
    /**
     It tells the delegate the BLE RSSI value
     */
    func onBLERSSIValue(rssi: NSNumber)
    /**
     It tells the delegate the system bt state changed
     */
    func onSystemBTStateChange(state: SystemBTState)
    /**
     Scan BLE Finished
    */
    func onBLEDeviceScanFinished()
    
}
