//
//  Albums.swift
//  imageName
//
//  Created by Darren on 11/21/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import Foundation
import UIKit
class Albums: NSObject, NSCoding {
    
    var albumPictures = [Photos]()
    var firstPicture: String = ""
    var secondPicture: String = ""
    var thirdPicture: String = ""
    var name: String
    
    init(albumName: String) {
//        firstPicture = firstPic
//        secondPicture = secondPic
//        thirdPicture = thirdPic
        self.name = albumName
    }
    
    required init(coder aDecoder: NSCoder) {
        albumPictures = aDecoder.decodeObject(forKey: "albumPictures") as! [Photos]
        firstPicture = aDecoder.decodeObject(forKey: "firstPicture") as! String
        secondPicture = aDecoder.decodeObject(forKey: "secondPicture") as! String
        thirdPicture = aDecoder.decodeObject(forKey: "thirdPicture") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(albumPictures, forKey: "albumPictures")
        aCoder.encode(firstPicture, forKey: "firstPicture")
        aCoder.encode(secondPicture, forKey: "secondPicture")
        aCoder.encode(thirdPicture, forKey: "thirdPicture")
        aCoder.encode(name, forKey: "name")
    }
}
