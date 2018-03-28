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
    func allObjects() -> [DataBaseObject]
}



