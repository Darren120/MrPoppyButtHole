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
    var photos = [Photos]()
    var indexPath: Int = 0
    var isNavHidden = false
    var tap: UITapGestureRecognizer!
    var doubleTap: UITapGestureRecognizer!
    var path: URL!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.translatesAutoresizingMaskIntoConstraints = false
        path = getDocumentsDirectory().appendingPathComponent(photos[indexPath].image)
        imageView.image = UIImage(contentsOfFile: path.path)
        title = photos[indexPath].name
        
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
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteImage))
        let notes = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(addNotes))
        let barButtonArray: [UIBarButtonItem] = [delete, notes]
        navigationItem.rightBarButtonItems = barButtonArray
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        if !navigationController!.navigationBar.isHidden {
            navigationController?.navigationBar.isHidden = true
        }
        return imageView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        scrollView.isHidden = true
        imageView.isHidden = true
        self.dismiss(animated: true, completion: nil)
  
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
            UIView.animate(withDuration: 0.50, animations: { [unowned self] in
                self.scrollView.zoomScale = 1.0
            })
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
    
    @objc func deleteImage() {
        
        if let data = defaults.object(forKey: "photos") as? Data {
            photos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
            let fileManager = FileManager.default
            do {
                try fileManager.removeItem(at: path)
            } catch {
                dismiss(animated: true, completion: nil)
                print("delete failed")
            }
            
        // CRASHES IF INDEX IS OUT OF RANGE AND I TRY TO CHECK IT BUT IT DONT WORK
        if photos.indices.contains(indexPath - 1)  {
            print(indexPath)
            path = getDocumentsDirectory().appendingPathComponent(photos[indexPath - 1].image)
            imageView.image = UIImage(contentsOfFile: path.path)
            title = photos[indexPath - 1].name
            photos.remove(at: indexPath)
            for name in photos {
                if name.name == title {
                    if let index = photos.index(of: name) {
                        indexPath = index
                    }
                }
            }
            
            saved()
            } else if photos.indices.contains(indexPath + 1) {
            print(indexPath)
                path = getDocumentsDirectory().appendingPathComponent(photos[indexPath + 1].image)
                imageView.image = UIImage(contentsOfFile: path.path)
                title = photos[indexPath + 1].name
                photos.remove(at: indexPath)
                for name in photos {
                    if name.name == title {
                        if let index = photos.index(of: name) {
                            indexPath = index
                        }
                    }
                }
                saved()
        } else {
            print("in here")
            photos.remove(at: indexPath)
            saved()
            navigationController?.popViewController(animated: true)
            }
                
        }

    }
    
    
    @objc func addNotes() {
        
    }
    
    func sizeToFit() {
        let width = view.frame.width
        let navBarHeght = navigationController!.navigationBar.frame.height
        let height = view.frame.height
        scrollView.frame = CGRect(x: 0 , y: 0 - navBarHeght, width: width, height: height + navBarHeght)
        imageView.frame = scrollView.frame
    }
    
    func saved() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: photos)
        defaults.set(savedData, forKey: "photos")
    }
}
