//
//  TestPrinter.swift
//  Tumbleweed
//
//  Created by Johan Sørensen on 07/04/2017.
//  Copyright © 2017 NRK. All rights reserved.
//

import UIKit

final class OutputBufferingPrinter {
    private(set) var lines: [String] = []

    func print(_ line: String) {
        lines.append(line)
    }

    func reset() {
        lines.removeAll()
    }
}
