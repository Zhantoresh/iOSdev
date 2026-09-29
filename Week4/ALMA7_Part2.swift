// =============================================================
//  Station ALMA-7, Part II: The Teleporter Incident
//  iOS Mobile Development · Module 4 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part2_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Default to struct. Use class only where the task says so.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Splits a line into fields.
/// fields("crate:101:120")            -> ["crate", "101", "120"]
/// fields("livestock:lab mice:12:2")  -> ["livestock", "lab mice", "12", "2"]
/// fields("junk")                     -> ["junk"]
func fields(_ line: String, separatedBy separator: Character = ":") -> [String] {
    var result: [String] = []
    var current = ""
    for character in line {
        if character == separator {
            result.append(current)
            current = ""
        } else {
            current.append(character)
        }
    }
    result.append(current)
    return result
}

/// Cargo manifest as recovered from the damaged recorder.
let rawManifest = [
    "crate:101:120",
    "container:KZ-ALM-7:340",
    "livestock:lab mice:12:2",
    "???-corrupted-line",
    "crate:102:75",
    "container:KZ-ALM-9:410",
    "livestock:ficus:3:5",
    "crate:103:260",
    "crate:104:abc",
    ""
]

/// Oxygen readings. One of these deck names is not a real deck.
let deckReadings: [(deck: String, oxygen: Int)] = [
    (deck: "bridge",     oxygen: 78),
    (deck: "lab",        oxygen: 64),
    (deck: "greenhouse", oxygen: 55),
    (deck: "cargo",      oxygen: 12),
    (deck: "medbay",     oxygen: 90),
    (deck: "engine",     oxygen: 41)
]

/// Crew records, straight from the personnel file.
let crewData: [(name: String, deck: String, oxygen: Int)] = [
    (name: "Timur",   deck: "engine", oxygen: 62),
    (name: "Dana",    deck: "lab",    oxygen: 48),
    (name: "Aigerim", deck: "bridge", oxygen: 91),
    (name: "Nurlan",  deck: "cargo",  oxygen: 17)
]

print("ALMA-7 recorder online: \(rawManifest.count) manifest lines, \(deckReadings.count) readings, \(crewData.count) crew records.")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each declaration when you start working on it.


// MARK: Level 1 · The Deck Register

// 1.1
enum Deck: String, CaseIterable {
    case bridge, lab, cargo, medbay, engine
    var evacuationPriority: Int{
        switch self{
        case .bridge: return 1
        case .medbay: return 2
        case .lab: return 3
        case .engine: return 4
        case .cargo: return 5
        }
    }
}

for deck in Deck.allCases{
    print(deck, deck.evacuationPriority)
}

// 1.2
enum AlarmLevel: Int {
    case green = 0, yellow, orange, red
    static func level(forTotalMass mass: Int) -> AlarmLevel {
        let steps = mass/500
        let clampedSteps = min(steps, AlarmLevel.red.rawValue)
        guard let level = AlarmLevel(rawValue: clampedSteps) else{
            fatalError("Invalid alarm level")
        }
        return level
    }
}

print(AlarmLevel.level(forTotalMass: 0))    // green
print(AlarmLevel.level(forTotalMass: 940))  // yellow
print(AlarmLevel.level(forTotalMass: 4000)) // red

// MARK: Level 2 · The Manifest

// 2.1
enum ManifestEntry {
    case crate(id: Int, massKg: Int)
    case container(code: String, massKg: Int)
    case livestock(species: String, count: Int, massPerUnitKg:Int)
    case unknown(raw: String)
}

