//
//  documentsDirectory.swift
//  imageName
//
//  Created by Darren on 9/25/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import Foundation

func getDocumentsDirectory() -> URL {
    //This call for path always returns an array containing one thing, the user's personal directory.
    let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    let documentsDirectory = path[0]
    return documentsDirectory
    
}

var photos = [Photos]()
var searchedArray = [Photos]()
