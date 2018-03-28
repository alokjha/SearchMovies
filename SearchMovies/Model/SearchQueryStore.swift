//
//  SearchQueryStore.swift
//  SearchMovies
//
//  Created by Alok Jha on 28/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import Foundation

struct SearchQueryStore : PersistenceStore {
    
    typealias Storage = UserDefaults
    typealias DataBaseObject = SearchQuery
    
    let storage = UserDefaults.standard
    private let key = "searchResults"
    
    func save(_ obj: SearchQuery) {
        
        let value = obj.value.lowercased()
        
        guard var array = storage.array(forKey: key) as? [String] else {
            let array = [value]
            storage.set(array, forKey: key)
            storage.synchronize()
            return
        }
        
        if let index = array.index(of: value) {
            array.remove(at: index)
        }
        
        if array.count == 10 {
            array.removeLast()
            array.insert(value, at: 0)
        }
        else {
            array.insert(value, at: 0)
        }
        
        storage.set(array, forKey: key)
        storage.synchronize()
    }
    
    func allObjects() -> [SearchQuery] {
        
        if let array = storage.object(forKey: key) as? [String] {
            var objects : [SearchQuery] = []
            for str in array {
                let query = SearchQuery(value: str, page: 0)
                objects.append(query)
            }
            return objects
        }
        else {
            return []
        }
    }
}