// 2.2
func parseEntry(_ line: String) -> ManifestEntry {
    let parts = fields(line)
    let tag = parts[0]
    switch tag{
    case "crate":
        guard parts.count == 3, let id = Int(parts[1]), let massKg = Int(parts[2]) else{
            return .unknown(raw: line)
        }
        return .crate(id: id, massKg: massKg)
            
    case "container":
        guard parts.count == 3, let massKg = Int(parts[2]) else{
            return .unknown(raw: line)
        }
        return .container(code: parts[1], massKg: massKg)
        
    case "livestock":
        guard parts.count == 4, let count = Int(parts[2]), let massPerUnitKg = Int(parts[3]) else{
            return .unknown(raw: line)
        }
        return .livestock(species: parts[1], count: count, massPerUnitKg: massPerUnitKg)
        
    default:
        return .unknown(raw: line)
    }
}
print(parseEntry("crate:101:120"))
print(parseEntry("container:KZ-ALM-7:340"))
print(parseEntry("livestock:lab mice:12:2"))
print(parseEntry("???-corrupted-line"))
print(parseEntry("crate:104:abc"))
print(parseEntry(""))

// 2.3
func mass(of entry: ManifestEntry) -> Int {
    switch entry{
    case .crate(_, let massKg):
        return massKg
    case .container(_, massKg: let massKg):
        return massKg
    case .livestock(_, let count, let massPerUnitKg):
        return count * massPerUnitKg
    case .unknown(_):
        return 0
    }
}

var totalMass = 0
var unknownCount = 0

for line in rawManifest {
    let entry = parseEntry(line)
    totalMass += mass(of: entry)
    
    switch entry {
    case .unknown:
        unknownCount += 1
    default:
        break
    }
}

print("Total mass: \(totalMass)")
print("Unknown lines: \(unknownCount)")

let A = totalMass


// MARK: Level 3 · Crew Snapshots

// 3.1
struct CrewSnapshot {
    let name: String
    var deck: Deck
    var oxygen: Int
    mutating func breathe(_ amount: Int){
        oxygen = max(oxygen - amount, 0)
    }
    mutating func move(to deck: Deck){
        self.deck = deck
    }
    mutating func reviveInMedbay(){
        self = CrewSnapshot(name: name, deck: .medbay, oxygen: 100)
    }
    static func rookie(named name: String) -> CrewSnapshot{
        let deck = Deck.bridge
        let oxygen = 100
        return CrewSnapshot(name: name, deck: deck, oxygen: oxygen)
    }
}

var dana = CrewSnapshot.rookie(named: "Dana")
print(dana)

dana.breathe(30)
print(dana.oxygen)

dana.move(to: .lab)
print(dana.deck)

dana.reviveInMedbay()
print(dana)

// 3.2
var crewRoster: [CrewSnapshot] = []
for record in crewData{
    guard let deck = Deck(rawValue: record.deck) else {
        print("Unknown deck: \(record.deck) for \(record.name)")
        continue
    }
    crewRoster.append(CrewSnapshot(name: record.name, deck: deck, oxygen: record.oxygen))
}

// 3.3 · Value-semantics demonstration (copy / plain parameter / inout)
let original = CrewSnapshot.rookie(named: "Timur")
var copy = original
copy.breathe(50)

print("1. Copy vs original:")
print("   before: original.oxygen = \(original.oxygen), copy.oxygen = \(copy.oxygen)")
copy.breathe(20)
print("   after:  original.oxygen = \(original.oxygen), copy.oxygen = \(copy.oxygen)")


func tryToChange(_ snapshot: CrewSnapshot) {
    var localCopy = snapshot
    localCopy.breathe(30)
}

let before = CrewSnapshot.rookie(named: "Dana")
print("2. Plain parameter:")
print("   before: \(before.oxygen)")
tryToChange(before)
print("   after:  \(before.oxygen)")

func actuallyChange(_ snapshot: inout CrewSnapshot) {
    snapshot.breathe(30)
}

var beforeInout = CrewSnapshot.rookie(named: "Aigerim")
print("3. inout parameter:")
print("   before: \(beforeInout.oxygen)")
actuallyChange(&beforeInout)
print("   after:  \(beforeInout.oxygen)")

