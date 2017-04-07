//
//  TestPrinter.swift
//  Tumbleweed
//
//  Created by Johan Sørensen on 07/04/2017.
//  Copyright © 2017 NRK. All rights reserved.
//

import UIKit

final class OutputBufferingPrinter {
    private(set) var output = ""

    func print(_ line: String) {
        output.append(line)
    }

    func reset() {
        output = ""
    }
}
