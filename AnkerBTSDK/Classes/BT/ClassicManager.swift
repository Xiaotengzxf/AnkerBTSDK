//
//  ClassicManager.swift
//  AnkerBTSDK
//
//  Created by ANKER on 2018/5/4.
//

import UIKit
import AVFoundation

class ClassicManager: NSObject {
    
    private var macAddressList : [Data] = []
    private var classicManagerDelegates : [String: ClassicManagerDelegate] = [:]

    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRouteChange(_:)), name: NSNotification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func registerClassicListener(name: String,  delegate: ClassicManagerDelegate) {
        classicManagerDelegates[name] = delegate
    }
    
    public func unregisterBLEConnectionListener(name:String) {
        classicManagerDelegates.removeValue(forKey: name)
    }
    
    @objc private func handleRouteChange(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let reasonRaw = userInfo[AVAudioSessionRouteChangeReasonKey] as? NSNumber,
            let reason = AVAudioSessionRouteChangeReason(rawValue: reasonRaw.uintValue)
            else {
                NSLog("[BC] Strange... could not get routeChange")
                return
        }
        
        switch reason {
        case .newDeviceAvailable:
            NSLog("[BC] newDeviceAvailable")
        case .oldDeviceUnavailable:
            NSLog("[BC] oldDeviceUnavailable")
        case .routeConfigurationChange:
            NSLog("[BC] routeConfigurationChange \(AVAudioSession.sharedInstance().currentRoute)")
        case .categoryChange:
            NSLog("[BC] categoryChange: \(AVAudioSession.sharedInstance().category)")
        case .unknown :
            NSLog("[BC] unknown")
        case .noSuitableRouteForCategory:
            NSLog("[BC] noSuitableRouteForCategory")
        case .override:
            NSLog("[BC] override")
        case .wakeFromSleep:
            NSLog("[BC] wakeFromSleep")
        }
    }
    
    public func getClassicMACAddr() -> Bool {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord, with: [.allowBluetooth])
            macAddressList.removeAll()
            if let inputs = AVAudioSession.sharedInstance().availableInputs {
                for route in inputs {
                    if route.portType == AVAudioSessionPortBluetoothHFP {
                        let mac = route.uid.replacingOccurrences(of: ":", with: "")
                        let index = mac.index(mac.startIndex, offsetBy: 12)
                        if let data = mac[..<index].lowercased().hexadecimal() {
                            macAddressList.append(Data(data.reversed()))
                        }
                    }
                }
            }
            if macAddressList.count > 0 {
                return true
            }
        } catch {
            
        }
        return false
    }
}