// MARK: Level 4 · The Teleport Pod

// 4.1
final class TeleportPod {
    let id: String
    var chargeLevel: Int
    var occupant: CrewSnapshot?
    init(id: String, chargeLevel: Int) {
        self.id = id
        self.chargeLevel = chargeLevel
        self.occupant = nil
    }
    deinit {
        print("Pod \(id) deinitialized")
    }
    func load(_ crew: CrewSnapshot) -> Bool {
        if occupant != nil || chargeLevel < 20 {
            return false
        }
        occupant = crew
        return true
    }
    func fire() -> CrewSnapshot? {
        guard let currentOccupant = occupant else {
            return nil
        }
        chargeLevel -= 20
        occupant = nil
        return currentOccupant
    }
}

let pod = TeleportPod(id: "P-1", chargeLevel: 100)
let danaForPod = CrewSnapshot.rookie(named: "Dana")

print(pod.load(danaForPod))
print(pod.chargeLevel)
let fired = pod.fire()
print(fired?.name ?? "nobody")
print(pod.chargeLevel)
print(pod.fire() as Any)

// 4.2 · Charge ledger: load+fire three times, then fire an empty pod
func findMember(named name: String, in roster: [CrewSnapshot]) -> CrewSnapshot? {
    var result: CrewSnapshot? = nil
    for member in roster {
        if member.name == name {
            result = member
        }
    }
    return result
}

let podSecond = TeleportPod(id: "P-1", chargeLevel: 100)


guard let timur = findMember(named: "Timur", in: crewRoster) else {
    fatalError("Timur not found")
}
podSecond.load(timur)
podSecond.fire()
print(podSecond.chargeLevel)


guard let danaForLedger = findMember(named: "Dana", in: crewRoster) else {
    fatalError("Dana not found")
}
podSecond.load(danaForLedger)
podSecond.fire()
print(podSecond.chargeLevel)


guard let nurlan = findMember(named: "Nurlan", in: crewRoster) else {
    fatalError("Nurlan not found")
}
podSecond.load(nurlan)
podSecond.fire()
print(podSecond.chargeLevel)


podSecond.fire()
print(podSecond.chargeLevel)

let C = podSecond.chargeLevel


// 4.3 · Reference-semantics demonstration
// Reference semantics: TeleportPod (class)
let podA = TeleportPod(id: "A", chargeLevel: 100)
let podB = podA
podB.chargeLevel = 50
print("podA.chargeLevel: \(podA.chargeLevel)") // 50 — тот же объект, что и podB
print("podB.chargeLevel: \(podB.chargeLevel)") // 50

// Value semantics: CrewSnapshot (struct), для сравнения
var snapshotA = CrewSnapshot.rookie(named: "TestA")
var snapshotB = snapshotA
snapshotB.oxygen = 50
print("snapshotA.oxygen: \(snapshotA.oxygen)") // 100 — независимая копия
print("snapshotB.oxygen: \(snapshotB.oxygen)") // 50

/* Rule demonstrated: assigning a class instance to another variable creates a second reference to the SAME object (changes through either variable are visible through both), while assigning a struct creates an independent COPY (changes through one variable never affect the other). */

// MARK: Level 5 · Station Systems

// 5.1
final class Station {
    let callSign: String
    
    var hullIntegrity: Int {
        willSet {
            print("Hull integrity changing from \(hullIntegrity) to \(newValue)")
        }
        didSet {
            if hullIntegrity > 100 {
                hullIntegrity = 100
            } else if hullIntegrity < 0 {
                hullIntegrity = 0
            }
        }
    }
    
    var oxygenByDeck: [Deck: Int] = [:]
    
    lazy var fullDiagnostics: String = {
        print("Running full scan...")
        return "Diagnostics complete for \(callSign)"
    }()
    
    var totalOxygen: Int {
        var sum = 0
        for value in oxygenByDeck.values {
            sum += value
        }
        return sum
    }
    
