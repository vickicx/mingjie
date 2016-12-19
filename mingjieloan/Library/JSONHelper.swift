//
//  JSONHelper.swift
//
//  Created by Baris Sencan on 28/08/2014.
//  Copyright 2014 Baris Sencan
//
//  Distributed under the permissive zlib license
//  Get the latest version from here:
//
//  https://github.com/isair/JSONHelper
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

import Foundation

/// A type of dictionary that only uses strings for keys and can contain any
/// type of object as a value.
public typealias JSONDictionary = [String: AnyObject]

/// Operator for use in deserialization operations.
infix operator <-- { associativity right precedence 150 }

/// Returns nil if given object is of type NSNull.
///
/// - parameter object: Object to convert.
///
/// - returns: nil if object is of type NSNull, else returns the object itself.
private func convertToNilIfNull(_ object: AnyObject?) -> AnyObject? {
    if object is NSNull {
        return nil
    }
    return object
}

// MARK: Primitive Type Deserialization

// For optionals.
public func <-- <T>(property: inout T?, value: AnyObject?) -> T? {
    var newValue: T?
    ""
    if let unwrappedValue: AnyObject = convertToNilIfNull(value) {
        // We unwrapped the given value successfully, try to convert.
        if let convertedValue = unwrappedValue as? T {
            // Convert by just type-casting.
            newValue = convertedValue
        } else {
            // Convert by processing the value first.
            switch property {
            case is Int?:
                if unwrappedValue is String {
                    if let intValue = Int("\(unwrappedValue)") {
                        newValue = intValue as? T
                    }
                }
            case is URL?:
                newValue = URL(string: "\(unwrappedValue)") as? T
            case is Date?:
                if let timestamp = unwrappedValue as? Int {
                    newValue = Date(timeIntervalSince1970: Double(timestamp)) as? T
                } else if let timestamp = unwrappedValue as? Double {
                    newValue = Date(timeIntervalSince1970: timestamp) as? T
                } else if let timestamp = unwrappedValue as? NSNumber {
                    newValue = Date(timeIntervalSince1970: timestamp.doubleValue) as? T
                }
            default:
                break
            }
        }
    }
    property = newValue
    return property
}

// For non-optionals.
public func <-- <T>(property: inout T, value: AnyObject?) -> T {
    var newValue: T?
    newValue <-- value
    if let newValue = newValue { property = newValue }
    return property
}

// Special handling for value and format pair to NSDate conversion.
public func <-- (property: inout Date?, valueAndFormat: (AnyObject?, AnyObject?)) -> Date? {
    var newValue: Date?
    if let dateString = convertToNilIfNull(valueAndFormat.0) as? String {
        if let formatString = convertToNilIfNull(valueAndFormat.1) as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = formatString
            if let newDate = dateFormatter.date(from: dateString) {
                newValue = newDate
            }
        }
    }
    property = newValue
    return property
}

public func <-- (property: inout Date, valueAndFormat: (AnyObject?, AnyObject?)) -> Date {
    var date: Date?
    date <-- valueAndFormat
    if let date = date { property = date }
    return property
}

// MARK: Primitive Array Deserialization

public func <-- (array: inout [String]?, value: AnyObject?) -> [String]? {
    if let stringArray = convertToNilIfNull(value) as? [String] {
        array = stringArray
    } else {
        array = nil
    }
    return array
}

public func <-- (array: inout [String], value: AnyObject?) -> [String] {
    var newValue: [String]?
    newValue <-- value
    if let newValue = newValue { array = newValue }
    return array
}

public func <-- (array: inout [Int]?, value: AnyObject?) -> [Int]? {
    if let intArray = convertToNilIfNull(value) as? [Int] {
        array = intArray
    } else {
        array = nil
    }
    return array
}

public func <-- (array: inout [Int], value: AnyObject?) -> [Int] {
    var newValue: [Int]?
    newValue <-- value
    if let newValue = newValue { array = newValue }
    return array
}

public func <-- (array: inout [Float]?, value: AnyObject?) -> [Float]? {
    if let floatArray = convertToNilIfNull(value) as? [Float] {
        array = floatArray
    } else {
        array = nil
    }
    return array
}

public func <-- (array: inout [Float], value: AnyObject?) -> [Float] {
    var newValue: [Float]?
    newValue <-- value
    if let newValue = newValue { array = newValue }
    return array
}

public func <-- (array: inout [Double]?, value: AnyObject?) -> [Double]? {
    if let doubleArrayDoubleExcitement = convertToNilIfNull(value) as? [Double] {
        array = doubleArrayDoubleExcitement
    } else {
        array = nil
    }
    return array
}

public func <-- (array: inout [Double], value: AnyObject?) -> [Double] {
    var newValue: [Double]?
    newValue <-- value
    if let newValue = newValue { array = newValue }
    return array
}

public func <-- (array: inout [Bool]?, value: AnyObject?) -> [Bool]? {
    if let boolArray = convertToNilIfNull(value) as? [Bool] {
        array = boolArray
    } else {
        array = nil
    }
    return array
}

