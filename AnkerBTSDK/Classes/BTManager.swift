//
//  BTManager.swift
//  AnkerBTSDK
//
//  Created by ANKER on 2018/4/27.
//

import UIKit

public class BTManager: NSObject {
    
    public static let sharedInstance = BTManager()
    //private var classicManager: ClassicManager?
    //private let bleConnectManager = BLEConnectionManager.sharedInstance
    
    var option = BTOption() {
        didSet {
            if !option.bUseSDKOnlyForBLE {
                //classicManager = ClassicManager()
            }
        }
    }
    
    // MARK: - register
    
    
    
    // MARK: - Classic
    
    
    
    // MARK: - BLE
    
    /// 连接
    ///
    /// - Parameter timeout: 扫描时间，0表示不限时间
    public func scanBLE(timeout: Double) {
        
    }
}