    var averageOxygen: Int {
        get {
            return totalOxygen / oxygenByDeck.count
        }
        set {
            for key in oxygenByDeck.keys {
                oxygenByDeck[key] = newValue
            }
        }
    }
    
    init(callSign: String, hullIntegrity: Int) {
        self.callSign = callSign
        self.hullIntegrity = hullIntegrity
        for reading in deckReadings {
            if let deck = Deck(rawValue: reading.deck) {
                oxygenByDeck[deck] = reading.oxygen
            }
        }
    }
}

// 5.2
let station = Station(callSign: "ALMA-7", hullIntegrity: 85)
print(station.oxygenByDeck)
print(station.totalOxygen)
print(station.averageOxygen)

let B = station.averageOxygen

print("Before touching fullDiagnostics")
print(station.fullDiagnostics)
print(station.fullDiagnostics)

// Task 5.2
station.hullIntegrity = 130
print(station.hullIntegrity)

station.hullIntegrity = -40
print(station.hullIntegrity)

station.hullIntegrity = 55
print(station.hullIntegrity)

/* Why the didSet clamp doesn't loop forever:
 Swift's property observers (willSet/didSet) only fire in response to an assignment made from OUTSIDE the observer itself. When didSet assigns a new value back to hullIntegrity (e.g. hullIntegrity = 100), that particular assignment does NOT trigger willSet/didSet again — Swift treats the observer's own internal write as part of the same "already observing" pass, not a new external mutation. If it did re-trigger, clamping to exactly 100 or 0 would be harmless anyway (100 clamped to 100 is still 100), so even in principle there's no infinite loop — but in practice Swift simply doesn't re-invoke the observer for a write happening inside the observer. */



// MARK: Level 6 · Incident Reports
// Three of these compile and are wrong. One does not compile.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
 Report 1:
 var roster = crewRoster
 for var member in roster {
     member.oxygen -= 10
 }
 print(roster[0].oxygen)   // author expected the crew to have lost oxygen

 WHAT THE AUTHOR EXPECTED: that subtracting 10 from member.oxygen inside
 the loop would update the actual elements stored in roster.

 WHAT ACTUALLY HAPPENS: roster[0].oxygen is unchanged — the crew appears
 to have lost no oxygen at all.

 THE RULE: CrewSnapshot is a struct (value type). A for-in loop over an
 array of structs gives you a COPY of each element as the loop variable.
 `member` is a brand-new, independent CrewSnapshot for each iteration —
 mutating it only mutates that local copy, never the original element
 sitting inside `roster`. (In modern Swift, `for var member in roster`
 even produces a compiler warning that `var` here is pointless, since
 the copy is discarded at the end of each iteration anyway.)

 THE FIX: mutate the array by index instead of through a copied loop
 variable:
*/
var roster = crewRoster
for i in 0..<roster.count {
    roster[i].oxygen -= 10
}
print(roster[0].oxygen)

/*
 Report 2:
 let podA = TeleportPod(id: "A", chargeLevel: 100)
 let podB = podA
 podB.chargeLevel = 0
 print(podA.chargeLevel)   // author expected 100

 WHAT THE AUTHOR EXPECTED: that podB is an independent copy of podA, so
 changing podB's charge would leave podA untouched at 100.

 WHAT ACTUALLY HAPPENS: podA.chargeLevel prints 0, not 100.

 THE RULE: TeleportPod is a class (reference type). `let podB = podA`
 does not copy the pod — it copies the REFERENCE, so podA and podB both
 point to the exact same object in memory. Changing chargeLevel through
 either variable changes the one and only underlying instance.

 THE FIX: there isn't a "fix" in the sense of changing this code to make
 podA stay at 100 while still sharing state — that's not possible with a
 class the way this code is structured. If independent copies were
 actually wanted, TeleportPod would need to be a struct, or the author
 needs to construct a second, separate pod instance rather than aliasing
 the first one:
*/
let podA2 = TeleportPod(id: "A", chargeLevel: 100)
let podB2 = TeleportPod(id: "A-copy", chargeLevel: podA2.chargeLevel)
podB2.chargeLevel = 0
print(podA2.chargeLevel) // now correctly stays 100, because these are two separate objects

