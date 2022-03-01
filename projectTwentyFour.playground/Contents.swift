import UIKit

let string = "This is a test string"
// NSMutableAttributedString is used so we can format the string
// a big diffierence between NSMutableAttributedString and NSAttributedString
let attributedString = NSMutableAttributedString(string: string)

attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedString.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))

// attributes where we can have a line or many kind of attributes toward our string
//NSAttributedString.Key.underlineColor

// can be used to make a string into a clickable link
// can do much more stuff with NSAttributedString
//NSAttributedString.Key.link



/*
let string = "This is a test string"

// attriutes is a dictionary where there are options we
// can set and change we can create attributed that has the id of key of NSAttributedString
// and the value is any
let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]

// here we apply string and attributes
let attributedString = NSAttributedString(string: string    , attributes: attributes)
 */

/*
let input = "Swift is like Objective-C without the C"
input.contains("Swift")

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")

// contains where will call it's closure for every item in our languages array
// and for every item we check if it contains the input or part of it at least
languages.contains(where: input.contains)
*/

/*
let weather = "it's going to rain"
print(weather.capitalized)

extension String {
    var capitalizedFirst: String {
        // getting the first letter and making it uppercased
        // and adding it to our string where we get rid of the first letter
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}*/

/*
let password = "12345"
// hasPrefix is if a string begins with a substring ie parameter
// hasSuffix is if the string ends with a substring
password.hasPrefix("123")
password.hasSuffix("456")

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        // self is refrence to the string that is being used
        // drop is removing letter from the end or begining
        // by giving it how many letter we want to remove
        // also it returns a substring that why are using the String()
        // we convert into a normal string
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}*/



/*
let name = "Taylor"

// you can't really thing of string as array of character
// even is this syntax works
// this will count each letter in string therefor it works
for letter in name {
    print("Give me a \(letter)")
}


// because this syntax won't work
// print the fourth character from name
//print(name[3])

// however this syntax works basically
// from name pull out character, the character is an index inside name
// the index starts at the starts of the string and counts forward by the 3
let letter = name[name.index(name.startIndex, offsetBy: 3)]

extension String {
    // a speciell method that reads arrays, string etc
    subscript(i: Int) -> String {
        // the same as in line twenty
        return String(self[index(startIndex, offsetBy: i)])
    }
    
}

let letter2 = name[3]
*/
