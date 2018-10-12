//
//  String+FastRPCSerializableTests.swift
//  MapyAPITests
//
//  Created by Josef Dolezal on 17/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import XCTest
@testable import FastRPCSwift

class String_FastRPCSerializableTests: XCTestCase {
    func testSerializeASCIIStrings() {
        XCTAssertEqual([UInt8](try "ElWEds0SzorqKVX".serialize().data), [32, 15, 69, 108, 87, 69, 100, 115, 48, 83, 122, 111, 114, 113, 75, 86, 88])
        XCTAssertEqual([UInt8](try "XnYPkzsYkgSegLY".serialize().data), [32, 15, 88, 110, 89, 80, 107, 122, 115, 89, 107, 103, 83, 101, 103, 76, 89])
        XCTAssertEqual([UInt8](try "ROJuuXbGclXqVfz".serialize().data), [32, 15, 82, 79, 74, 117, 117, 88, 98, 71, 99, 108, 88, 113, 86, 102, 122])
        XCTAssertEqual([UInt8](try "u3GHIyM3yYFxx1w".serialize().data), [32, 15, 117, 51, 71, 72, 73, 121, 77, 51, 121, 89, 70, 120, 120, 49, 119])
        XCTAssertEqual([UInt8](try "P1u9kT6E4KhrQ05".serialize().data), [32, 15, 80, 49, 117, 57, 107, 84, 54, 69, 52, 75, 104, 114, 81, 48, 53])
        XCTAssertEqual([UInt8](try "26y57aOyBUwgGJG".serialize().data), [32, 15, 50, 54, 121, 53, 55, 97, 79, 121, 66, 85, 119, 103, 71, 74, 71])
        XCTAssertEqual([UInt8](try "QJ24K8gESejp2M8".serialize().data), [32, 15, 81, 74, 50, 52, 75, 56, 103, 69, 83, 101, 106, 112, 50, 77, 56])
        XCTAssertEqual([UInt8](try "xUiN9zU8EIOH774".serialize().data), [32, 15, 120, 85, 105, 78, 57, 122, 85, 56, 69, 73, 79, 72, 55, 55, 52])
        XCTAssertEqual([UInt8](try "0OZE0pNBWrcXRiT".serialize().data), [32, 15, 48, 79, 90, 69, 48, 112, 78, 66, 87, 114, 99, 88, 82, 105, 84])
        XCTAssertEqual([UInt8](try "sFL6Kg8kcFqW2n8".serialize().data), [32, 15, 115, 70, 76, 54, 75, 103, 56, 107, 99, 70, 113, 87, 50, 110, 56])
        XCTAssertEqual([UInt8](try "cPPEG4HBQdEqCU9".serialize().data), [32, 15, 99, 80, 80, 69, 71, 52, 72, 66, 81, 100, 69, 113, 67, 85, 57])
        XCTAssertEqual([UInt8](try "sErPGbpXP2jMjg8".serialize().data), [32, 15, 115, 69, 114, 80, 71, 98, 112, 88, 80, 50, 106, 77, 106, 103, 56])
        XCTAssertEqual([UInt8](try "0k57V9wiRazWxLm".serialize().data), [32, 15, 48, 107, 53, 55, 86, 57, 119, 105, 82, 97, 122, 87, 120, 76, 109])
        XCTAssertEqual([UInt8](try "1KbWO5UAfwpvHNN".serialize().data), [32, 15, 49, 75, 98, 87, 79, 53, 85, 65, 102, 119, 112, 118, 72, 78, 78])
        XCTAssertEqual([UInt8](try "gmk3ZCAuBBSMLcy".serialize().data), [32, 15, 103, 109, 107, 51, 90, 67, 65, 117, 66, 66, 83, 77, 76, 99, 121])
        XCTAssertEqual([UInt8](try "re41Pak8Tx49AQl".serialize().data), [32, 15, 114, 101, 52, 49, 80, 97, 107, 56, 84, 120, 52, 57, 65, 81, 108])
        XCTAssertEqual([UInt8](try "2t7ixlVcAkVWxgh".serialize().data), [32, 15, 50, 116, 55, 105, 120, 108, 86, 99, 65, 107, 86, 87, 120, 103, 104])
        XCTAssertEqual([UInt8](try "vuTkUr4WYGeTy8t".serialize().data), [32, 15, 118, 117, 84, 107, 85, 114, 52, 87, 89, 71, 101, 84, 121, 56, 116])
        XCTAssertEqual([UInt8](try "RYvfbv4TD4T8muV".serialize().data), [32, 15, 82, 89, 118, 102, 98, 118, 52, 84, 68, 52, 84, 56, 109, 117, 86])
        XCTAssertEqual([UInt8](try "hRlYfAaupusTCcn".serialize().data), [32, 15, 104, 82, 108, 89, 102, 65, 97, 117, 112, 117, 115, 84, 67, 99, 110])
    }

