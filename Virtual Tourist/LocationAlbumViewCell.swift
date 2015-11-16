//
//  LocationAlbumViewCell.swift
//  Virtual Tourist
//
//  Created by Enrico Montana on 10/18/15.
//  Copyright © 2015 Enrico Montana. All rights reserved.
//

import UIKit

class LocationAlbumViewCell: UICollectionViewCell {

    @IBOutlet weak var locationPhotoView: UIImageView!
    
    var imageName: String = ""
    
    var taskToCancelifCellIsReused: NSURLSessionTask? {
        
        didSet {
            if let taskToCancel = oldValue {
                taskToCancel.cancel()
            }
        }
    }

}