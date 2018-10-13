//
//  Date+Timezones.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 19/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

internal extension Date {
    /// Since there is no easy way to determine whether the current timezome is after
    /// GMT, we use date formatter to obtain timezone in format 'GMT-08:00' or 'GMT+08:00'.
    internal static let timezoneFormatter: DateFormatter = {
        let formatter = DateFormatter()

        formatter.dateFormat = "ZZZZ"

        return formatter
    }()

    /// Based on date timezone format, determines whether the timezone is located
    /// after GMT.
    ///
    /// - Returns: True if date timezone is located after GMT.
    internal func isTimezoneAfterGMT() -> Bool {
        let timezone = Date.timezoneFormatter.string(from: self)

        return timezone.contains("+")
    }
}
