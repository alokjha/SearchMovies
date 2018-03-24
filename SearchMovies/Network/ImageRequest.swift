//
//  ImageRequest.swift
//  SearchMovies
//
//  Created by Alok Jha on 23/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import Foundation

struct ImageRequest : APIRequest {
    
    var method = RequestType.GET
    var path = ""
    var parameters = [String: String]()
    
    init(name: String) {
        path = name;
    }
}
