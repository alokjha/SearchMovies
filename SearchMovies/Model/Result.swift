//
//  Result.swift
//  SearchMovies
//
//  Created by Alok Jha on 27/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import Foundation

enum Result {
    case movie(movie : Movie)
    case searchHistory(query: SearchQuery)
}
