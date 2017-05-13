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
//    drop.get("task", Int.self, handler: getById)
  }
  
  // needed for REST
  // this now is used for the /task index route
  func index(_ req: Request) throws -> ResponseRepresentable {
    return "imma index"
  }
  
  // needed for REST
  func show(_ req: Request, task: Task) throws -> ResponseRepresentable {
    return "Show"
  }
  
  
  func getAllTasks(req: Request) -> ResponseRepresentable {
    return "Get all the damn tasks"
  }
  
  func getById(req: Request, taskId: Int) -> ResponseRepresentable {
    return "The damn Id is now: \(taskId)"
  }
  
}

// in order to be a RESTful view controller, you need to implement resourceRepresentable
extension TasksViewController: ResourceRepresentable {
  func makeResource() -> Resource<Task> {
    return Resource(index: index, show: show)
  }
}
