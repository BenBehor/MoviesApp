//
//  Movie.swift
//  Ovies
//
//  Created by Ben on 25/02/2019.
//  Copyright © 2019 BehorDev. All rights reserved.
//

import Foundation

class Movie: Codable {
    let title: String
    let image: String
    let rating: Double
    let releaseYear: Int
    let genre: [String]
    
    init(title:String, image:String, rating:Double, releaseYear:Int, genre:[String]) {
        self.title = title
        self.image = image
        self.rating = rating
        self.releaseYear = releaseYear
        self.genre = genre
    }
}
