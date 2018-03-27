//
//  PersistenceStore.swift
//  SearchMovies
//
//  Created by Alok Jha on 26/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import Foundation

protocol PersistenceStore {
    associatedtype Storage
    associatedtype DataBaseObject
    
    var storage : Storage {get}
    
    func save(_ obj : DataBaseObject)
}


struct SearchQueryStore : PersistenceStore {
    
    typealias Storage = UserDefaults
    typealias DataBaseObject = SearchQuery
    
    let storage = UserDefaults.standard
    private let key = "searchResults"

    func save(_ obj: SearchQuery) {
        
        guard var array = storage.array(forKey: key) as? [String] else {
            let array = Array<String>.init(arrayLiteral: obj.value)
            storage.set(array, forKey: key)
            storage.synchronize()
            return
        }
        
        if array.count == 10 {
            
            if let index = array.index(of: obj.value) {
                array.remove(at: index)
                array.append(obj.value)
            }
            else {
                array.removeFirst()
                array.append(obj.value)
            }
        }
        else {
            
            if let index = array.index(of: obj.value) {
                array.remove(at: index)
                array.append(obj.value)
            }
            else {
                array.append(obj.value)
            }
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
