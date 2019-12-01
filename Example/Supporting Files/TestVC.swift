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
        guard
            let data = Data(base64Encoded: textView.text, options: .ignoreUnknownCharacters)
            else {
                return
        }

        do {
            print("Decoding procedure")
            print(try FastRPCSerialization.frpcProcedure(with: data))
        } catch {
            print("Falling back to response")
            do {
                print(try FastRPCSerialization.frpcResponse(with: data))
            } catch {
                print("Falling back to fault")
                do {
                    print(try FastRPCSerialization.frpcFault(with: data))
                } catch {
                    print("error", error)
                }
            }
        }
    }
}
