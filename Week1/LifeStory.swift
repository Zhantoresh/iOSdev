
let firstName = "Zhantore"
let lastName = "Orazymbetov"
let currentYear = 2026
let birthYear = 2006
let age = currentYear - birthYear
let isStudent = true
let height = 1.66
let university = "KBTU"
let yearOfStudy = 4
let bachelorDegreeYear = 2023
let faculty = "School of Information Technology and Engineering"
let specialty = "Information Systems"
let hometown = "Almaty"
let nation = "kazakh"
let numberOfLanguagesSpoken = 3
let roleAtWork = "teacher"
let disciplines = ["maths", "informatics", "mathematical literacy"]
let companyIAmWorkingFor = "Sigma"
let languagesSpoken = ["kazakh", "russian", "english"]
let hobby = "swimming"
let secondHobby = "football"
let thirdHobby = "watching movies"
let numberOfHobbies = 3
let favoriteNumber = 29
let 🎯 = favoriteNumber
let isHobbyCreative = false
let emojiForTheLastSentence = "🤩"
let swimmingEmoji = "🏊‍♂️"
let footballEmoji = "⚽️"
let movieEmoji = "🎬"
let hobbyCreativityNote = isHobbyCreative ? "creative hobby" : "not particularly a creative hobby"
let favoriteTVShow = "Better call Saul"
let favoriteSuperheroTVShow = "Daredevil"
let favoriteMovie = "Avengers: Infinity War"
let favoriteAnimatedMovie = "Spider-man: Across the Spiderverse"
let favoriteAnimatedTVShow = "Avatar: The last airbender"
var lifeStory = "My name is \(firstName) \(lastName). I am \(nation). I was born in \(hometown). I am \(height) meters tall. I speak \(numberOfLanguagesSpoken) languages, including \(languagesSpoken.joined(separator: ", ")). Right now i am a student of \(university). I am currently working as \(roleAtWork) for the company \(companyIAmWorkingFor), and I prepare schoolchildren for disciplines including \(disciplines.joined(separator: ", ")). I was born in \(birthYear), which makes me \(age) years old, and I got my Bachelor's degree in \(bachelorDegreeYear) from \(faculty), majoring in \(specialty). In my free time, I enjoy \(hobby) \(swimmingEmoji), which is \(hobbyCreativityNote). I have \(numberOfHobbies) hobbies in total including \(secondHobby) \(footballEmoji) and \(thirdHobby) \(movieEmoji), and my favorite number is \(🎯). My favorite movie is \(favoriteMovie), and my favorite animated movie is \(favoriteAnimatedMovie). I also enjoy watching \(favoriteTVShow), \(favoriteSuperheroTVShow), and \(favoriteAnimatedTVShow)."

let futureGoals = "My major goal for the near future is to become a specialist in Information Technology sphere. In the last summer, I got rejected from several companies including Kolesa Group, Andersen, EPAM TechOrda, Netcracker. So I think I need to try harder and try some new directions including Mobile Development. It's the reason why I chose iOS Dev course. I am going to graduate the university in the next year. I am also preparing for IELTS exam and completing my portfolio in order to get invitation from universities of Europe or Great Britain. After graduation I am going to study in Masters Degree. I hope this course of iOS will be unforgettable) \(emojiForTheLastSentence)"
lifeStory.append(" " + futureGoals)
print(lifeStory)
