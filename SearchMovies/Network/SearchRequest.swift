//
//  SearchRequest.swift
//  SearchMovies
//
//  Created by Alok Jha on 23/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import UIKit

struct SearchRequest: APIRequest {
    
    var method = RequestType.GET
    var path = "search/movie"
    var parameters = [String: String]()
    
    init(parameters : [String : String]) {
        self.parameters = parameters;
    }
    
}
