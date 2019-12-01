//
//  LocationCoderTests.swift
//  MapyAPITests
//
//  Created by Josef Dolezal (Admin) on 30/11/2019.
//  Copyright © 2019 Josef Dolezal. All rights reserved.
//

@testable import MapyAPI
import XCTest

final class LocationCoderTests: XCTestCase {
    func testStringifiesEmptySequence() {
        XCTAssertEqual(LocationCoder.stringify([]), "")
    }

    func testStringifiesSingleCoordinate() {
        let subject = LocationCoder.stringify

        XCTAssertEqual(subject([.init(latitude: 50.09362757205963, longitude: 14.696489721536636)]), "9hpVaxXzbG")
        XCTAssertEqual(subject([.init(latitude: 33.46971318125725, longitude: 43.612505346536636)]), "uxCVavzUxs")
        XCTAssertEqual(subject([.init(latitude: 28.886355301826903, longitude: 2.304118126630783)]), "9EcXwvdRJt")
    }

    func testStringifiesCoordinatesCollection() {
        let subject = LocationCoder.stringify
        var locations: [Location] = [
            .init(latitude: 49.98141601681709, longitude: 14.576989263296127),
            .init(latitude: 49.98142138123512, longitude: 14.577042907476425),
            .init(latitude: 49.981432780623436, longitude: 14.577249437570572),
            .init(latitude: 49.981444850564, longitude: 14.577411711215973),
            .init(latitude: 49.98146764934063, longitude: 14.57755520939827),
            .init(latitude: 49.98152531683445, longitude: 14.577689319849014),
            .init(latitude: 49.98160645365715, longitude: 14.577878415584564),
            .init(latitude: 49.981704354286194, longitude: 14.57774430513382),
            .init(latitude: 49.98180292546749, longitude: 14.577805995941162),
            .init(latitude: 49.981849193573, longitude: 14.578247219324112),
            .init(latitude: 49.981871992349625, longitude: 14.578570425510406),
            .init(latitude: 49.98187802731991, longitude: 14.578929841518402),
            .init(latitude: 49.98200476169586, longitude: 14.579243659973145)
        ]
        XCTAssertEqual(subject(locations), "9hY5MxXRiVNgNGOVN66uNO6iNb6d6SOK6uLXOONlOPRH62P7NbQJNHP5Oy")

        locations = [
            .init(latitude: 42.02839605510235, longitude: -1.6619275510311127),
            .init(latitude: 42.02866964042187, longitude: -1.6610652208328247),
            .init(latitude: 42.028202936053276, longitude: -1.660831868648529),
            .init(latitude: 42.02839605510235, longitude: -1.6602297127246857),
            .init(latitude: 42.02863611280918, longitude: -1.6594398021697998),
            .init(latitude: 42.02880308032036, longitude: -1.6589100658893585),
            .init(latitude: 42.028836607933044, longitude: -1.6587933897972107),
            .init(latitude: 42.02887013554573, longitude: -1.6587115824222565),
            .init(latitude: 42.02907666563988, longitude: -1.6579122841358185),
            .init(latitude: 42.02893652021885, longitude: -1.6578224301338196),
            .init(latitude: 42.02897675335407, longitude: -1.6571760177612305),
            .init(latitude: 42.02897675335407, longitude: -1.6570137441158295),
            .init(latitude: 42.028943225741386, longitude: -1.6568970680236816),
            .init(latitude: 42.02887013554573, longitude: -1.6568166017532349),
            .init(latitude: 42.02868305146694, longitude: -1.6567093133926392),
            .init(latitude: 42.0283692330122, longitude: -1.6565296053886414),
            .init(latitude: 42.028296142816544, longitude: -1.6565027832984924),
            .init(latitude: 42.02822908759117, longitude: -1.6564840078353882),
            .init(latitude: 42.02804937958717, longitude: -1.6564665734767914),
            .init(latitude: 42.02796220779419, longitude: -1.6564571857452393),
            .init(latitude: 42.027882412075996, longitude: -1.6564571857452393)
        ]
        XCTAssertEqual(subject(locations), "tw6YHwmEDfVCS8Ol2GTAQ1UKReSIPu6TNoNyNoUQQq6CJmTbNx6uN06TMLNxLP6NIhOEGjNQLPNLLXNKIqNFKzN0LH")
    }

