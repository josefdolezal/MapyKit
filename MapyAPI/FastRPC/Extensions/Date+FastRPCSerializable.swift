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
        // to minutes (by dividing by 60) and then to hour quartes (by dividing by 15)
        // which for short is dividing by 900
        let timezoneDifference = TimeZone.current.secondsFromGMT() / 900
        // Since timezone difference is always positive, we have to explicitly check
        // whether the timezone is before/after GMT. Advance negative values by 256.
        let timezone = isTimezoneAfterGMT()
            // Advance negative values by 256
            ? 256 - timezoneDifference
            // Keep positive values as is
            : timezoneDifference
        let timestamp = Int(timeIntervalSince1970)

        // Get components
        let year = max(0, min(dateComponents.year! - 1600, 2047))
        let month = dateComponents.month!
        let day = dateComponents.day!
        // Week starts at sunday and it's ordinal number is '1', we want the sunday to be '0'
        let weekday = dateComponents.weekday! - 1
        let hour = dateComponents.hour!
        let minute = dateComponents.minute!
        let second = dateComponents.second!

        // Define data structure
        let bytes = [
            identifier.truncatedBytes(to: 1),
            timezone.truncatedBytes(to: 1),
            timestamp.truncatedBytes(to: 4),
            ((second & 31) << 3 | weekday & 7).truncatedBytes(to: 1),
            ((minute & 63) << 1 | (second & 32) >> 5 | (hour & 1) << 7).truncatedBytes(to: 1),
            ((hour & 30) >> 1 | (day & 15) << 4).truncatedBytes(to: 1),
            ((day & 31) >> 4 | (month & 15) << 1 | (year & 7) << 5).truncatedBytes(to: 1),
            ((year & 2040) >> 3).truncatedBytes(to: 1)
        ]

        // Combine the data into single result
        return bytes.reduce(Data(), +)
    }

    // MARK: Private API

    /// Since there is no easy way to determine whether the current timezome is after
    /// GMT, we use date formatter to obtain timezone in format 'GMT-08:00' or 'GMT+08:00'.
    private static let timezoneFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "ZZZZ"

        return formatter
    }()


    /// Based on date timezone format, determines whether the timezone is located
    /// after GMT.
    ///
    /// - Returns: True if date timezone is located after GMT.
    private func isTimezoneAfterGMT() -> Bool {
        let timezone = Date.timezoneFormatter.string(from: self)

        return timezone.contains("+")
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
