//
//  Item.swift
//  Runs
//
//  Created by Akshith Vattem on 10/25/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
