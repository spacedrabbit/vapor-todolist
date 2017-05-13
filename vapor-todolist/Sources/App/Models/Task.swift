//
//  Task.swift
//  vapor-todolist
//
//  Created by Louis Tur on 5/13/17.
//
//

import Foundation
import Vapor
import HTTP

class Task: StringInitializable {
  var name: String!
  
  required init?(from string: String) throws {
    self.name = string
  }
}
