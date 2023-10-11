//
//  ImageDetailViewController.swift
//  AGCM
//
//  Created by Thirumal Sivakumar on 01/02/23.
//

import UIKit
import ImageScrollView

class ImageDetailViewController: UIViewController {
    
    @IBOutlet weak var imageScrollView: ImageScrollView!
    let selectedImage: UIImage
    let fileName: String
    init(image: UIImage, fileName: String) {
        self.selectedImage = image
        self.fileName = fileName
        super.init(nibName: "ImageDetailViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageScrollView.setup()
        imageScrollView.display(image: selectedImage)
        self.title = fileName
    }

}