    func testSerializeUTF8Strings() {
         XCTAssertEqual([UInt8](try "šü%úÁ$Ů[úďďüňßó".serialize().data), [32, 27, 197, 161, 195, 188, 37, 195, 186, 195, 129, 36, 197, 174, 91, 195, 186, 196, 143, 196, 143, 195, 188, 197, 136, 195, 159, 195, 179])
         XCTAssertEqual([UInt8](try "üčúÝ%čě$ÍŚú%žáß".serialize().data), [32, 27, 195, 188, 196, 141, 195, 186, 195, 157, 37, 196, 141, 196, 155, 36, 195, 141, 197, 154, 195, 186, 37, 197, 190, 195, 161, 195, 159])
         XCTAssertEqual([UInt8](try "Öů'%ČěŮÉŚŚ@}úůÜ".serialize().data), [32, 26, 195, 150, 197, 175, 39, 37, 196, 140, 196, 155, 197, 174, 195, 137, 197, 154, 197, 154, 64, 125, 195, 186, 197, 175, 195, 156])
         XCTAssertEqual([UInt8](try "áŮ@ŽČÚŠÓü}Řß`Ř~".serialize().data), [32, 26, 195, 161, 197, 174, 64, 197, 189, 196, 140, 195, 154, 197, 160, 195, 147, 195, 188, 125, 197, 152, 195, 159, 96, 197, 152, 126])
         XCTAssertEqual([UInt8](try "áťŮÜöŘßř[}í'šŘŮ".serialize().data), [32, 27, 195, 161, 197, 165, 197, 174, 195, 156, 195, 182, 197, 152, 195, 159, 197, 153, 91, 125, 195, 173, 39, 197, 161, 197, 152, 197, 174])
         XCTAssertEqual([UInt8](try "Ü`[@[ÚŽ~~ŚňÚĎěÓ".serialize().data), [32, 24, 195, 156, 96, 91, 64, 91, 195, 154, 197, 189, 126, 126, 197, 154, 197, 136, 195, 154, 196, 142, 196, 155, 195, 147])
         XCTAssertEqual([UInt8](try "ť}ßřýÖÜŮÁüňářéÁ".serialize().data), [32, 29, 197, 165, 125, 195, 159, 197, 153, 195, 189, 195, 150, 195, 156, 197, 174, 195, 129, 195, 188, 197, 136, 195, 161, 197, 153, 195, 169, 195, 129])
         XCTAssertEqual([UInt8](try "ĎčžÜ$ŇěšśšÖřŘčŽ".serialize().data), [32, 29, 196, 142, 196, 141, 197, 190, 195, 156, 36, 197, 135, 196, 155, 197, 161, 197, 155, 197, 161, 195, 150, 197, 153, 197, 152, 196, 141, 197, 189])
         XCTAssertEqual([UInt8](try "áÍŠňüÍß~á{ÖÓóšš".serialize().data), [32, 28, 195, 161, 195, 141, 197, 160, 197, 136, 195, 188, 195, 141, 195, 159, 126, 195, 161, 123, 195, 150, 195, 147, 195, 179, 197, 161, 197, 161])
         XCTAssertEqual([UInt8](try "Ň']ěň~ŤÚ{'ď{áÚ'".serialize().data), [32, 23, 197, 135, 39, 93, 196, 155, 197, 136, 126, 197, 164, 195, 154, 123, 39, 196, 143, 123, 195, 161, 195, 154, 39])
         XCTAssertEqual([UInt8](try "Áěč`í'ýÓů'~Á~éó".serialize().data), [32, 25, 195, 129, 196, 155, 196, 141, 96, 195, 173, 39, 195, 189, 195, 147, 197, 175, 39, 126, 195, 129, 126, 195, 169, 195, 179])
         XCTAssertEqual([UInt8](try "]Ěü\\$}\\Čě]öíÓÍů".serialize().data), [32, 24, 93, 196, 154, 195, 188, 92, 36, 125, 92, 196, 140, 196, 155, 93, 195, 182, 195, 173, 195, 147, 195, 141, 197, 175])
         XCTAssertEqual([UInt8](try "ÚéýŠß[íŤśśŇÚ'řÝ".serialize().data), [32, 28, 195, 154, 195, 169, 195, 189, 197, 160, 195, 159, 91, 195, 173, 197, 164, 197, 155, 197, 155, 197, 135, 195, 154, 39, 197, 153, 195, 157])
         XCTAssertEqual([UInt8](try "Ý$ŘáíéťžŠÍíÁ@ÉĎ".serialize().data), [32, 28, 195, 157, 36, 197, 152, 195, 161, 195, 173, 195, 169, 197, 165, 197, 190, 197, 160, 195, 141, 195, 173, 195, 129, 64, 195, 137, 196, 142])
         XCTAssertEqual([UInt8](try "śÁ][ťĚČÁÜŽěíö@\'\\".serialize().data), [32, 27, 197, 155, 195, 129, 93, 91, 197, 165, 196, 154, 196, 140, 195, 129, 195, 156, 197, 189, 196, 155, 195, 173, 195, 182, 64, 39, 92])
         XCTAssertEqual([UInt8](try "ŘÁĎŘ{čďĎ`ĎďČ$@ś".serialize().data), [32, 26, 197, 152, 195, 129, 196, 142, 197, 152, 123, 196, 141, 196, 143, 196, 142, 96, 196, 142, 196, 143, 196, 140, 36, 64, 197, 155])
         XCTAssertEqual([UInt8](try "áŇüÁÜčůÍŮáś{'šß".serialize().data), [32, 28, 195, 161, 197, 135, 195, 188, 195, 129, 195, 156, 196, 141, 197, 175, 195, 141, 197, 174, 195, 161, 197, 155, 123, 39, 197, 161, 195, 159])
         XCTAssertEqual([UInt8](try "ó~Áíň'ÜŤĎ{śč@öě".serialize().data), [32, 26, 195, 179, 126, 195, 129, 195, 173, 197, 136, 39, 195, 156, 197, 164, 196, 142, 123, 197, 155, 196, 141, 64, 195, 182, 196, 155])
         XCTAssertEqual([UInt8](try "~śř]ň%čÝéŘŮśÍŽÜ".serialize().data), [32, 27, 126, 197, 155, 197, 153, 93, 197, 136, 37, 196, 141, 195, 157, 195, 169, 197, 152, 197, 174, 197, 155, 195, 141, 197, 189, 195, 156])
         XCTAssertEqual([UInt8](try "ÚÖ[\\ů~ýÉůŤťüĚňď".serialize().data), [32, 27, 195, 154, 195, 150, 91, 92, 197, 175, 126, 195, 189, 195, 137, 197, 175, 197, 164, 197, 165, 195, 188, 196, 154, 197, 136, 196, 143])
    }

    func testSerializeRandomStrings() throws {
        for _ in 0...100 {
            let string = String.random(maxLength: Int.random(in: 0...300))
            let stringData = string.data(using: .utf8)!
            var subject = try string.serialize().data

            // Get information of how many bytes are used by string length
            let bytesLength = Int(subject.removeFirst() & 0x07) + 1
            // Get string length
            let length = subject.prefix(bytesLength)
                .enumerated()
                .map { offset, byte in
                    Int(byte) << (8 * offset)
                }
                .reduce(0, +)

            // Remove the string length data
            subject.removeFirst(bytesLength)

            // Test serialized info about string length bytes count
            XCTAssertEqual(bytesLength, stringData.count.usedBytes.count)
            // Test string length
            XCTAssertEqual(length, stringData.count)
            // Test raw bytes itself
            XCTAssertEqual(subject, stringData)
        }
    }
}
