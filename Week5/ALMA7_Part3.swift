// =============================================================
//  Station ALMA-7, Part III: The Repair Fleet
//  iOS Mobile Development · Module 5 · Lab Assignment
//
//  How to use:
//   • Xcode: File → New → Playground → Blank, replace everything
//     with this file's contents.
//   • Terminal: swift ALMA7_Part3_Starter.swift
//
//  Rules:
//   • Do NOT modify the STARTER DATA section. LegacyBeacon in
//     particular must be reached with an extension, not edited.
//   • `!` (force unwrap) is forbidden: −0.5 points each.
//   • No map / filter / reduce / compactMap.
//   • The Health Rule must exist in exactly ONE place in this file.
// =============================================================


// MARK: - =================== STARTER DATA ===================
// MARK: - Do not modify anything in this section

/// Drone records recovered from the fleet registry.
/// One `kind` does not correspond to any drone type you will build.
let fleetData: [(kind: String, id: String, charge: Int)] = [
    (kind: "welder",  id: "W-1", charge: 80),
    (kind: "scanner", id: "S-1", charge: 45),
    (kind: "cargo",   id: "C-1", charge: 100),
    (kind: "welder",  id: "W-2", charge: 15),
    (kind: "scanner", id: "S-2", charge: 60),
    (kind: "tug",     id: "T-1", charge: 50)
]

/// Hull sensors. These are NOT drones — they never move and never work a shift.
let sensorData: [(id: String, charge: Int)] = [
    (id: "hull-cam", charge: 12),
    (id: "thermal",  charge: 77)
]

/// Hardware from the original station. You may not add anything to this
/// declaration — no methods, no protocols, no properties.
struct LegacyBeacon {
    let name: String
    let signalStrength: Int
}

let beacon = LegacyBeacon(name: "ALMA-BEACON", signalStrength: 8)

print("Fleet registry online: \(fleetData.count) drone records, \(sensorData.count) sensors, beacon \(beacon.name).")

// MARK: - ================= END OF STARTER DATA =================


// MARK: - =================== YOUR SOLUTION ===================


// MARK: Level 1 · The Power Cell

// Why a class and not a struct here?  ->
// A battery is one physical object: the drone and anyone else holding it must see the
// same charge (shared reference); a struct would silently copy it and the copies would drift apart.
final class PowerCell {
    private var charge: Int

    init(charge: Int) {
        self.charge = charge.clamped(to: 0...100)
    }

    func level() -> Int {
        return charge
    }

    func spend(_ amount: Int) -> Bool {
        guard amount > 0, charge >= amount else { return false }
        charge -= amount
        return true
    }

    func recharge(by amount: Int) {
        guard amount > 0 else { return }
        charge = (charge + amount).clamped(to: 0...100)
    }
}

// Encapsulation proof (leave this commented, with the compiler error):
// let cell = PowerCell(charge: 50)
// cell.charge = 100
// error: 'charge' is inaccessible due to 'private' protection level


// MARK: Level 2 · The Fleet

// 2.1  What does `final` on runOnce() buy you?  ->
// `final` guarantees no subclass can change the shift ritual (spend cost -> else 0 -> work):
// subclasses customise only powerCost and performTask(), so no drone can skip paying for its work.
class Drone {
    let id: String
    let cell: PowerCell

    init(id: String, cell: PowerCell) {
        self.id = id
        self.cell = cell
    }

    var powerCost: Int { 10 }                       // overridable

    var statusLine: String {                        // "W-1: 80% ########.."
        return "\(id): \(cell.level())% \(cell.level().powerBar)"
    }

    var canRunAnotherTask: Bool {
        return cell.level() >= powerCost
    }

    func performTask() -> Int { 0 }                 // a bare drone does nothing

