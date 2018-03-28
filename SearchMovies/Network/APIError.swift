//
//  APIError.swift
//  SearchMovies
//
//  Created by Alok Jha on 28/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import Foundation

enum APIError: Error {
    case CouldNotDownloadImage
    case EmptyResults
    case NoMoreResults
    case Other(String)
}

extension APIError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .CouldNotDownloadImage:
            return "Could not download image"
        case .EmptyResults :
            return "No results for this query"
        case .NoMoreResults:
            return "No more results to show"
        case let .Other(message):
            return "\(message)"
        }
    }
}
