//
//  Movie.swift
//  SearchMovies
//
//  Created by Alok Jha on 23/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import UIKit

struct Movie: Codable {
    
    let title : String
    let overview : String
    let posterURL : String?
    let releaseDate : String
    
    private enum CodingKeys : String , CodingKey {
        case title
        case overview
        case posterURL = "poster_path"
        case releaseDate = "release_date"
    }
}

struct MovieResponse : Codable {
    
    let page : Int
    let totalResults : Int
    let totalPages : Int
    let results : [Movie]
    
    private enum CodingKeys : String , CodingKey {
        case page
        case totalResults = "total_results"
        case totalPages = "total_pages"
        case results
    }
}
