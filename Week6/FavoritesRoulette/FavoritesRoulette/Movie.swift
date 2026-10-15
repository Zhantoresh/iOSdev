//
//  Movie.swift
//  FavoritesRoulette
//
//  Created by Жантөре Оразымбетов on 15.10.2026.
//

import UIKit

struct Movie {
    let title: String
    let year: Int
    let description: String
    let imageName: String
}

extension Movie {
    static let favorites: [Movie] = [
        Movie(title: "Тёмный рыцарь", year: 2008,
              description: "Бэтмен Кристофера Нолана противостоит Джокеру, который погружает Готэм в хаос.",
              imageName: "theDarkKnight"),
        Movie(title: "Бэтмен", year: 2022,
              description: "Молодой Брюс Уэйн охотится на серийного убийцу, оставляющего загадки.",
              imageName: "theBatman"),
        Movie(title: "Мстители: Финал", year: 2019,
              description: "Уцелевшие герои пытаются исправить последствия щелчка Таноса.",
              imageName: "avengersEndgame"),
        Movie(title: "Новый Человек-паук", year: 2012,
              description: "Питер Паркер узнаёт тайну исчезновения родителей и сражается с учёным, превратившимся в Ящера.",
              imageName: "amazingSpiderMan"),
        Movie(title: "Оно", year: 2017,
              description: "Дети из города Дерри встречаются с древним злом в облике клоуна Пеннивайза.",
              imageName: "itMovie"),
        Movie(title: "Человек-паук 3: Враг в отражении", year: 2007,
              description: "Питер борется с Песочным человеком и тёмной стороной, которую пробуждает чёрный симбиот.",
              imageName: "spiderMan3"),
        Movie(title: "Железный человек 3", year: 2013,
              description: "Тони Старк теряет дом и вынужден сразиться с Мандарином, полагаясь только на свой ум.",
              imageName: "ironMan3"),
        Movie(title: "Звёздные войны: Эпизод I", year: 1999,
              description: "Джедаи Квай-Гон и Оби-Ван спасают планету Набу и находят юного Энакина Скайуокера.",
              imageName: "starWarsEpisode1"),
        Movie(title: "Истребитель демонов: Бесконечная крепость", year: 2025,
              description: "Тандзиро и Столпы попадают в Бесконечную крепость, где их ждёт решающая битва с сильнейшими демонами.",
              imageName: "infinityCastle"),
        Movie(title: "Тачки 3", year: 2017,
              description: "Молния Маккуин, которого вытесняет новое поколение гонщиков, пытается вернуться в большой спорт.",
              imageName: "cars3")
    ]
}
