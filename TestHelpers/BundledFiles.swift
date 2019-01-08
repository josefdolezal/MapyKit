//
//  BundledFiles.swift
//  MapyKit
//
//  Created by Josef Dolezal on 07/10/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest

fileprivate class BundleLocator { }

extension XCTest {
    /// Returns list of all visible files located in test bundle.
    func bundledFiles() throws -> [URL] {
        let filemanager = FileManager.default

        // Find the tests bundle
        let bundleURL = Bundle(for: BundleLocator.self).bundleURL
        // Get all files from testing bundle
        let files = filemanager
            .enumerator(at: bundleURL, includingPropertiesForKeys: [.isRegularFileKey], options: .skipsHiddenFiles)?
            .compactMap { $0 as? URL }

        return files ?? []
    }
}

extension Array where Element == URL {
    func matching(_ pattern: String) -> [URL] {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])

        return filter { url in
            let filePath = url.absoluteString
            let matches = regex.numberOfMatches(in: url.absoluteString, options: [], range: NSRange.init(filePath.startIndex..<filePath.endIndex, in: filePath))

            return matches > 0
        }
    }
}