/*
 Report 3:
 struct Logbook {
     var entries: [String] = []
     func add(_ entry: String) {
         entries.append(entry)
     }
 }

 WHAT THE AUTHOR EXPECTED: that calling add(_:) would append a new entry
 to the entries array.

 WHAT ACTUALLY HAPPENS: this code does not compile at all.

 THE RULE: Logbook is a struct (value type). By default, instance methods
 on a struct cannot modify the struct's own stored properties — self is
 treated as immutable inside an ordinary method. Swift requires the
 `mutating` keyword on any method that needs to change self's properties,
 specifically to make struct mutation visible and intentional at the call
 site (since it also determines whether the method can be called on a
 `let` instance at all).

 THE FIX: mark the method as mutating:
*/
struct Logbook {
    var entries: [String] = []
    mutating func add(_ entry: String) {
        entries.append(entry)
    }
}
var log = Logbook()
log.add("test entry")
print(log.entries)
/*
 Report 4:
 let snapshot = CrewSnapshot.rookie(named: "Dana")
 snapshot.oxygen = 40

 let pod = TeleportPod(id: "B", chargeLevel: 50)
 pod.chargeLevel = 10

 WHAT THE AUTHOR EXPECTED: presumably that neither line would compile,
 or that both would behave the same way, since both variables are
 declared with `let`.

 WHAT ACTUALLY HAPPENS: only ONE of the two lines is an error.
 `snapshot.oxygen = 40` fails to compile. `pod.chargeLevel = 10` compiles
 and runs fine.

 THE RULE — this is the precise distinction the task asks for:
 For a STRUCT, `let` freezes the entire value, property by property —
 the whole struct instance is immutable, so you cannot reassign ANY of
 its var properties once it's declared with let. `snapshot` is a `let`
 CrewSnapshot, so `snapshot.oxygen = 40` is illegal, even though
 `oxygen` itself is declared as `var` inside the struct's definition.

 For a CLASS, `let` only freezes the REFERENCE itself — it prevents you
 from reassigning `pod` to point at a different TeleportPod object
 (`pod = TeleportPod(...)` would be illegal), but it does nothing to
 protect the object's own internal state. Since chargeLevel is declared
 `var` inside the class, and pod still points at the same object the
 whole time, mutating pod.chargeLevel is perfectly legal even though pod
 itself is a `let`.

 THE FIX: to make `snapshot.oxygen = 40` compile, declare snapshot as a
 var instead of let:
*/
var snapshot2 = CrewSnapshot.rookie(named: "Dana")
snapshot2.oxygen = 40 // now legal


// MARK: Level 7 · Sealing the Black Box

// The leaky original:
//
// class FlightRecorder {
//     var entries: [String] = []
//     var isSealed = false
// }
//
// Your sealed version below. One comment per access keyword.

final class FlightRecorder {
    
    /* private: entries can only be read/written from inside FlightRecorder itself — not even other code in this file can touch it directly, so nobody outside can replace or clear the array. */
    private var entries: [String] = []
    
    /* private(set): anyone can READ isSealed from outside, but only code inside FlightRecorder can WRITE to it — so outside code can check the seal status but never flip it back to false. */
    
     private(set) var isSealed = false
    
    /* internal (the default, no keyword needed): entryCount is visible anywhere in this module/app, giving outside code a safe read-only view of how many entries exist, without exposing the array itself. */
    var entryCount: Int {
        entries.count
    }
    
    /* internal: the public way to add an entry. Refuses to add anything once sealed, enforcing the "no writes after sealing" rule. */
    
