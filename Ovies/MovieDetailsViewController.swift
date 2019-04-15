//
//  MovieDetailsViewController.swift
//  Ovies
//
//  Created by Ben on 01/04/2019.
//  Copyright © 2019 BehorDev. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var movieGenre: UITextField!
    @IBOutlet weak var movieRating: UITextField!
    @IBOutlet weak var movieTitle: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    @IBAction func closeMovieDetailsPopup(_ sender: UIButton) {
        self.view.removeFromSuperview()
    }
}