    final func runOnce() -> Int {
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

// 2.2
final class WelderDrone: Drone {
    override var powerCost: Int { 25 }
    override func performTask() -> Int { 40 }
    func weldSeam() -> String { "\(id) welded a seam" }
}

class ScannerDrone: Drone {
    override var powerCost: Int { 10 }
    override func performTask() -> Int { 15 }
    override var statusLine: String { super.statusLine + " [scanner]" }
}

final class CargoDrone: Drone {
    override var powerCost: Int { 20 }
    override func performTask() -> Int { 25 }
}

// 2.3
func makeDrone(kind: String, id: String, charge: Int) -> Drone? {
    let cell = PowerCell(charge: charge)
    switch kind {
    case "welder":  return WelderDrone(id: id, cell: cell)
    case "scanner": return ScannerDrone(id: id, cell: cell)
    case "cargo":   return CargoDrone(id: id, cell: cell)
    default:        return nil
    }
}

func buildFleet(from records: [(kind: String, id: String, charge: Int)]) -> [Drone] {
    var result: [Drone] = []
    for record in records {
        if let drone = makeDrone(kind: record.kind, id: record.id, charge: record.charge) {
            result.append(drone)
        } else {
            print("WARNING: skipped record \(record.id) — unknown kind '\(record.kind)'")
        }
    }
    return result
}

let fleet: [Drone] = buildFleet(from: fleetData)
print("Fleet built: \(fleet.count) drones")


// MARK: Level 3 · The Shift

func runShift(_ fleet: [Drone], rounds: Int) -> Int {
    var total = 0
    for _ in 0..<max(rounds, 0) {
        for drone in fleet {
            total += drone.runOnce()
        }
    }
    return total
}

let A = runShift(fleet, rounds: 3)

print("--- After the shift ---")
for drone in fleet {
    print(drone.statusLine)
}

var B = 0
var C = 0
for drone in fleet {
    B += drone.cell.level()
    if drone.canRunAnotherTask { C += 1 }
}
print("Drones with enough charge for one more task: \(C)")


// MARK: Level 4 · Diagnostics

// 4.1
protocol Diagnosable {
    var componentID: String { get }
    var statusCode: Int { get }
    func diagnose() -> String
}

// 4.2
protocol Rechargeable {
    mutating func recharge(by amount: Int)
}

// Why does Drone implement recharge(by:) without `mutating`?  ->
// `mutating` only exists to let a method change `self` of a value type; Drone is a class, and
// calling a method on a reference never changes the reference itself, only the object it points to.
extension Drone: Diagnosable, Rechargeable {
    var componentID: String { id }
    var statusCode: Int { healthCode(forCharge: cell.level()) }

    func recharge(by amount: Int) {
        cell.recharge(by: amount)
    }
}

struct SensorModule: Diagnosable, Rechargeable {
    let id: String
    var chargeLevel: Int

    var componentID: String { id }
    var statusCode: Int { healthCode(forCharge: chargeLevel) }

    mutating func recharge(by amount: Int) {
        guard amount > 0 else { return }
        chargeLevel = (chargeLevel + amount).clamped(to: 0...100)
    }
}

var sensors: [SensorModule] = []
for record in sensorData {
    sensors.append(SensorModule(id: record.id, chargeLevel: record.charge))
}

// 4.3
// Why could [Drone] never have held the sensors?  ->
// A SensorModule is a struct, and structs cannot inherit from Drone, so only a protocol type can hold both.
func diagnosticsReport(_ components: [Diagnosable]) -> String {
    var lines: [String] = []
    for component in components {
        lines.append(component.diagnose())
    }
    return lines.joined(separator: "\n")
}

var components: [Diagnosable] = []
for drone in fleet { components.append(drone) }
for sensor in sensors { components.append(sensor) }

print("--- Diagnostics (drones + sensors) ---")
print(diagnosticsReport(components))


// MARK: Level 5 · Shared Behaviour

// 5.1 · default diagnose() + the single home of the Health Rule
extension Diagnosable {
    func diagnose() -> String {
        return "\(componentID): code \(statusCode)"
    }

    /// THE HEALTH RULE — the only place in the file where the thresholds exist.
    func healthCode(forCharge charge: Int) -> Int {
        if charge < 20 { return 2 }     // critical
        if charge < 50 { return 1 }     // warning
        return 0                        // nominal
    }
}

// 5.2 · the beacon you cannot edit
extension LegacyBeacon: Diagnosable {
    var componentID: String { name }
    var statusCode: Int { healthCode(forCharge: signalStrength) }

    func diagnose() -> String {
        return "[LEGACY HARDWARE] \(name): signal \(signalStrength), code \(statusCode)"
    }
}

components.append(beacon)
print("--- Diagnostics (with legacy beacon) ---")
print(diagnosticsReport(components))

var D = 0
for component in components {
    D += component.statusCode
}

// 5.3
extension Int {
    /// 42 -> "####......" (10 chars, clamped to 0...10)
    var powerBar: String {
        let filled = (self / 10).clamped(to: 0...10)
        return String(repeating: "#", count: filled) + String(repeating: ".", count: 10 - filled)
    }

    /// Shared clamping rule, written once (used by PowerCell, SensorModule and powerBar).
    func clamped(to range: ClosedRange<Int>) -> Int {
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}

print("powerBar check: \(42.powerBar)  \((-5).powerBar)  \(250.powerBar)")


// MARK: Level 6 · Incident Reports
// Two of these do not compile. Two compile and lie.
// For each: expectation, actual behaviour, the language rule, the fix.

/*
// Report 1
class PatchDrone: Drone {
    func performTask() -> Int {
        return 30
    }
}

// Report 2
final class HeavyWelder: WelderDrone {
    override func runOnce() -> Int {
        return 999
    }
}

// Report 3
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
print(first.weldSeam())

// Report 4
protocol Labelled {
    var componentID: String { get }
}

extension Labelled {
    func label() -> String { "generic component" }
}

struct Thruster: Labelled {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [Labelled] = [Thruster(componentID: "T-1")]
print(parts[0].label())
*/

// ---- Report 1 ----
// Expected: a drone that produces 30 work units.
// Actual: DOES NOT COMPILE: "overriding declaration requires an 'override' keyword".
// Rule: a method with the same signature as a superclass method is an override and must say so,
//       so that an accidental override (or a typo that would silently create a new method) is impossible.
// Fix: write `override func performTask() -> Int`.
final class PatchDroneFixed: Drone {
    override func performTask() -> Int { 30 }
}

// ---- Report 2 ----
// Expected: a welder whose shift always yields 999.
// Actual: DOES NOT COMPILE: "inheritance from a final class 'WelderDrone'" (and runOnce() is final too:
//         "instance method overrides a 'final' instance method").
// Rule: `final` forbids subclassing (on a class) and overriding (on a member).
// Fix: do not touch the ritual; subclass Drone and customise only the cost and the work.
final class HeavyWelder: Drone {
    override var powerCost: Int { 40 }
    override func performTask() -> Int { 80 }
}

// ---- Report 3 ----
// Expected: call weldSeam() on the welder stored in the array.
// Actual: DOES NOT COMPILE: "value of type 'Drone' has no member 'weldSeam'".
// Rule: the compiler only knows the static type of the variable (Drone), not the runtime object (WelderDrone).
// Fix: conditional downcast. `as?` returns an optional because the cast can fail
//      (the element might be a ScannerDrone, and then there is no WelderDrone to give back).
let reportFleet: [Drone] = [WelderDrone(id: "W-9", cell: PowerCell(charge: 100))]
let first = reportFleet[0]
if let welder = first as? WelderDrone {
    print(welder.weldSeam())
}

// ---- Report 4 ----
// Expected: "thruster T-1" (the struct's own label()).
// Actual: COMPILES, but prints "generic component".
// Rule: label() is NOT a protocol requirement, only an extension method, so it is dispatched statically.
//       Through a `Labelled`-typed value the compiler only knows the protocol, so it picks the extension's version.
// Fix: ONE line — declare `func label() -> String` inside the protocol so it becomes a requirement
//      (witness table, dynamic dispatch) and the struct's implementation wins.
protocol LabelledFixed {
    var componentID: String { get }
    func label() -> String                  // <- the one line
}

extension LabelledFixed {
    func label() -> String { "generic component" }
}

struct Thruster: LabelledFixed {
    let componentID: String
    func label() -> String { "thruster \(componentID)" }
}

let parts: [LabelledFixed] = [Thruster(componentID: "T-1")]
print(parts[0].label())


// MARK: Finale · Mission Code

let missionCode = "\(A)-\(B)-\(C)-\(D)"
print("MISSION CODE: \(missionCode)")


// MARK: Bonus

// 1. Two ways to forbid using Drone directly
//    a) RUNTIME: check the dynamic type in init:
//         init(id: String, cell: PowerCell) {
//             precondition(type(of: self) != Drone.self, "Drone is abstract: subclass it")
//             ...
//         }
//       `Drone(id:cell:)` compiles, then crashes when executed.
//       (a lighter variant: performTask() { fatalError("subclass must override") })
//    b) COMPILE TIME: the base type is a protocol (below). `Worker(...)` is rejected by the compiler because a
//       protocol has no initializer. (Making Drone's init `fileprivate` also blocks it, but only outside this file.)

// 2. Protocol-based redesign: the base "class" is a protocol + extension, the welder is a struct.
protocol Worker: Diagnosable {
    var id: String { get }
    var cell: PowerCell { get }
    var powerCost: Int { get }
    func performTask() -> Int                       // no default: every Worker MUST provide it
}

extension Worker {
    var componentID: String { id }
    var statusCode: Int { healthCode(forCharge: cell.level()) }

    func runOnce() -> Int {                         // the ritual, written once
        guard cell.spend(powerCost) else { return 0 }
        return performTask()
    }
}

struct WelderUnit: Worker {
    let id: String
    let cell: PowerCell
    var powerCost: Int { 25 }
    func performTask() -> Int { 40 }
}

let demoUnit = WelderUnit(id: "WU-1", cell: PowerCell(charge: 60))
print("Bonus demo: WelderUnit produced \(demoUnit.runOnce()) units, \(demoUnit.diagnose())")

// 3. Comparison:
//    The class design gives a free shared base (stored properties, one init, a `final` ritual) but cannot forbid
//    `Drone()` at compile time, and the hierarchy is single-inheritance only. The protocol design makes "must not use
//    the base directly" a compile-time fact, works with structs/enums and with types we did not write, but cannot
//    store properties by itself and `final` does not exist for protocol extensions (a type can shadow runOnce()).
//    For this station I would pick the protocol design; if drones had to share mutable state (the same PowerCell,
//    a mission log), I would keep classes (or struct + a shared class reference like PowerCell) because value
//    types would copy the state and the copies would diverge.


// MARK: - ================= DEFENSE QUESTIONS =================
/*
 1. Why does a class satisfy a `mutating` protocol requirement without the
    keyword, while a struct must write it?
    A `mutating` requirement means "this method may change self". For a struct self is the value itself, so a
    method that changes it must be marked `mutating` (self is passed as inout). For a class, self is only a
    reference: the method changes the object the reference points to, never the reference, so nothing needs
    `mutating` and a class method simply satisfies the requirement.

 2. One thing inheritance does that protocols cannot, and one thing
    protocols do that inheritance cannot:
    Inheritance: shares stored properties and an initializer (Drone's id and cell) and lets subclasses refine the
    same implementation with override/super. Protocols cannot store data.
    Protocols: unite unrelated types, a class (Drone), a struct (SensorModule) and a type we cannot edit
    (LegacyBeacon, via extension), in one [Diagnosable] array. Inheritance cannot, since structs do not inherit
    and a class has only one superclass.

 3. What does `final` prevent, and what did it protect in runOnce()?
    `final` prevents subclassing (on a class) or overriding (on a method/property). On runOnce() it guarantees
    the shift ritual (spend powerCost, return 0 on failure, else performTask) is identical for every drone, so no
    subclass can skip the payment or produce work for free (Report 2's 999). It also lets the compiler call it directly.

 4. In Report 4, why did the protocol extension's method win?
    label() was not a requirement of the protocol, only a method in its extension, and extension-only methods are
    dispatched statically. The array element type is Labelled, so the compiler binds the call to the extension's
    version and never looks at Thruster's own method. Declaring label() in the protocol turns it into a requirement,
    which is dispatched dynamically through the type's witness table, so the struct's implementation is called.

*/
