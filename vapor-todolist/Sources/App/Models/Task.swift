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

class Task: NodeRepresentable {
  var taskId: Int!
  var title: String!
  
  func makeNode(context: Context) throws -> Node {
    return try Node(node: ["taskId":self.taskId, "title": self.title])
  }
}


extension Task {
  convenience init?(node: Node) {
    self.init()
    
    guard
      let taskId = node["taskID"]?.int,
      let title = node["title"]?.string
    else {
        return nil
    }
    
    self.taskId = taskId
    self.title = title
  }
}
