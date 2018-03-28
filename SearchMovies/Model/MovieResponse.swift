//
//  MovieResponse.swift
//  SearchMovies
//
//  Created by Alok Jha on 28/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import Foundation

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