public func <-- (array: inout [Bool], value: AnyObject?) -> [Bool] {
    var newValue: [Bool]?
    newValue <-- value
    if let newValue = newValue { array = newValue }
    return array
}

public func <-- (array: inout [URL]?, value: AnyObject?) -> [URL]? {
    if let stringURLArray = convertToNilIfNull(value) as? [String] {
        array = [URL]()
        for stringURL in stringURLArray {
            if let url = URL(string: stringURL) {
                array!.append(url)
            }
        }
    } else {
        array = nil
    }
    return array
}

public func <-- (array: inout [URL], value: AnyObject?) -> [URL] {
    var newValue: [URL]?
    newValue <-- value
    if let newValue = newValue { array = newValue }
    return array
}

public func <-- (array: inout [Date]?, valueAndFormat: (AnyObject?, AnyObject?)) -> [Date]? {
    var newValue: [Date]?
    if let dateStringArray = convertToNilIfNull(valueAndFormat.0) as? [String] {
        if let formatString = convertToNilIfNull(valueAndFormat.1) as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = formatString
            newValue = [Date]()
            for dateString in dateStringArray {
                if let date = dateFormatter.date(from: dateString) {
                    newValue!.append(date)
                }
            }
        }
    }
    array = newValue
    return array
}

public func <-- (array: inout [Date], valueAndFormat: (AnyObject?, AnyObject?)) -> [Date] {
    var newValue: [Date]?
    newValue <-- valueAndFormat
    if let newValue = newValue { array = newValue }
    return array
}

public func <-- (array: inout [Date]?, value: AnyObject?) -> [Date]? {
    if let timestamps = convertToNilIfNull(value) as? [AnyObject] {
        array = [Date]()
        for timestamp in timestamps {
            var date: Date?
            date <-- timestamp
            if date != nil { array!.append(date!) }
        }
    } else {
        array = nil
    }
    return array
}

public func <-- (array: inout [Date], value: AnyObject?) -> [Date] {
    var newValue: [Date]?
    newValue <-- value
    if let newValue = newValue { array = newValue }
    return array
}

// MARK: Custom Object Deserialization

public protocol Deserializable {
    init(data: JSONDictionary)
}

public func <-- <T: Deserializable>(instance: inout T?, dataObject: AnyObject?) -> T? {
    if let data = convertToNilIfNull(dataObject) as? JSONDictionary {
        instance = T(data: data)
    } else {
        instance = nil
    }
    return instance
}

public func <-- <T: Deserializable>(instance: inout T, dataObject: AnyObject?) -> T {
    var newInstance: T?
    newInstance <-- dataObject
    if let newInstance = newInstance { instance = newInstance }
    return instance
}

// MARK: Custom Object Array Deserialization

public func <-- <T: Deserializable>(array: inout [T]?, dataObject: AnyObject?) -> [T]? {
    if let dataArray = convertToNilIfNull(dataObject) as? [JSONDictionary] {
        array = [T]()
        for data in dataArray {
            array!.append(T(data: data))
        }
    } else {
        array = nil
    }
    return array
}

public func <-- <T: Deserializable>(array: inout [T], dataObject: AnyObject?) -> [T] {
    var newArray: [T]?
    newArray <-- dataObject
    if let newArray = newArray { array = newArray }
    return array
}

// MARK: Raw Value Representable (Enum) Deserialization

public func <-- <T: RawRepresentable>(property: inout T?, value: AnyObject?) -> T? {
    var newEnumValue: T?
    var newRawEnumValue : T.RawValue?
    newRawEnumValue <-- value
    if let unwrappedNewRawEnumValue = newRawEnumValue, let enumValue = T(rawValue: unwrappedNewRawEnumValue) {
        newEnumValue = enumValue
    }
    property = newEnumValue
    return property
}

// For non-optionals.
public func <-- <T: RawRepresentable>(property: inout T, value: AnyObject?) -> T {
    var newValue: T?
    newValue <-- value
    if let newValue = newValue { property = newValue }
    return property
}

// MARK: JSON String Deserialization

private func dataStringToObject(_ dataString: String) -> AnyObject? {
    var data: Data = dataString.data(using: String.Encoding.utf8)!
    var error: NSError?
    do {
        return try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0))
    } catch _ {
        return nil
    }
}

public func <-- <T: Deserializable>(instance: inout T?, dataString: String) -> T? {
    return instance <-- dataStringToObject(dataString)
}

public func <-- <T: Deserializable>(instance: inout T, dataString: String) -> T {
    return instance <-- dataStringToObject(dataString)
}

public func <-- <T: Deserializable>(array: inout [T]?, dataString: String) -> [T]? {
    return array <-- dataStringToObject(dataString)
}

public func <-- <T: Deserializable>(array: inout [T], dataString: String) -> [T] {
    return array <-- dataStringToObject(dataString)
}


