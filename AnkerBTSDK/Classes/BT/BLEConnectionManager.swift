//
//  BLEConnectionManager.swift
//  BLEConnection
//
//  Created by Tool Airoha on 2017/7/25.
//  Copyright © 2017年 Tool Airoha. All rights reserved.
//

import Foundation
import AVFoundation
import CoreBluetooth

/**
 A static, singleton class. Please do not create instances by yourself. Instead, use the BLEConnectionManager.Inst to do all you want to do. And implement the BLEConnectionDelegate protocol in your APP to listen response from our framework.
 
 
 The step of using BLEConnection connect BLE roughly like below:

 
 1. Create a class to implement BLEConnectionDelegate protocol in UI App
 
 2. BLEConnectionManager.sharedInstance.registerBLEConnectionListener()
 
 3. When UI App launched, please wait for the callback onReadyToConnect()
 
 4. Invoke BLEConnectionManager.sharedInstance.connectBLE()
 
 Then, UI App will get the callback of onBLEConnectFinished()
 
 */
class BLEConnectionManager: NSObject {
    
    /**
     A shared, singleton instance, any operation must using this instance
     */
    static let sharedInstance = BLEConnectionManager()
    private var bleConnectionDelegates = [String: BLEConnectionDelegate]()

    private override init() {
        super.init()
        BLECentralManager.sharedInstance.initCentralManager()
    }
    
    /**
     registerBLEConnectionListener - UI APP have to implement the BLEConnectionDelegate protocol and invoke this function to setup the delegate
     */
    public func registerBLEConnectionListener(name:String ,  delegate: BLEConnectionDelegate) {
        bleConnectionDelegates[name] = delegate
    }
    
    /**
     unregisterBLEConnectionListener - after unregister the delegate, UI APP won't get the callback from framework
     */
    public func unregisterBLEConnectionListener(name:String) {
        bleConnectionDelegates.removeValue(forKey: name)
    }
    
    /**
     Connect BLE device, but please connect BT3.0 in system >> Bluetooth first.
     - parameter timeout: stop to connect BLE device if over timeout. If timeout value is 0, means only stop connect BLE device when the device is connected.
     */
    public func connectBLE(timeout: Double) {
        //2. scan BLE
        if timeout == 0.0 {
            BLECentralManager.sharedInstance.startScanForever()
        } else {
            BLECentralManager.sharedInstance.startScan(timeout: timeout)
        }
    }
    /**
     Disconnect BLE device, after BLE is disconnected, the callback function onBLEDisconnected will be invoked
     */
    public func disconnectBLE() {
        BLECentralManager.sharedInstance.cleanBLEDeviceConnection()
    }

    func cbConnectBLE(result: BLEConnectResult) {
        for delegate in bleConnectionDelegates {
            delegate.1.onBLEConnectFinished(result: result)
        }
    }
    
    func cbReadyToConnect() {
        for delegate in bleConnectionDelegates {
            delegate.1.onReadyToConnect()
        }
    }
    
    func cbDisconnectedBLE() {
        for delegate in bleConnectionDelegates {
            delegate.1.onBLEDisconnected()
        }
    }
    
    func cbSystemBTStateChange(state: SystemBTState) {
        for delegate in bleConnectionDelegates {
            delegate.1.onSystemBTStateChange(state: state)
        }
    }
    
    func cbRSSIValue(rssi: NSNumber) {
        for delegate in bleConnectionDelegates {
            delegate.1.onBLERSSIValue(rssi: rssi)
        }
    }
    
    func bleDeviceScanFinished() {
        for delegate in bleConnectionDelegates {
            delegate.1.onBLEDeviceScanFinished()
        }
    }
}

