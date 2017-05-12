import Vapor

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

drop.get("hello") { request in
  return try JSON(node: [ "message" : "hello world!"])
}

drop.get("names") { request in
  return try JSON(node: ["names" : ["Alex", "Mary", "John"]])
}

// a GET endpoint without an identifier is treated as the root
drop.get("customer") { request in
  let customer = Customer(first: "Louis", last: "Tur")
  return try JSON(node: customer)
}

drop.run()
