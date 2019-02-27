//
//  Date.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/26/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation

extension Date {
  
  func isToday() -> Bool {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy:MM:dd"
    let result = formatter.string(from: date)
    let todayStr = result.components(separatedBy: " ")[0]
    let target = formatter.string(from: self)
    let targetStr = target.components(separatedBy: " ")[0]
    return todayStr == targetStr
  }
}
