//
//  TasksViewController.swift
//  vapor-todolist
//
//  Created by Louis Tur on 5/13/17.
//
//

import Foundation
import Vapor
import VaporSQLite
import HTTP

// MARK: - Newer Lesson
final class TaskViewController {
  
  // TODO: look into the function signature for handler to explain to the class
  func addRoutes(drop: Droplet) {
    drop.get("task", "all", handler: getAll)
    drop.post("task", "new", handler: create)
  }
  
  func getAll(request: Request) throws -> ResponseRepresentable {
    guard let result = try drop.database?.driver.raw("SELECT * FROM Tasks;") else {
      throw Abort.badRequest
    }
    
    guard let nodes = result.nodeArray else {
      return try JSON(node: [])
    }
    
    let tasks = nodes.flatMap{ Task(node: $0) }
    return try JSON(node: tasks)
  }
  
  func create(request: Request) throws -> ResponseRepresentable {
    
    guard
      let id = request.json?["id"]?.int,
      let taskTitle = request.json?["title"]?.string
    else {
        throw Abort.badRequest
    }
    
    // TODO: look up this sql syntax
    guard let _ = try drop.database?.driver.raw("INSERT INTO Tasks (taskID, title) VALUES (?, ?)", [id, taskTitle]) else {
      throw Abort.custom(status: .notAcceptable, message: "Could not insert")
    }
    
    return "Task added"
  }
  
}










// MARK: - Older lesson -
final class DemoTasksViewController {
  
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
//extension DemoTasksViewController: ResourceRepresentable {
//  func makeResource() -> Resource<Task> {
//    return Resource(index: index, show: show)
//  }
//}
