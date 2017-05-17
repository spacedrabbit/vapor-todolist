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
    drop.put("task", "update", handler: update)
    drop.delete("task", "delete", handler: delete)
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
      //let id = request.json?["id"]?.int, // this is created automatically since it is a unique key
      let taskTitle = request.json?["title"]?.string
    else {
        throw Abort.badRequest
    }
    
    // TODO: look up this sql syntax
    // TODO: how to make it to autoincrement
    guard let _ = try drop.database?.driver.raw("INSERT INTO Tasks (title) VALUES (?)", [taskTitle]) else {
      throw Abort.custom(status: .notAcceptable, message: "Could not insert")
    }
    
    return "Task added"
  }
  
  func update(request: Request) throws -> ResponseRepresentable {
    guard
      let id = request.json?["id"]?.int,
      let taskTitle = request.json?["title"]?.string
    else { throw Abort.badRequest }
    
    guard let _ = try drop.database?.driver.raw("UPDATE Tasks SET title = (?) WHERE taskID = (?)", [taskTitle, id]) else {
      throw Abort.custom(status: .notAcceptable, message: "Could not update record with ID: \(id)")
    }
    
    return try JSON(node: ["success":true])
  }
  
  func delete(request: Request) throws -> ResponseRepresentable {
    
    guard
      let id = request.json?["id"]?.int
    else { throw Abort.badRequest }
    
    guard let record = try drop.database?.driver.raw("SELECT * FROM Tasks WHERE taskID = (?)", [id]) else {
      throw Abort.notFound
    }
    
    guard let verifiedCount = record.array?.count, verifiedCount > 0 else {
      throw Abort.notFound
    }
    
    guard let _ = try drop.database?.driver.raw("DELETE FROM Tasks WHERE taskID = (?)", [id]) else {
      throw Abort.custom(status: .notAcceptable, message: "Could not delete record with ID: \(id)")
    }
    
    return try JSON(node: ["success":true])
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
