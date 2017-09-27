//
//  FullPictureController.swift
//  imageName
//
//  Created by Darren on 9/21/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import UIKit

class FullPictureController: UIViewController, UIScrollViewDelegate {
    var image: String!
    var photo = [Photos]()
    var indexPath: Int = 0
    var isNavHidden = false
    var tap: UITapGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        let path = getDocumentsDirectory().appendingPathComponent(photo[indexPath].image)
        imageView.image = UIImage(contentsOfFile: path.path)
        title = photo[indexPath].name
        
        tap = UITapGestureRecognizer(target: self, action: #selector(hideController))
        tap.numberOfTapsRequired = 1
        view.addGestureRecognizer(tap)
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(hideController))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        sizeToFit()
        
        
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if !navigationController!.navigationBar.isHidden {
            navigationController?.navigationBar.isHidden = true
        }
        return imageView
    }
    

    @objc func hideController(gesture: UISwipeGestureRecognizer) {
        switch gesture {
        case tap:
            guard scrollView.zoomScale <= 1.0 else {return}
            if !isNavHidden {
                navigationController?.navigationBar.isHidden = true
                isNavHidden = true
                
            } else {
                navigationController?.navigationBar.isHidden = false
                isNavHidden = false
  
            }
        case doubleTap:
            scrollView.zoomScale = 1.0
            scrollView.frame = view.frame
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func sizeToFit() {
        let width = view.frame.width
        let navBarHeght = navigationController!.navigationBar.frame.height
        let height = view.frame.height
        scrollView.frame = CGRect(x: 0 , y: 0 - navBarHeght, width: width, height: height + navBarHeght)
        imageView.frame = scrollView.frame
    }

}
