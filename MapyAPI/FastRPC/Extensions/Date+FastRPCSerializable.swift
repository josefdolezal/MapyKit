//
//  Date+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 19/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

extension Date: FastRPCSerializable {
    func serialize() throws -> Data {
        let calendar = Calendar.current
        let identifier = FastRPCObejectType.dateTime.identifier
        let dateComponents = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: self)
        // Timezone is represented using hour quarters -> so we convert seconds
        // to minutes (by dividing by 60) and then to hour quartes (by dividing by 4)
        // which for short is dividing by 240
        let timezone = TimeZone.current.secondsFromGMT() / 240
        let timestamp = Int(timeIntervalSince1970)

        // Get components
        let year = max(0, min(dateComponents.year! - 1600, 2047))
        let month = dateComponents.month!
        let day = dateComponents.day!
        let weekday = dateComponents.weekday!
        let hour = dateComponents.hour!
        let minute = dateComponents.minute!
        let second = dateComponents.second!

        // Define data structure
        let bytes = [
            identifier.truncatedBytes(to: 1),
            timezone.truncatedBytes(to: 1),
            timestamp.truncatedBytes(to: 4),
            ((second & 31) << 3 | weekday & 7).truncatedBytes(to: 1),
            ((minute & 63) << 1 | (second & 32) >> 5 | (hour & 1) << 7).truncatedBytes(to: 4),
            ((hour & 30) >> 1 | (day & 15) << 4).truncatedBytes(to: 1),
            ((day & 31) >> 4 | (month & 15) << 1 | (year & 7) << 5).truncatedBytes(to: 1),
            ((year & 2040) >> 3).truncatedBytes(to: 1)
        ]

        // Combine the data into single result
        return bytes.reduce(Data(), +)
    }
}

extension Int {
    var usedBytes: Data {
        var copy = self

        return Data(bytes: &copy, count: copy.nonTrailingBytesCount)
    }

    func truncatedBytes(to length: Int) -> Data {
        let sanitizedLength = Swift.min(length, bitWidth / 8)
        var copy = self

        return Data(bytes: &copy, count: sanitizedLength)
    }
}

extension Data {
    static func + (_ lhs: Data, _ rhs: Data) -> Data {
        var result = lhs

        result.append(rhs)

        return result
    }
}