    func add(_ entry: String) {
        guard !isSealed else {
            print("Cannot add entry: recorder is sealed.")
            return
        }
        entries.append(entry)
    }
    
    /* internal: the public way to seal the recorder. There's no way to un-seal it from outside, since isSealed's setter is private. */
    func seal() {
        isSealed = true
    }
    
    /* fileprivate: visible to any code in this same file (including free functions), but not to code outside the file. This lets a helper function elsewhere in the file build a transcript using the raw entries, without exposing entries itself as public API. */
    fileprivate func rawEntries() -> [String] {
        entries
    }
}

// A free function elsewhere in the file that uses the fileprivate helper:
func auditTranscript(of recorder: FlightRecorder) -> String {
    var transcript = ""
    for entry in recorder.rawEntries() {
        transcript += "- \(entry)\n"
    }
    return transcript
}

let recorder = FlightRecorder()
recorder.add("Launch sequence started")
recorder.seal()


// recorder.entries = []
// error: 'entries' is inaccessible due to 'private' protection level


// recorder.isSealed = false
// error: cannot assign to property: 'isSealed' setter is inaccessible


recorder.add("Trying to sneak in after sealing")
print(recorder.entryCount)

// MARK: Finale · Integrity Code

let D = AlarmLevel.level(forTotalMass: A).rawValue
let integrityCode = "\(A)-\(B)-\(C)-\(D)"
print("INTEGRITY CODE: \(integrityCode)")


// MARK: Bonus

// deinit in TeleportPod, a do-block lifetime experiment, and === identity



print("--- Variant A: with second reference ---")
var secondReference: TeleportPod? = nil

do {
    let podC = TeleportPod(id: "C", chargeLevel: 100)
    secondReference = podC
    print("Inside do block (A)")
}

print("After do block (A) — deinit has NOT fired yet, because secondReference still holds it")
secondReference = nil // now nothing references podC anymore
print("After clearing secondReference — deinit fires HERE")



print("--- Variant B: no second reference ---")
print("Before do block (B)")

do {
    let podD = TeleportPod(id: "D", chargeLevel: 100)
    print("Inside do block (B)")
}
// deinit for podD fires exactly here, on the closing brace above —
// podD was the only reference, and it goes out of scope at this line

print("After do block (B)")

/*
 EXPLANATION — which line does deinit fire on, and why:

 In Variant A, "Pod C deinitialized" does NOT print right after the do
 block closes. Even though podC's own local scope ends at the closing
 brace, `secondReference` (declared outside the do block) was assigned
 to point at the same object, so the reference count on that TeleportPod
 instance is still 1 even after podC itself goes out of scope. The
 object stays alive until secondReference is itself set to nil (or goes
 out of scope) — that's the exact line where "Pod C deinitialized" is
 printed.

 In Variant B, "Pod D deinitialized" prints immediately on the closing
 brace of the do block. podD was the ONLY reference to that object, so
 as soon as it goes out of scope, the reference count drops to 0, and
 Swift's automatic reference counting (ARC) deinitializes the object
 right there — before "After do block (B)" ever prints.

 This demonstrates ARC (Automatic Reference Counting): a class instance
 stays alive for as long as at least one strong reference to it exists,
 regardless of the lexical scope it was originally created in.
*/




func areSamePod(_ a: TeleportPod, _ b: TeleportPod) -> Bool {
    return a === b
}

let podX = TeleportPod(id: "X", chargeLevel: 100)
let podY = podX
let podZ = TeleportPod(id: "X", chargeLevel: 100)

print(areSamePod(podX, podY))
print(areSamePod(podX, podZ))

