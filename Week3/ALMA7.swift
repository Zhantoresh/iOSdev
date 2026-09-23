// =============================================================
//  Station ALMA-7: Rescue Protocol
//  iOS Mobile Development · Module 3 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER CODE section.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • Use the exact function names from the assignment PDF.
// =============================================================


// MARK: - =================== STARTER CODE ===================
// MARK: - Do not modify anything in this section

typealias Reading = (sensor: String, value: Int)

/// Splits a string at the first occurrence of the separator.
/// splitOnce("O2:87", by: ":") -> ("O2", "87")
/// splitOnce("hello", by: ":") -> nil
func splitOnce(_ line: String, by separator: Character) -> (String, String)? {
    guard let index = line.firstIndex(of: separator) else { return nil }
    let left = String(line[..<index])
    let right = String(line[line.index(after: index)...])
    return (left, right)
}

let rawLog = [
    "O2:87", "TEMP:-12", "O2:9x", "PRESS:101", "TEMP:abc", "O2:",
    "RAD:3", "O2:64", ":55", "TEMP:31", "PRESS:98", "O2:71",
    "RAD:-1", "TEMP:4", "PRESS:1o2", "O2:90"
]

class Tank {
    var level: Int
    init(level: Int) { self.level = level }
}

class Module {
    let name: String
    var oxygenTank: Tank?
    init(name: String, oxygenTank: Tank?) {
        self.name = name
        self.oxygenTank = oxygenTank
    }
}

class CrewMember {
    let name: String
    let role: String
    let priority: Int      // 1 = evacuated first
    var module: Module?    // nil = in open space
    init(name: String, role: String, priority: Int, module: Module?) {
        self.name = name
        self.role = role
        self.priority = priority
        self.module = module
    }
}

let lab  = Module(name: "Lab",  oxygenTank: Tank(level: 40))
let hab  = Module(name: "Hab",  oxygenTank: Tank(level: 12))
let dock = Module(name: "Dock", oxygenTank: nil)

let crew = [
    CrewMember(name: "Timur",   role: "Engineer",  priority: 3, module: lab),
    CrewMember(name: "Dana",    role: "Scientist", priority: 4, module: dock),
    CrewMember(name: "Aigerim", role: "Commander", priority: 1, module: hab),
    CrewMember(name: "Nurlan",  role: "Pilot",     priority: 2, module: nil)
]

var roster: [String: CrewMember] = [:]
for member in crew { roster[member.name] = member }

print("ALMA-7 systems online: \(rawLog.count) log lines, \(crew.count) crew members.")

// MARK: - ================= END OF STARTER CODE =================


// MARK: - =================== YOUR SOLUTION ===================
// Uncomment each signature when you start working on it.


// MARK: Level 1 · Decoding Telemetry

// 1.1
func parseReading(_ raw: String) -> Reading? {
    guard let (sensor, valueString) = splitOnce(raw, by: ":"),
          !sensor.isEmpty,
          let value = Int(valueString),
          value>=0 || sensor == "TEMP"
    else{return nil}
    return (sensor, value)
}

print(parseReading("O2:87") as Any)
print(parseReading("RAD:-1") as Any)

// 1.2
func parseLog(_ lines: [String]) -> (valid: [Reading], invalidCount: Int) {
    var validReadings: [Reading] = []
    var invalidCount = 0
    for line in lines{
        if let reading = parseReading(line){
            validReadings.append(reading)
        }
        else {
            invalidCount += 1
        }
    }
    return(validReadings, invalidCount)
    
}

let A = parseLog(rawLog).invalidCount


// MARK: Level 2 · Analysis

// 2.1
func select(_ readings: [Reading], where isIncluded: (Reading) -> Bool) -> [Reading] {
    var selectedReadings: [Reading] = []
    for reading in readings{
        if isIncluded(reading){
            selectedReadings.append(reading)
        }
    }
    return (selectedReadings)
}

func values(of readings: [Reading]) -> [Int] {
    var valuesOfArray: [Int] = []
    for reading in readings {
        valuesOfArray.append(reading.value)
    }
    return valuesOfArray
}

// 2.2
func stats(of values: [Int]) -> (min: Int, max: Int, average: Double)? {
    guard !values.isEmpty else {
        return nil
    }
    var minValue = values[0]
    var maxValue = values[0]
    var sum = 0
    
    for value in values {
        sum += value
        if value < minValue{
            minValue = value
        }
        if value > maxValue{
            maxValue = value
        }
    }
    return (minValue, maxValue, Double(sum)/Double(values.count))
}

func stats(_ values: Int...) -> (min: Int, max: Int, average: Double)? {
    stats(of: values)
}

