//
//  PasswordEvaluator.swift
//  vapor-todolist
//
//  Created by Louis Tur on 5/13/17.
//
//

import Foundation
import Vapor


// TODO: look up the ValidationSuite protocol
class PasswordValidator : ValidationSuite {
  static func validate(input value: String) throws {
    let evaluation = !OnlyAlphanumeric.self && Count.containedIn(low: 5, high: 12)
    try evaluation.validate(input: value)
  }
}
