//
//  BLECentralManager.swift
//  BLEConnection
//
//  Created by Tool Airoha on 2017/7/26.
//  Copyright © 2017年 Tool Airoha. All rights reserved.
//

import Foundation
import CoreBluetooth
import AVFoundation

class BLECentralManager: NSObject, CBCentralManagerDelegate {
    
    static let sharedInstance = BLECentralManager()
    let option = BTOption()
    //member var
    fileprivate var _centralManager: CBCentralManager!
    var toConnectPer : CBPeripheral? = nil
    var connectedPer : CBPeripheral? = nil
    var scanTimeoutTimer: Timer?
    var connectPerTimer: Timer?
    var createScanTimerCount = 0 // 搜索定时器技术
    var createScanTimerTime = 0
    
    
    override init(){
        super.init()
    }
    
    deinit {
        if self.toConnectPer != nil {
            _centralManager.cancelPeripheralConnection(self.toConnectPer!)
            self.toConnectPer = nil
        }
        if self.connectedPer != nil {
            _centralManager.cancelPeripheralConnection(self.connectedPer!)
            self.connectedPer = nil
        }
        if self.connectPerTimer != nil {
            self.connectPerTimer?.invalidate()
            self.connectPerTimer = nil
        }
    }
    
    func initCentralManager() {
        if( _centralManager == nil ){
            _centralManager = CBCentralManager(delegate: self, queue: nil, options: [CBCentralManagerOptionRestoreIdentifierKey:"JouzBLEConnection.Restore.Identifier"])
        }
    }
 
    // CBCentralManagerDelegate
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            cleanBLEDeviceConnection()
            BLEConnectionManager.sharedInstance.cbSystemBTStateChange(state: .unknown)
            break
        case .resetting:
            cleanBLEDeviceConnection()
            BLEConnectionManager.sharedInstance.cbSystemBTStateChange(state: .resetting)
            break
        case .unsupported:
            cleanBLEDeviceConnection()
            BLEConnectionManager.sharedInstance.cbSystemBTStateChange(state: .unsupported)
            break
        case .unauthorized:
            cleanBLEDeviceConnection()
            BLEConnectionManager.sharedInstance.cbSystemBTStateChange(state: .unauthorized)
            break
        case .poweredOff:
            cleanBLEDeviceConnection()
            BLEConnectionManager.sharedInstance.cbSystemBTStateChange(state: .poweredOff)
            break
        case .poweredOn:
            BLEConnectionManager.sharedInstance.cbSystemBTStateChange(state: .poweredOn)
            checkBLEConnection()
            break
        }
    }
    
    func cleanBLEDeviceConnection() {
        if self.connectedPer != nil {
            _centralManager.cancelPeripheralConnection(self.connectedPer!)
            self.connectedPer = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if peripheral.name == nil {
            return
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        stopScan()
        if peripheral.name != nil {
            //log.info("[BC] didConnect \(peripheral.name!)")
        }
        BLEConnectionManager.sharedInstance.cbConnectBLE(result: .success)
        self.connectedPer = peripheral
        
        if self.connectPerTimer != nil {
            self.connectPerTimer?.invalidate()
            self.connectPerTimer = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //log.info("[BC] didFailToConnect \(error.debugDescription)")
        BLEConnectionManager.sharedInstance.cbConnectBLE(result: .connectFail)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if peripheral.name != nil  {
            //log.info("[BC] didDisconnectPeripheral \(peripheral.name!)")
        }
        self.toConnectPer = nil
        self.connectedPer = nil
        if connectPerTimer != nil {
            self.connectPerTimer?.invalidate()
            self.connectPerTimer = nil
        } else {
            BLEConnectionManager.sharedInstance.cbDisconnectedBLE()
        }
    }
    
    @objc func connectPerCheck(t: Timer) {
        if self.connectedPer == nil {
            if let per = self.toConnectPer {
                _centralManager.cancelPeripheralConnection(per)
                BLEConnectionManager.sharedInstance.cbConnectBLE(result: .timeout)
            }
        }
    }
    
    func stopScan() {
        stopScanTimer()
        _centralManager.stopScan()
    }
    
    @objc func timeoutToStop() {
        createScanTimerCount += 1
        if createScanTimerCount < createScanTimerTime / 2 {
            //if JouzModel.sharedInstance.bleDevices.count == 0 {
                _centralManager.stopScan()
                _centralManager.scanForPeripherals(withServices: nil)
                return
            //}
        } else {
            createScanTimerCount = 0
            stopScan()
            BLEConnectionManager.sharedInstance.bleDeviceScanFinished()
        }
    }
    
    func createScanTimer() {
        if self.scanTimeoutTimer == nil {
            self.stopScanTimer()
            createScanTimerCount = 0
            self.scanTimeoutTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(BLECentralManager.sharedInstance.timeoutToStop), userInfo: nil, repeats: true)
            
            //log.info("[BC] createScanTimer")
        }
    }
    
    func stopScanTimer() {
        if self.scanTimeoutTimer != nil {
            //log.info("[BC] stopScanTimer")
            self.scanTimeoutTimer?.invalidate()
            self.scanTimeoutTimer = nil
        }
    }
    
    func startScan(timeout: Double) {
        if _centralManager.state != .poweredOn {
            //log.info("[BC] BT POWER is not on")
            return
        }
        stopScan()
        
        checkBLEConnection()
        
        let cmdUUID = CBUUID(string: option.serviceUUID)
        _centralManager.scanForPeripherals(withServices: [cmdUUID])
        stopScanTimer()
        createScanTimerTime = Int(timeout)
        createScanTimer()
    }
    
    func startScanForever() {

    }
    
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        if let peripherals: [CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            for peri in peripherals {
                if _centralManager.state == .poweredOn {
                    self.toConnectPer = peri
                    _centralManager.connect(self.toConnectPer!, options: nil)
                }
            }
        }else {
        }
    }
    
    private func checkBLEConnection() {
        if !tryToConnectedPeripheral() {
        }
    }
    
    // 尝试连接已经连接的特定蓝牙
    private func tryToConnectedPeripheral() -> Bool {
        let cmdUUID = CBUUID(string: option.serviceUUID)
        let perList = _centralManager.retrieveConnectedPeripherals(withServices: [cmdUUID])
        var bValue = false
        for peri in perList {
            self.toConnectPer = peri
            _centralManager.connect(self.toConnectPer!, options: nil)
            bValue = true
            break
        }
        return bValue
    }
    
    func connectToPeripheral(per: CBPeripheral, isMaster: Bool = true) {
        if isMaster {
            self.toConnectPer = per
            _centralManager.connect(self.toConnectPer!, options: nil)
        }
        
        if connectPerTimer != nil {
            connectPerTimer?.invalidate()
            connectPerTimer = nil
        }
        
        connectPerTimer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(connectPerCheck(t:)), userInfo: nil, repeats: false)
        RunLoop.main.add(connectPerTimer!, forMode: .commonModes)
    }
}

extension Data {
    func hexEncodedStringNoBlank() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