print(stats(3, 8, 1) as Any)
print(stats() as Any)

let logResult = parseLog(rawLog)
let o2Readings = select(logResult.valid) { $0.sensor == "O2" }
let o2Values = values(of: o2Readings)

guard let o2Stats = stats(of: o2Values) else {
    fatalError("No O2 readings found")
}

let B = Int(o2Stats.average)


// 2.3 · The Closure Ladder (5 sorts, then compare results in code)
let sort1 = logResult.valid.sorted(by: { (a: Reading, b: Reading) -> Bool in
    return a.value > b.value
})

let sort2 = logResult.valid.sorted(by:{ (a,b) in
    return a.value > b.value
})
                                   
let sort3 = logResult.valid.sorted(by: { (a,b) in
    a.value > b.value
})

let sort4 = logResult.valid.sorted(by:{
    $0.value > $1.value}
)

let sort5 = logResult.valid.sorted{$0.value > $1.value}

let values1 = values(of: sort1)
let values2 = values(of: sort2)
let values3 = values(of: sort3)
let values4 = values(of: sort4)
let values5 = values(of: sort5)

let allMatch = values1 == values2 && values2 == values3 && values3 == values4 && values4 == values5
print("All five sorts match: \(allMatch)")

// MARK: Level 3 · Temperature Stabilization

// 3.1
func heatUp(_ t: Int) -> Int {
    return t + 5
}
func coolDown(_ t: Int) -> Int {
    return t - 3
}
func hold(_ t: Int) -> Int {
    return t
}
func chooseProtocol(for temp: Int) -> (Int) -> Int {
    if temp<18 {return heatUp}
    else if temp > 24 {return coolDown}
    else { return hold}
}

print(heatUp(10))
print(coolDown(30))
print(hold(20))
let testProtocol = chooseProtocol(for: 10)
print(testProtocol(10))


// 3.2
func runUntilStable(from start: Int, maxSteps: Int = 10) -> (finalTemp: Int, steps: Int, isStable: Bool) {
    var steps = 0
    var currentTemp = start
    while steps<maxSteps && (currentTemp<18 || currentTemp>24) {
        let protocolFucntion = chooseProtocol(for: currentTemp)
        currentTemp = protocolFucntion(currentTemp)
        steps += 1
    }
    let isStable = currentTemp >= 18 && currentTemp <= 24
    return (currentTemp, steps, isStable)
}

print(runUntilStable(from: 31))
print(runUntilStable(from: -100, maxSteps: 5))

let tempReadings = select(logResult.valid) { $0.sensor == "TEMP" }
let tempValues = values(of: tempReadings)

guard let tempStats = stats(of: tempValues) else {
    fatalError("No TEMP readings found")
}

let C = runUntilStable(from: tempStats.min).steps


// MARK: Level 4 · The Crew

// 4.1
func oxygenLevel(of member: CrewMember) -> Int? {
    member.module?.oxygenTank?.level
}

print(oxygenLevel(of: crew[0]) as Any)
print(oxygenLevel(of: crew[1]) as Any)

// 4.2
func status(of member: CrewMember) -> String {
    guard let module = member.module else {
        return "\(member.name): no data (open space)"
    }
    
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data (\(module.name))"
    }
    
    let condition = level < 20 ? "CRITICAL" : "OK"
    return "\(member.name): \(level)% \(condition)"
}

for member in crew {
    print(status(of: member))
}


// 4.3
// @discardableResult
@discardableResult
func transferOxygen(from source: inout Int, to target: inout Int, amount: Int) -> Int {
    guard amount > 0 else { return 0 }
    
    let availableToGive = min(amount, source)
    let spaceInTarget = 100 - target
    let actualTransfer = min(availableToGive, spaceInTarget)
    
    source -= actualTransfer
    target += actualTransfer
    
    return actualTransfer
}

if var labLevel = lab.oxygenTank?.level, var habLevel = hab.oxygenTank?.level {
    let transferred = transferOxygen(from: &labLevel, to: &habLevel, amount: 30)
    lab.oxygenTank?.level = labLevel
    hab.oxygenTank?.level = habLevel
    print("Transferred: \(transferred)")
}

var testSource = 5
var testTarget = 90
let secondTransfer = transferOxygen(from: &testSource, to: &testTarget, amount: 50)
print("Second transfer: \(secondTransfer), source left: \(testSource), target now: \(testTarget)")


let D = hab.oxygenTank?.level ?? 0
print(D)

