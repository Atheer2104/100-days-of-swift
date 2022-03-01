import UIKit

var str = "Hello, playground"

//tuples, fixed in size
var name = (first: "Taylor", last: "Swift")
//diffierent ways of calling them
name.0
name.first

//arrays vs tuples vs sets

//
let address = (house: 555, street: "Taylor Swift Avenue", city: "Nashville")

// for unique values and check for item fast use sets
let set = Set(["aardvark", "astonaut", "azalea"])

//if collections of values is okay with being duplicate and the order matters
let pythons = ["Eric", "Graham", "John", "Terry", "Eric"]

