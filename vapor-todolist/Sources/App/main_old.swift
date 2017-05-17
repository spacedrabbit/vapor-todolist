//
//  main_old.swift
//  vapor-todolist
//
//  Created by Louis Tur on 5/16/17.
//
//

import Vapor
import VaporSQLite
import HTTP

/*
 Note: This file is meant to be used to follow along with the older lessons. 
 
 It is a standalone version and should not be considered (directly) as part of this project
 */

class Customer: NodeRepresentable {
  var customerId: Int!
  var firstName: String!
  var lastName: String!
  
  init(first: String, last: String, id: Int = -1) {
    self.firstName = first
    self.lastName = last
    self.customerId = id
  }
  
  // todo: look up the documentation changes for NodeRepresentable
  // why has this "context" parameter been added
  // note: this can be compared to the JSONable protocol we defined a long time ago
  func makeNode() throws -> Node {
    return try Node(node: ["first_name": self.firstName, "last_name": self.lastName])
  }
  
  func makeNode(context: Context) throws -> Node {
    return try Node(node: self.makeNode(), in: context)
  }
}


// throwing this into a closure to remove errors about top-level declarations
// renames 'drop' -> 'prop' for further clarity
let closure: ()->() = {
  
  let prop = Droplet()
  
  // MARK: Adding in SQlite support and querying for version #
  try prop.addProvider(VaporSQLite.Provider.self)
  prop.get("version") { request in
    let result = try prop.database?.driver.raw("SELECT sqlite_version()")
    return try JSON(node: result)
  }
  
  // MARK: Basic Routing
  prop.get("hello") { request in
    return try JSON(node: [ "message" : "hello world!"])
  }
  
  prop.get("names") { request in
    return try JSON(node: ["names" : ["Alex", "Mary", "John"]])
  }
  
  // MARK: Returning Custom JSON
  // a GET endpoint without an identifier is treated as the root
  prop.get("customer") { request in
    let customer = Customer(first: "Louis", last: "Tur")
    return try JSON(node: customer)
  }
  
  // MARK: URL Paths
  // evaluates to /foo/bar
  prop.get("foo", "bar") { request in
    return "foo bar"
  }
  
  // MARK: Errors
  prop.get("error") { request in
    throw Abort.custom(status: .other(statusCode: 1001, reasonPhrase: "how'd you even get here?"), message: "Go back, it's a trap!")
  }
  
  prop.get("vapor") { request in
    return Response(redirect: "error")
  }
  
  // MARK: URL Parameters
  prop.get("users", ":id") { (request: Request) in
    
    guard let userId: Int = request.parameters["id"]?.int else {
      throw Abort.notFound
    }
    return "User Id: \(userId)"
  }
  
  // parameters can also be strongly typed and added to the closure?
  prop.get("customer", Int.self) { request, userId in
    return "User Id: \(userId)"
  }
  
  // we can even switch up these types
  // AND (bonus) it will allow for overloading a route with different typed parameters
  prop.get("customer", String.self) { request, userId in
    return "User Id: \(userId)"
  }
  
  
  // MARK: Groups
  // Groups logically group routes under a specific parent-level URL path
  prop.group("_tasks") { groups in
    // note: this assumes that the URL will be prefixed with /tasks
    // so having a redirect as "vapor" evaluates as "/tasks/vapor"
    // to use a route outside of this path, you need to give a relative
    // path like "/vapor"
    groups.get("all") { request in
      return Response(redirect: "/vapor")
    }
    
    groups.get("due_soon") { request in
      return Response(redirect: "/names")
      
    }
  }
  
  // MARK: POST Requests
  // You can inspect the request object for query params, header info, body info etc..
  // the way this is tested is via postman, just be sure to set breakpoints ahead of time before you build/run
  prop.post("users") { request in
    
    guard let firstName = request.json?["first_name"]?.string,
      let lastName = request.json?["last_name"]?.string else {
        throw Abort.badRequest
    }
    
    let newUser = Customer(first: firstName, last: lastName)
    return try JSON(node: newUser)
  }
  
  
  // MARK: Inserting into SQLite
  // create an endpoint /customers/create for POST requests
  prop.post("customers", "create") { request in
    
    // look for our keys
    guard let first = request.json?["first_name"]?.string,
      let last = request.json?["last_name"]?.string else {
        throw Abort.badRequest
    }
    
    // raw sends in raw SQL queries... god I hope there is another option
    let result = try prop.database?.driver.raw("INSERT INTO Customer(firstName, lastName) VALUES(?,?)", [first, last])
    // something must be returned. in this case it ends up being an empty array if all goes well.
    // otherwise we'll receive some useful error info to help debug
    return try JSON(node: result)
  }
  
  // MARK: Retrieving from SQLite
  prop.get("customers", "all") { request in
    var customers: [Customer] = []
    
    // this is likely to return a number of results, but even if only 1 it will still get
    // returned as an array
    let result = try prop.database?.driver.raw("SELECT customerId,firstName,lastName FROM Customer;")
    
    guard let nodeArray = result?.nodeArray else {
      return try JSON(node: customers)
    }
    
    for node in nodeArray {
      let customer: Customer = Customer(first: node["firstName"]!.string!, last: node["lastName"]!.string!, id: node["customerId"]!.int!)
      customers.append(customer)
    }
    
    return try JSON(node: customers)
  }
  
  prop.get("customers") { request in
    guard let query = request.query?["name"]?.string else {
      throw Abort.badRequest
    }
    
    let result = try prop.database?.driver.raw("SELECT * from Customer WHERE firstName IS \"\(query)\"")
    return try JSON(node: result)
  }
  
  
  // MARK:  - Validators -
  // MARK: Email
  // you get free email validators built into vapor
  prop.post("register") { request in
    guard let email: Valid<Email> = try request.data["email"]?.validated() else {
      throw Abort.custom(status: .notAcceptable, message: "Your email could not be validated")
    }
    
    return "Validated: \(email)"
  }
  
  // MARK: Unique Items
  prop.post("unique") { request in
    guard let inputCommaSeperated = request.data["input"]?.string else {
      throw Abort.badRequest
    }
    
    // This is saying the return object will be a unique array of string, generically
    // The input expected is a comma-seperated list of values
    let unique: Valid<Unique<[String]>> = try inputCommaSeperated.components(separatedBy: ",").validated()
    return "Validated Unique: \(unique)"
  }
  
  // MARK: Matching Keys
  prop.post("keys") { request in
    
    // "keyCode" here is the key looked for in the json body
    guard let keyCode = request.data["keyCode"]?.string else {
      throw Abort.badRequest
    }
    
    // we're validation on the value of keyCode against "Secret!!!"
    let key: Valid<Matches<String>> = try keyCode.validated(by: Matches("Secret!!!"))
    return "Validated \(key)"
  }
  
  
  // MARK: - Custom Validators
  prop.post("register") { request in
    guard let inputPassword = request.data["password"]?.string else {
      throw Abort.badRequest
    }
    
    // between 5-12 and not just alpha numeric (so, with special characters)
    //  let password = try inputPassword.validated(by: !OnlyAlphanumeric.self &&
    //                                                  Count.containedIn(low: 5, high: 12))
    
    //  let password: Valid<PasswordValidator> = try inputPassword.validated(by: PasswordValidator.self)
    
    // TODO: how does this work by simply calling .validated and saying the Valid object will be of type PasswordValidator
    let password: Valid<PasswordValidator> = try inputPassword.validated()
    
    // these two will return bools
    let passwordIsValid = inputPassword.passes(PasswordValidator.self)
    let isValid = try inputPassword.tested(by: PasswordValidator.self)
    
    return "Validated password: \(password)"
  }
  
  // MARK: - RandomUser
  prop.get("random_user") { request in
    
    let response = try prop.client.get("https://randomuser.me/api")
    
    guard let responseData = response.data["results"]?.array?[0] as? JSON else {
      throw Abort.badRequest
    }
    
    return responseData
  }
  
  // MARK: - Controllers -
  
  // "registering" this router
  // because this singleton obj can check its routes, this "registering" is really just
  // defering the prop.get code to another location.
  let controller = DemoTasksViewController()
  controller.addRoutes(drop: prop)
  
  // MARK: RESTful Controller
  //prop.resource("task", controller)
  prop.run()
  
} as! () -> ()

