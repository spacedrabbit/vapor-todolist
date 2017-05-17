import Vapor
import VaporSQLite
import HTTP

let drop = Droplet()
let taskController = TaskViewController()
taskController.addRoutes(drop: drop)

try drop.addProvider(VaporSQLite.Provider)

drop.run()