    func testExtractsLocationsFromEmptyString() {
        XCTAssertEqual(LocationCoder.locations(from: ""), [])
    }

    func testExtractsSingleLocation() {
        let subject = LocationCoder.locations

        XCTAssertEqual(subject("9EcXwvdRJt"), [.init(latitude: 28.886355087161064, longitude: 2.304118126630783)])
        XCTAssertEqual(subject("uxCVavzUxs"), [.init(latitude: 33.46971318125725, longitude: 43.612505346536636)])
        XCTAssertEqual(subject("9EcXwvdRJt"), [.init(latitude: 28.886355087161064, longitude: 2.304118126630783)])
    }

    func testExtractsLocationsCollection() {
        let subject = LocationCoder.locations

        var locations: [Location] = [
            .init(latitude: 49.98141601681709, longitude: 14.576989263296127),
            .init(latitude: 49.98142138123512, longitude: 14.577042907476425),
            .init(latitude: 49.981432780623436, longitude: 14.577249437570572),
            .init(latitude: 49.981444850564, longitude: 14.577411711215973),
            .init(latitude: 49.98146764934063, longitude: 14.57755520939827),
            .init(latitude: 49.98152531683445, longitude: 14.577689319849014),
            .init(latitude: 49.98160645365715, longitude: 14.577878415584564),
            .init(latitude: 49.981704354286194, longitude: 14.57774430513382),
            .init(latitude: 49.98180292546749, longitude: 14.577805995941162),
            .init(latitude: 49.981849193573, longitude: 14.578247219324112),
            .init(latitude: 49.981871992349625, longitude: 14.578570425510406),
            .init(latitude: 49.98187802731991, longitude: 14.578929841518402),
            .init(latitude: 49.98200476169586, longitude: 14.579243659973145)
        ]
        XCTAssertEqual(subject("9hY5MxXRiVNgNGOVN66uNO6iNb6d6SOK6uLXOONlOPRH62P7NbQJNHP5Oy"), locations)

        locations = [
            .init(latitude: 42.02839605510235, longitude: -1.6619275510311127),
            .init(latitude: 42.02866964042187, longitude: -1.6610652208328247),
            .init(latitude: 42.028202936053276, longitude: -1.660831868648529),
            .init(latitude: 42.02839605510235, longitude: -1.6602297127246857),
            .init(latitude: 42.02863611280918, longitude: -1.6594398021697998),
            .init(latitude: 42.02880308032036, longitude: -1.6589100658893585),
            .init(latitude: 42.028836607933044, longitude: -1.6587933897972107),
            .init(latitude: 42.02887013554573, longitude: -1.6587115824222565),
            .init(latitude: 42.02907666563988, longitude: -1.6579122841358185),
            .init(latitude: 42.02893652021885, longitude: -1.6578224301338196),
            .init(latitude: 42.02897675335407, longitude: -1.6571760177612305),
            .init(latitude: 42.02897675335407, longitude: -1.6570137441158295),
            .init(latitude: 42.028943225741386, longitude: -1.6568970680236816),
            .init(latitude: 42.02887013554573, longitude: -1.6568166017532349),
            .init(latitude: 42.02868305146694, longitude: -1.6567093133926392),
            .init(latitude: 42.0283692330122, longitude: -1.6565296053886414),
            .init(latitude: 42.028296142816544, longitude: -1.6565027832984924),
            .init(latitude: 42.02822908759117, longitude: -1.6564840078353882),
            .init(latitude: 42.02804937958717, longitude: -1.6564665734767914),
            .init(latitude: 42.02796220779419, longitude: -1.6564571857452393),
            .init(latitude: 42.027882412075996, longitude: -1.6564571857452393)
        ]
        XCTAssertEqual(subject("tw6YHwmEDfVCS8Ol2GTAQ1UKReSIPu6TNoNyNoUQQq6CJmTbNx6uN06TMLNxLP6NIhOEGjNQLPNLLXNKIqNFKzN0LH"), locations)
    }
}
