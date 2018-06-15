//
//  Utility.swift
//  Headset
//
//  Created by AirohaTool on 2016/8/10.
//  Copyright © 2016年 jayfang. All rights reserved.
//

import Foundation
import UIKit

class Utility {
    
    static let sharedInstance = Utility()
    
    func lock(obj: AnyObject, blk:() -> ()) {
        objc_sync_enter(obj)
        blk()
        objc_sync_exit(obj)
    }
    
    func NSDataToInt(data:Data) -> Int {
        var value:Int = 0
        (data as NSData).getBytes(&value, length: data.count)
        return value
    }
    
    func NSDataToInt16( data:Data) -> Int16 {
        var value:Int16 = 0
        (data as NSData).getBytes(&value, length: data.count)
        return value
    }
    
    func IntToNSData(data:Int, length:Int) -> Data {
        var dataI: Int = data
        return Data(bytes: &dataI, count: length)
    }
    
    func UIntToData(data:UInt, length:Int) -> Data {
        var dataI: UInt = data
        return Data(bytes: &dataI, count: length)
    }
}

extension Data {
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx ", $0) }.joined()
    }
    func scanValue<T>(start: Int, length: Int) -> T {
        return self.subdata(in: start..<start+length).withUnsafeBytes { $0.pointee }
    }
}

class _QueueItem<T> {
    let value: T!
    var next: _QueueItem?
    
    init(_ newvalue: T?) {
        self.value = newvalue
    }
}

///
/// A standard queue (FIFO - First In First Out). Supports simultaneous adding and removing, but only one item can be added at a time, and only one item can be removed at a time.
///
class Queue<T> {
    
    typealias Element = T
    
    var _front: _QueueItem<Element>
    var _back: _QueueItem<Element>
    
    init () {
        // Insert dummy item. Will disappear when the first item is added.
        _back = _QueueItem(nil)
        _front = _back
    }
    
    /// Add a new item to the back of the queue.
    func enqueue (_ value: Element) {
        _back.next = _QueueItem(value)
        _back = _back.next!
    }
    
    /// Return and remove the item at the front of the queue.
    func dequeue () -> Element? {
        if let newhead = _front.next {
            _front = newhead
            return newhead.value
        } else {
            return nil
        }
    }
    
    func isEmpty() -> Bool {
        return _front === _back
    }
    
    func clear() {
        if isEmpty() {
            return
        }
        
        while let _ = dequeue()  {
            // do something with 'value'.
        }
    }
}

extension NSMutableData {
    func appendUInt8(_ value : UInt8) {
        var val = value
        self.append(&val, length: MemoryLayout.size(ofValue: val))
    }
    
    func appendInt32(_ value : Int32) {
        var val = value.bigEndian
        self.append(&val, length: MemoryLayout.size(ofValue: val))
    }
    
    func appendInt16(_ value : Int16) {
        var val = value.bigEndian
        self.append(&val, length: MemoryLayout.size(ofValue: val))
    }
    
    func appendInt8(_ value : Int8) {
        var val = value
        self.append(&val, length: MemoryLayout.size(ofValue: val))
    }
    
    func appendString(_ value : String) {
        value.withCString {
            self.append($0, length: Int(strlen($0)) + 1)
        }
    }
}

extension String {
    func hexadecimal() -> Data? {
        var data = Data(capacity: count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSMakeRange(0, utf16.count)) { match, flags, stop in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        guard data.count > 0 else { return nil }
        return data
    }
}


