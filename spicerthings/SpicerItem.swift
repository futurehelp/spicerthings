//
//  SpicerItem.swift
//  spicerthings
//
//  Created by futurehelp on 4/18/17.
//  Copyright © 2017 com.untitled.spicerthings. All rights reserved.
//

import Foundation

//  Spicer Model
struct SpicerItem {

    var quote: String
    
    func toAnyObject() -> Any {
        return [
            "quote": quote
        ]
    }
    
}
