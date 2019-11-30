//
//  TestVC.swift
//  Example
//
//  Created by Josef Dolezal (Admin) on 28/11/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

import UIKit
import FastRPCSwift

final class TestVC: UIViewController, UITextViewDelegate {
    @IBOutlet weak var inputTextField: UITextView!
    @IBOutlet weak var outputTextField: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        inputTextField.delegate = self
    }

    func textViewDidChange(_ textView: UITextView) {

        if let data = Data(base64Encoded: "yhECAWgLc2ltcGxlUm91dGVYA1AFAmlkYAZzb3VyY2UgBGNvb3IIZ2VvbWV0cnkgCjlocFZheFh6YkcLcm91dGVQYXJhbXNQAQljcml0ZXJpb244bwpkZXNjUGFyYW1zUAMKZmV0Y2hQaG90bxEGcmF0aW9zWAEgAzN4MgRsYW5nWAEgAmVuUAUCaWQgJTE0LjY5OTA1NDE3NzQ3NDk0OSw1MC4wOTQ0ODgyMTg3OTY5MjYGc291cmNlIARjb29yCGdlb21ldHJ5IAo5aHA5VXhYenNJC3JvdXRlUGFyYW1zUAEJY3JpdGVyaW9uOG8KZGVzY1BhcmFtc1ADCmZldGNoUGhvdG8RBnJhdGlvc1gBIAMzeDIEbGFuZ1gBIAJlblAEAmlkYAZzb3VyY2UgBGNvb3IIZ2VvbWV0cnkgCjlocHJBeFguVm4KZGVzY1BhcmFtc1ADCmZldGNoUGhvdG8RBnJhdGlvc1gBIAMzeDIEbGFuZ1gBIAJlblABFHRvbGxFeGNsdWRlQ291bnRyaWVzWAA=") {
            do {
                print(try FastRPCSerialization.frpcProcedure(with: data))
            } catch {
                print(error)
            }
        }
    }
}
