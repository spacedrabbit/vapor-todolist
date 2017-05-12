import Vapor
import HTTP

class Customer: NodeRepresentable {
  var firstName: String!
  var lastName: String!
  
  init(first: String, last: String) {
    self.firstName = first
    self.lastName = last
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



let drop = Droplet()

// MARK: Basic Routing
drop.get("hello") { request in
  return try JSON(node: [ "message" : "hello world!"])
}

drop.get("names") { request in
  return try JSON(node: ["names" : ["Alex", "Mary", "John"]])
}

// MARK: Returning Custom JSON
// a GET endpoint without an identifier is treated as the root
drop.get("customer") { request in
  let customer = Customer(first: "Louis", last: "Tur")
  return try JSON(node: customer)
}

// MARK: URL Paths
// evaluates to /foo/bar
drop.get("foo", "bar") { request in
  return "foo bar"
}

// MARK: Errors
drop.get("error") { request in
  throw Abort.custom(status: .other(statusCode: 1001, reasonPhrase: "how'd you even get here?"), message: "Go back, it's a trap!")
}

drop.get("vapor") { request in
  return Response(redirect: "error")
}

// MARK: URL Parameters
drop.get("users", ":id") { (request: Request) in
  
  guard let userId: Int = request.parameters["id"]?.int else {
    throw Abort.notFound
  }
  return "User Id: \(userId)"
}

// parameters can also be strongly typed and added to the closure?
drop.get("customer", Int.self) { request, userId in
  return "User Id: \(userId)"
}

// we can even switch up these types
// AND (bonus) it will allow for overloading a route with different typed parameters
drop.get("customer", String.self) { request, userId in
  return "User Id: \(userId)"
}


// MARK: Groups
// Groups logically group routes under a specific parent-level URL path
drop.group("tasks") { groups in
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
drop.post("users") { request in

  guard let firstName = request.json?["first_name"]?.string,
    let lastName = request.json?["last_name"]?.string else {
      throw Abort.badRequest
  }
  
  let newUser = Customer(first: firstName, last: lastName)
  return try JSON(node: newUser)
}


drop.run()