/*
 Why === cannot be used on CrewSnapshot at all:

 === (and !==) checks REFERENCE identity — whether two variables point
 to the exact same object in memory. This concept only makes sense for
 classes (reference types), where multiple variables genuinely can
 point at one shared instance.

 CrewSnapshot is a struct (value type). Value types don't have an
 "identity" separate from their value at all — every CrewSnapshot
 variable holds its own independent copy of the data. There is no
 underlying shared object for two CrewSnapshot variables to possibly
 be "the same instance" of, so the question "are these the same
 object?" doesn't apply, and Swift's type system simply doesn't offer
 === for struct types — attempting to use it produces a compile error.
 The correct comparison for structs is == (equality of contents), not
 === (identity), and CrewSnapshot would need to conform to Equatable
 for == to work automatically.
*/

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why did CrewSnapshot get an initializer for free and TeleportPod did not?
 In Swift, structs automatically receive a default constructor (memberwise initializer) that includes all declared stored properties.
 Classes (class) never receive such a generated initializer, regardless of whether their properties have default values. The reason is inheritance: a class can have a superclass with its own initialization requirements (e.g. a required call to super.init(...)), so Swift cannot safely guess what a "correct" automatic initializer should look like for every class. Structs, on the other hand, never have a superclass, so their properties can always be flatly listed and safely turned into a memberwise initializer. Because of this, the developer must manually write the init(...) constructor for a class to ensure that all its properties — and any inherited ones — are initialized correctly when creating an object.
 2. What does `mutating` do to self, and why do classes never need it?
 For structures (value types): the mutating keyword gives the method the right to change instance properties. Under the hood, mutating passes self as an inout parameter, which allows the method to actually overwrite the entire instance of the structure with a new value.
 For classes (reference types): methods work with a reference to an object, not with the value itself. Changing the properties of a class changes the data inside an existing heap object, but does not overwrite the reference itself, so the mutating keyword is not required for classes.
 3. In Report 4 both values are `let`. What exactly does `let` freeze for a
    struct, and what does it freeze for a class?
 For struct: let freezes the entire value (including all internal properties, even if they are declared as var). The entire structure becomes immutable.
 For a class: let freezes only the pointer itself. You cannot redirect a variable to another instance of the class, but you can change the internal var properties of the object to which this reference points.
 4. Why must a lazy property be var? When does lazy change behaviour, not
    just performance?
 Why var: The lazy property is initialized not when an object is created, but when it is accessed for the first time. Since the first read modifies the object's state (writes the calculated value to memory), it must be mutable (var).
 Behavior change (not just performance):
 Access closure: Inside the lazy property, you can safely access self and other instance properties, since by the time of the first call, the object has already been fully initialized.
 Side-effects: If the calculation of the lazy property contains logic (for example, print("Running full scan...") or writing to the log), this logic will be executed strictly on the first call, and not when creating the object, which changes the order of code execution.
 5. private vs fileprivate: where in your FlightRecorder would private be
    too strict?
 In the rawEntries() method.
 If the rawEntries() method had been marked private, it could not have been accessed from external functions outside the body of the FlightRecorder class.
 Using fileprivate allowed the auditTranscript(of:) function, located in the same file but outside the class, to safely access the array of records for generating the report, while maintaining protection from access from other project files.
 Bonus. On which line does deinit fire, and why can't === be used on
 CrewSnapshot?
 Where deinit is triggered:
 In Option A: deinit is triggered on the secondReference = nil line. Closing the do block does not destroy the object, since the external secondReference reference holds the reference count (ARC > 0). Reducing the counter to 0 occurs precisely when the link is reset to zero.
 In Option B: deinit is triggered exactly on the closing parenthesis } of the do block, since podD was the only strong reference, and when leaving the scope, the ARC counter immediately becomes 0.
 Why === can't be used for CrewSnapshot:
 The === (identity) operator checks whether two variables point to the same address in memory (referential identity). This applies only to classes. CrewSnapshot is a struct (meaningful type). Structures do not have the concept of a "unique object address" or a shared identity: each variable stores an independent copy of the data. To compare structures, the content equality operator == is used (in accordance with the Equatable protocol).
*/



