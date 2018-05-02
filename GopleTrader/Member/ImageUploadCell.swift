//
//  ImageUploadCell.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 17..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit

class ImageUploadCell: UITableViewCell {
    
    var company: CompanyImg? {
        didSet {
            if let subPath = company?.companyImg {
                if subPath != "" {
                    let imagePath = domain + subPath
                    print(imagePath)
                    
                    let imageData = try? Data(contentsOf : URL(string: imagePath)!)
                    
                    self.companyImg.image = UIImage(data: imageData!)
                } else {
                    return
                }
            }
            
            if let imageLink = company?.companyLink {
                self.imgLink.text = imageLink
            }
        }
    }
    
    @IBOutlet weak var companyImg: UIImageView!
    
    @IBOutlet weak var imgLink: UILabel!
    
    @IBOutlet weak var imgDelete: UIButton!

}
