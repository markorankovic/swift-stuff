

class Person {

    let name: String
    var balance: Int {
        willSet {
            print("\(name) has \(newValue)")
        }
    }
    
    init(name: String, balance: Int) {
        self.name = name
        self.balance = balance
    }
    
}

protocol Withdraws {
    func withdraw(amount: Int, from person: Person) -> Bool
}

class Note: Hashable {
    
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.moneyValue == rhs.moneyValue
    }
    
    let valueName: String
    let moneyValue: Int
    
    init(valueName: String, value: Int) {
        self.valueName = valueName
        self.moneyValue = value
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(valueName)
        hasher.combine(moneyValue)
    }
    
}

class Atm: Withdraws, CustomStringConvertible {
    
    private let notes: [Note]
    
    init(_ notes: [Note]) {
        self.notes = notes
    }
    
    var description: String {
        var notesList = ""
        for note in notes {
            notesList += "\(note.valueName), "
        }
        return "Atm with \(notesList)"
    }
    
    private func getNotesForAmount(amount: Int) -> [Note : Int] {
        var notesDict: [Note : Int] = [:]
        
        var amount = amount
        
        for note in self.notes.sorted(by: { $0.moneyValue > $1.moneyValue }) {
            notesDict[note] = amount / note.moneyValue
            amount = amount % note.moneyValue
        }
        
        return notesDict
    }
    
    private func getNotesInString(notesDict: [Note : Int]) -> String {
        var str = ""
        
        for note in notesDict.sorted(by: { $0.key.moneyValue > $1.key.moneyValue }) {
            guard note.value != 0 else {
                continue
            }
            note.value
            str += "\(note.value) \(note.key.valueName) "
        }
        
        return str
    }
    
    func withdraw(amount: Int, from person: Person) -> Bool {
        guard person.balance >= amount else {
            print("\(person.name) does not have enough credit")
            return false
        }
        
        let notesDict = getNotesForAmount(amount: amount)
        
        let notesInString = getNotesInString(notesDict: notesDict)
        
        print("Withdrawing \(notesInString)from \(person.name)")
        let outgoingCash = notesDict.map{ $0.value * $0.key.moneyValue }.reduce(0, +)
        person.balance -= outgoingCash
        return true
    }
    
}

let atm1 = Atm([
        Note(valueName: "tens", value: 10),
        Note(valueName: "hundreds", value: 100),
        Note(valueName: "fifties", value: 50),
        Note(valueName: "fives", value: 5),
        Note(valueName: "ones", value: 1),
        Note(valueName: "thousands", value: 1000)
    ])

let atm2 = Atm([
        Note(valueName: "ones", value: 1),
        Note(valueName: "twos", value: 2),
        Note(valueName: "fours", value: 4),
        Note(valueName: "eights", value: 8),
        Note(valueName: "sixteens", value: 16),
        Note(valueName: "thirty-twos", value: 32),
        Note(valueName: "sixty-fours", value: 64)
    ])

let jordan = Person(name: "Jordan", balance: 2301)

atm1.withdraw(amount: 116, from: jordan)

jordan.balance += 116

atm2.withdraw(amount: 116, from: jordan)

print(atm1)
print(atm2)

jordan.balance
