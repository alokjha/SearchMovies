//
//  MovieClient.swift
//  SearchMovies
//
//  Created by Alok Jha on 28/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import Foundation

class  MovieClient : APIClient {
    var baseURL: URL = URL(string: "https://api.themoviedb.org/3/")!
}
