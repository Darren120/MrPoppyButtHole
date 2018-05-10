//
//  Protocols.swift
//  imageName
//
//  Created by Darren on 12/19/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import Foundation

protocol clearSearch {
    func updateSearchResults(returnedFromSearch: Bool, clearSearch: Bool)
}
protocol searchArrayCheck {
    func fillArray (array: [Photos], populate: Bool)
}
protocol arrayCheck {
    func fillArray (array: [Photos], populate: Bool, index: Int)
}
func resetDefaults() {
    let defaults = UserDefaults.standard
    let dictionary = defaults.dictionaryRepresentation()
    dictionary.keys.forEach { key in
        defaults.removeObject(forKey: key)
    }
}
