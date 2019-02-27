//
//  DateMessages.swift
//  Telega
//
//  Created by Roman Kyslyy on 2/26/19.
//  Copyright © 2019 Roman Kyslyy. All rights reserved.
//

import Foundation

class DateMessages {
  let date: String
  var messages = [Message]()
  
  init(date: String) {
    self.date = date
  }
}
