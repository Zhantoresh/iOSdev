//easy tasks

//1 array creation and access
let fruits = ["orange", "apple", "banana", "cherry", "pineapple"]
print(fruits[2])

//2 set creation and manipulation
var favoriteNumbers: Set = [29, 22, 5, 10, 67, 52, 117]
favoriteNumbers.insert(99)
print(favoriteNumbers)

//3 dictionary creation and access
var programmingLanguages = ["C++": 1979, "Python":1989, "Swift":2014]
print(programmingLanguages["Swift"]!)

//4 array element update
var colors = ["green", "red", "blue", "yellow"]
colors[1] = "pink"
print(colors)

//medium tasks

//1 set intersection
var firstSetOfNumbers: Set<Int> = [1, 2, 3, 4]
var secondSetOfNumbers: Set<Int> = [3, 4, 5, 6]
var intersectedSet = firstSetOfNumbers.intersection(secondSetOfNumbers)
print(intersectedSet)

//2 dictionary update
var scores = ["Almat":5, "Dastan":10, "Birzhan":9]
scores.updateValue(8, forKey: "Almat")
//scores["Almat"] = 8
print(scores)

//3 array merge
var firstListOfFruits = ["apple", "banana"]
var secondListOfFruits = ["cherry", "date"]
var mergedFruits = firstListOfFruits + secondListOfFruits
print(mergedFruits)

//hard tasks

//1 dictionary key addition
var countries = ["Kazakhstan": 20590589, "Germany": 83644258, "Belgium":11867634]
countries["Russia"] = 146119928
print(countries)

//2 set union and subtract
var firstSet: Set<String> = ["cat", "dog"]
var secondSet: Set<String> = ["dog", "mouse"]
var unitedSet = firstSet.union(secondSet)
print(unitedSet)
unitedSet.subtract(secondSet)
print(unitedSet)

//3 nested collection
let studentsWithGrades = ["Alua": [55, 54, 48, 50, 60], "Arman":[55, 58, 59, 51, 47], "Erasyl": [60, 59, 60, 57, 55], "Bekzhan": [52, 54, 56, 60, 51]]
print(studentsWithGrades)
print(studentsWithGrades["Bekzhan"]![1])
