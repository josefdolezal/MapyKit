//
//  Double+FastRPCSerializable.swift
//  MapyAPI
//
//  Created by Josef Dolezal on 16/09/2018.
//  Copyright © 2018 Josef Dolezal. All rights reserved.
//

import Foundation

// b = buffer
// c = content
// d = exponent
// e = value


//for (a = 52; 0 < a; a--)
    //f.push(e % 2 ? 1 : 0), e = Math.floor(e / 2);
//for (a = 11; 0 < a; a--)
    //f.push(d % 2 ? 1 : 0), d = Math.floor(d / 2);
//f.push(c ? 1 : 0);
//for (c = a = 0; f.length;)
    // a += (1 << c) * f.shift()
    // c++
    // if (8 == c)  { b.push(a), c = a = 0 }
//return b


extension Double: FastRPCSerializable {
    // Implementation taken from `JAK.FRPC._encodeDouble` in https://api.mapy.cz/js/api/v5/smap-jak.js?v=4.13.27
    func serialize() throws -> Data {
        var buffer = [Int]()
        var content = 0
        var exponent = 0
        var value = 0
        var finalValue = self

        if isInfinite {
            exponent = 2014
            value = 0
            content = 0 > self ? 1 : 0
        } else if 0 == self {
            value = 0
            exponent = 0
            content = 0
        } else {
            let absolute = abs(finalValue)
            content = 0 > self ? 1 : 0

            if absolute > pow(2, -1022) {
                finalValue = Swift.min(floor(log(absolute)) / log(2), 1023)
                exponent = Int(finalValue) + 1023
                value = Int(absolute * pow(2, 52 - self) - pow(2, 52))
            } else {
                exponent = 0
                value = Int(absolute / pow(2, -1074))
            }
        }


        var data = [Int]()
        var a = 52
        while a > 0 {
            data.append(value % 2)
            value = value / 2
            a -= 1
        }

        a = 11
        while a > 0 {
            data.append(exponent % 2)
            exponent = exponent / 2
            a -= 1
        }

        data.append(content)

        content = 0
        a = 0

        while !data.isEmpty {
            a += (1 << content) * data.removeFirst()
            content += 1

            if content == 8 {
                buffer.append(a)
                content = 0
                a = 0
            }
        }

        return Data(data)
    }
}
