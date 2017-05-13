//
//  TasksViewController.swift
//  vapor-todolist
//
//  Created by Louis Tur on 5/13/17.
//
//

import Foundation
import Vapor
import HTTP

final class TasksViewController {
  
  func addRoutes(drop: Droplet) {
    drop.get("task", "all", handler: getAllTasks)
    drop.get("task", Int.self, handler: getById)
  }
  
  func getAllTasks(req: Request) -> ResponseRepresentable {
    return "Get all the damn tasks"
  }
  
  func getById(req: Request, taskId: Int) -> ResponseRepresentable {
    return "The damn Id is now: \(taskId)"
  }
}
