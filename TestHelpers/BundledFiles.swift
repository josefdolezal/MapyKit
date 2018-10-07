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
        let options = FileManager.DirectoryEnumerationOptions.skipsHiddenFiles

        // Find the tests bundle
        let bundleURL = Bundle(for: type(of: self)).bundleURL
        // Get all files from testing bundle
        return try filemanager.contentsOfDirectory(
            at: bundleURL,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: options
        )
    }
}
