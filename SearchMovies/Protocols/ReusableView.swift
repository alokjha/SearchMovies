//
//  ReusableView.swift
//  SearchMovies
//
//  Created by Alok Jha on 24/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import UIKit

protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String.init(describing: self)
    }
}

