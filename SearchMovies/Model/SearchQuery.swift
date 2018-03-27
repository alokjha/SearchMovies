//
//  SearchQuery.swift
//  SearchMovies
//
//  Created by Alok Jha on 26/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import Foundation

struct SearchQuery {
    let value : String
    let page : Int
}

extension SearchQuery :  Equatable {
    
    static func ==(lhs: SearchQuery, rhs: SearchQuery) -> Bool {
        return lhs.value.lowercased() == rhs.value.lowercased() && lhs.page == rhs.page
    }

}
