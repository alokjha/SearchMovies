//
//  NibLoadableView.swift
//  SearchMovies
//
//  Created by Alok Jha on 24/03/18.
//  Copyright © 2018 Alok Jha. All rights reserved.
//

import UIKit

protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String.init(describing: self).components(separatedBy: ".").last!
    }
}