// 4.4
func evacuationOrder(_ names: String..., roster: [String: CrewMember]) -> [String] {
    var foundMembers: [CrewMember] = []
    
    for name in names {
        guard let member = roster[name] else {
            print("Unknown crew member: \(name)")
            continue
        }
        foundMembers.append(member)
    }
    
    let sortedMembers = foundMembers.sorted { $0.priority < $1.priority }
    
    var resultNames: [String] = []
    for member in sortedMembers {
        resultNames.append(member.name)
    }
    
    return resultNames
}

print(evacuationOrder("Dana", "Ghost", "Aigerim", "Timur", roster: roster))



print(evacuationOrder("Nurlan", "Timur", roster: roster))

// MARK: Level 5 · The Saboteur's Logbook
// The saboteur's code is below, commented out (it needs your
// oxygenLevel(of:) to compile). Comment on every problem, then
// write fixed versions and a test that proves the logic bug is gone.

/*
func reportOxygen(for member: CrewMember) -> String {
    let tank = member.module!.oxygenTank!
    return "\(member.name): \(tank.level)%"
}

func firstCritical(in crew: [CrewMember]) -> String {
    var result: String?
    for member in crew {
        if oxygenLevel(of: member)! < 20 {
            result = member.name
        }
    }
    return result!
}
*/

/*
 PROBLEM 1: member.module! crashes if a crew member has no module
 (e.g. Nurlan, whose module is nil — he's in open space).

 PROBLEM 2: .oxygenTank! crashes if the module has no tank
 (e.g. Dock, whose oxygenTank is nil).

 Fixed by using oxygenLevel(of:), which safely chains through
 both optionals with optional chaining, then guard let unwraps it.
*/
func reportOxygen(for member: CrewMember) -> String {
    guard let level = oxygenLevel(of: member) else {
        return "\(member.name): no data"
    }
    return "\(member.name): \(level)%"
}

print(reportOxygen(for: crew[0]))
print(reportOxygen(for: crew[3]))

/*
 PROBLEM 3: oxygenLevel(of: member)! crashes whenever oxygenLevel
 returns nil (same cases as above — no module, or module with no tank).

 PROBLEM 4: return result! crashes if no one in crew is critical
 (result stays nil the whole loop).

 PROBLEM 5 (logic bug, not a crash): the loop never stops after
 finding a critical member — it keeps overwriting `result` on every
 match. So if several crew members are critical, the function
 returns the LAST one found, not the FIRST — despite being named
 "firstCritical". This doesn't show up on the starter data because
 only one crew member (Aigerim) is critical there.

 Fixed by returning immediately inside the loop on the first match,
 and returning String? (nil when no one is critical) instead of
 force-unwrapping an empty result.
*/
func firstCritical(in crew: [CrewMember]) -> String? {
    for member in crew {
        if let level = oxygenLevel(of: member), level < 20 {
            return member.name
        }
    }
    return nil
}

let criticalTank1 = Tank(level: 5)
let criticalTank2 = Tank(level: 10)
let criticalModule1 = Module(name: "TestA", oxygenTank: criticalTank1)
let criticalModule2 = Module(name: "TestB", oxygenTank: criticalTank2)

let testCrew = [
    CrewMember(name: "First", role: "Test", priority: 1, module: criticalModule1),
    CrewMember(name: "Second", role: "Test", priority: 2, module: criticalModule2)
]

print(firstCritical(in: testCrew) as Any)


// MARK: Finale · Launch Code

let launchCode = "\(A)-\(B)-\(C)-\(D)"
print("LAUNCH CODE: \(launchCode)")


// MARK: Bonus

func makeAlarm(threshold: Int) -> (Int) -> Bool {
    var count = 0
    return { level in
        if level < threshold {
            count += 1
            print("Alarm #\(count)")
            return true
        }
        return false
    }
}
let alarm = makeAlarm(threshold: 20)
print(alarm(12))
print(alarm(40))
print(alarm(5))

// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. guard let vs if let beyond syntax:
  - guard let requires an unconditional exit from the current scope
    (return, throw, or break) in its else branch if the value is nil.
    This guarantees that once the check passes, the unwrapped variable
    stays available for the rest of the function.

  - if let creates an isolated, nested scope (a {} block), and the
    unwrapped variable is only available inside that block.

  Where if let makes the code noticeably worse:
  When you need to unwrap several optionals in sequence or perform
  multiple checks. With if let you end up with a so-called "Pyramid
  of Doom" — deep, nested indentation.

  Compare, for example, the status function:

  Bad version with if let:

  func status(of member: CrewMember) -> String {
      if let module = member.module {
          if let level = oxygenLevel(of: member) {
              let condition = level < 20 ? "CRITICAL" : "OK"
              return "\(member.name): \(level)% \(condition)"
          } else {
              return "\(member.name): no data (\(module.name))"
          }
      } else {
          return "\(member.name): no data (open space)"
      }
  }

  Good version with guard let (like my actual code):

  func status(of member: CrewMember) -> String {
      guard let module = member.module else {
          return "\(member.name): no data (open space)"
      }
      guard let level = oxygenLevel(of: member) else {
          return "\(member.name): no data (\(module.name))"
      }
      let condition = level < 20 ? "CRITICAL" : "OK"
      return "\(member.name): \(level)% \(condition)"
  }

  With guard let, the code stays flat, reads top to bottom, and handles
  edge cases immediately with early returns.
 

 2. Why can't you pass [Int] to stats(_ values: Int...)?
 
  Because from the caller's point of view, Int... (a variadic parameter)
  and [Int] (an array) are different argument types.

  When a function is declared as stats(_ values: Int...), the compiler
  expects individual elements listed one by one, separated by commas
  (e.g. stats(1, 2, 3)). Swift wraps those elements into an [Int] array
  internally, inside the function body — but at the call site it does
  not automatically "unpack" an existing [Int] array into a variadic
  argument list.

  That's exactly why the code needs two separate functions:
  1. stats(of values: [Int]) — takes an array directly.
  2. stats(_ values: Int...) — takes a comma-separated list of numbers,
     and internally calls stats(of: values).
 

 3. Why doesn't transferOxygen(from: &x, to: &x, amount: 5) compile?

  The code doesn't compile because of Swift's built-in Law of Exclusivity
  (the rule that memory can only be accessed exclusively while mutated).

  When a parameter is passed as inout (using &), the function gets
  exclusive write access to that variable for the whole duration of the
  call. Passing the same variable x into two different inout parameters
  at once would create overlapping ("aliased") access to the same memory
  location.

  What bug this prevents:
  It prevents unexpected mutation and broken logic caused by aliasing.
  In our case, transferring oxygen "from itself to itself" would break
  the math:
  1. source and target would point to the exact same memory location.
  2. The line source -= actualTransfer would immediately also change
     target, since they're the same variable.
  3. The line target += actualTransfer would then overwrite that value
     again, completely breaking the oxygen balance calculation.
 

 4. Why doesn't oxygenLevel(of: dana) ?? "no data" compile?
 
  Because for the nil-coalescing operator (??), the type on the left and
  the type on the right have to match (or the right side has to convert
  to the left side's wrapped type).

  - oxygenLevel(of: dana) returns Int? (an optional Int).
  - "no data" has type String.

  The ?? operator tries to unwrap an Int from the left side, and if it's
  nil, substitute the value on the right instead — but that substituted
  value also has to be an Int, not a String. Swift is strictly typed and
  won't automatically convert Int to String inside ??.

  To make this work, you'd need to first convert the result to a string,
  or handle it explicitly with if let / guard let, for example:

  if let level = oxygenLevel(of: dana) {
      print("\(level)")
  } else {
      print("no data")
  }
 

 5. Full type of chooseProtocol and how to read it:
 
  The full type of chooseProtocol is:

  (Int) -> (Int) -> Int

  How to read it:
  - The function takes one parameter of type Int (the current
    temperature)...
  - ...and returns another function of type (Int) -> Int, which itself
    takes an Int and returns a new Int.

  This works because functions in Swift are first-class citizens — they
  can be passed around, stored, and returned just like any other value.
  That's what lets chooseProtocol return heatUp, coolDown, or hold
  directly as its result.
 

 Bonus. Where does the alarm counter live after makeAlarm returns?
  After makeAlarm finishes running, its local variable count is not
  destroyed — it moves from the stack to the heap.

  How this works:
  Normally, a local variable lives on the stack and is destroyed as
  soon as its function returns. But here, the closure that makeAlarm
  returns captures the variable count by reference. Swift detects this
  capture and automatically allocates a heap object to hold count. That
  variable stays alive in memory for as long as the closure itself
  (e.g. stored in the alarm constant) is still being held somewhere
  in the code.

  Important detail:
  Each separate call to makeAlarm() creates its own, independent
  instance of count on the heap. For example, with two different
  alarms:

  let alarm1 = makeAlarm(threshold: 20)
  let alarm2 = makeAlarm(threshold: 20)

  print(alarm1(10)) // Alarm #1 (alarm1's own counter = 1)
  print(alarm1(10)) // Alarm #2 (alarm1's counter = 2)
  print(alarm2(10)) // Alarm #1 (alarm2 has a separate counter,
                     //           starting fresh at 1)

  alarm1 and alarm2 have completely independent counters, living in
  separate heap locations.

*/







