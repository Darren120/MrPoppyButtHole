//
//  FullPictureController.swift
//  imageName
//
//  Created by Darren on 9/21/17.
//  Copyright © 2017 Darren. All rights reserved.
//gay gay gay

import UIKit
protocol searchArrayCheck {
    func fillArray (array: [Photos], populate: Bool)
}
class FullPictureController: UIViewController, UIScrollViewDelegate, searchArrayCheck {
    func fillArray(array: [Photos], populate: Bool) {
        if populate {
            searchedArray = array
            isSearched = true
        } else {
            photos = array
        }
    }
    
    var image: String!
    var delegate: clearSearch?
    var isSearched = false
    var clearSearch = false
    var photos = [Photos]()
    var searchedArray = [Photos]()
    var indexPath: Int = 0
    var doubleTap: UITapGestureRecognizer!
    var swipeLeft: UISwipeGestureRecognizer!
    var swipeRight: UISwipeGestureRecognizer!
    var path: URL!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if searchedArray.isEmpty {
            path = getDocumentsDirectory().appendingPathComponent(photos[indexPath].image)
            imageView.image = UIImage(contentsOfFile: path.path)
            title = photos[indexPath].name
        } else {
            path = getDocumentsDirectory().appendingPathComponent(searchedArray[indexPath].image)
            imageView.image = UIImage(contentsOfFile: path.path)
            title = searchedArray[indexPath].name
        }
        
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = true
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(hideController))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.backgroundColor = .white
        
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
        sizeToFit()
        return imageView
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        scrollView.isHidden = true
        imageView.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @objc func hideController(gesture: UISwipeGestureRecognizer) {
        print("j")
        switch gesture {
        case doubleTap:
            UIView.animate(withDuration: 0.50, animations: { [unowned self] in
                self.navigationController?.navigationBar.isHidden = false
                self.scrollView.zoomScale = 1.0
                self.scrollView.frame = self.view.frame
            })
        default:
            break
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = true
        navigationController?.tabBarController?.tabBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func deleteImage() {
        let ac = UIAlertController(title: "Delete Picture?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes", style: .default, handler: { [unowned self]
            (_: UIAlertAction) in
            if let data = defaults.object(forKey: "photos") as? Data {
                self.photos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
                let fileManager = FileManager.default
                do {
                    try fileManager.removeItem(at: self.path)
                } catch {
                    self.dismiss(animated: true, completion: nil)
                    print("delete failed")
                }
            } else {
                print("phtots cant be deleted")
                return
            }
            
            
            if self.isSearched {
                for item in self.photos {
                    if item.name == self.searchedArray[self.indexPath].name {
                        if let index = self.photos.index(of: item){
                            self.photos.remove(at: index)
                            self.saved()
                        }
                    }
                }
                self.searchedArray.remove(at: self.indexPath)
                self.savedSearch()
                self.saved()
                self.isSearched = false
                self.delegate?.updateSearchResults(returnedFromSearch: true)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.delegate?.updateSearchResults(returnedFromSearch: false)
                if self.photos.indices.contains(self.indexPath - 1)  {
                    print(self.indexPath)
                    self.path = getDocumentsDirectory().appendingPathComponent(self.photos[self.indexPath - 1].image)
                    UIView.animate(withDuration: 0.23, animations: { [unowned self] in
                        self.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        }, completion: {[unowned self] (_: Bool) in
                            UIView.animate(withDuration: 0.22, animations: { [unowned self] in
                                self.view.transform = CGAffineTransform.identity
                                self.imageView.image = UIImage(contentsOfFile: self.path.path)
                                }, completion: nil)
                    })
                    self.title = self.photos[self.indexPath - 1].name
                    self.photos.remove(at: self.indexPath)
                    for name in self.photos {
                        if name.name == self.title {
                            if let index = self.photos.index(of: name) {
                                self.indexPath = index
                            }
                        }
                    }
                    
                    self.saved()
                } else if self.photos.indices.contains(self.indexPath + 1) {
                    self.path = getDocumentsDirectory().appendingPathComponent(self.photos[self.indexPath + 1].image)
                    UIView.animate(withDuration: 0.23, animations: { [unowned self] in
                        self.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        }, completion: {[unowned self] (_: Bool) in
                            UIView.animate(withDuration: 0.22, animations: { [unowned self] in
                                self.view.transform = CGAffineTransform.identity
                                self.imageView.image = UIImage(contentsOfFile: self.path.path)
                                }, completion: nil)
                    })
                    self.title = self.photos[self.indexPath + 1].name
                    self.photos.remove(at: self.indexPath)
                    for name in self.photos {
                        if name.name == self.title {
                            if let index = self.photos.index(of: name) {
                                self.indexPath = index
                            }
                        }
                    }
                    self.saved()
                } else {
                    UIView.animate(withDuration: 0.23, animations: { [unowned self] in
                        self.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        }, completion: {[unowned self] (_: Bool) in
                            self.view.backgroundColor = UIColor.white
                            self.photos.remove(at: self.indexPath)
                            self.saved()
                            self.navigationController?.popViewController(animated: true)
                    })
                }
            }
            
            
            
        }))
        
        
        ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: {
            (_: UIAlertAction)in
            return
        }))
        present(ac, animated: true, completion: nil)
        
        
    }
    
    
    @objc func addNotes() {
        
    }
    
    func sizeToFit() {
        let width = view.frame.width
        
        let height = view.frame.height
        scrollView.frame = CGRect(x: 0 , y: 0  , width: width, height: height)
        imageView.frame = CGRect(x: 0 , y: 0  , width: width, height: height)
        imageView.contentMode = .scaleAspectFit
    }

    
    func saved() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: photos)
        defaults.set(savedData, forKey: "photos")
    }
    func savedSearch() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: searchedArray)
        defaults.set(savedData, forKey: "searchPhotos")
    }
}
