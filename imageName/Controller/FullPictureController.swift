//
//  FullPictureController.swift
//  imageName
//
//  Created by Darren on 9/21/17.
//  Copyright © 2017 Darren. All rights reserved.
//gay gay gay

import UIKit

class FullPictureController: UIViewController, UIScrollViewDelegate, searchArrayCheck {
    func fillArray(array: [Photos], populate: Bool) {
        print("g")
        if populate {
            searchedArray = array
            isSearched = true
        } else {
            photos = array
        }
    }
    
    var int = 0
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
       scrollView.isScrollEnabled = true
        print("ok:\(indexPath)")
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
        view.translatesAutoresizingMaskIntoConstraints = false
        doubleTap = UITapGestureRecognizer(target: self, action: #selector(hideController))
        swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipePicture))
        swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(swipePicture))
        swipeLeft.direction = .left
        swipeRight.direction = .right
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(swipeRight)
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(doubleTap)
        scrollView.delegate = self
        scrollView.addSubview(imageView)
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 10.0
        scrollView.backgroundColor = .black
        
        sizeToFit()
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteImage))
        let notes = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(addNotes))
        let barButtonArray: [UIBarButtonItem] = [delete, notes]
        navigationItem.rightBarButtonItems = barButtonArray
    }
    
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        navigationController?.navigationBar.isHidden = true
        if scrollView.zoomScale == 1 {
            navigationController?.navigationBar.isHidden = false
            sizeToFit()
        } else {
            navigationController?.navigationBar.isHidden = true

        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        scrollView.isHidden = true
        imageView.isHidden = true
        self.dismiss(animated: true, completion: nil)
    }
    @objc func swipePicture (gesture: UISwipeGestureRecognizer) {
        switch gesture {
        case swipeLeft:
            print("left")
        case swipeRight:
            print("right")
        default:
            break
        }
    }
    
    @objc func hideController(gesture: UISwipeGestureRecognizer) {
        print("j")
        switch gesture {
        case doubleTap:
            UIView.animate(withDuration: 0.50, animations: { [unowned self] in
                self.navigationController?.navigationBar.isHidden = false
                self.scrollView.zoomScale = 1.0
                self.scrollView.frame = self.view.frame
                self.sizeToFit()
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
                            print("founded")
                            self.saved()
                        }
                    }
                }
                if self.searchedArray.indices.contains(self.indexPath - 1) {
                    self.path = getDocumentsDirectory().appendingPathComponent(self.searchedArray[self.indexPath - 1].image)
                    UIView.animate(withDuration: 0.23, animations: { [unowned self] in
                        self.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        }, completion: {[unowned self] (_: Bool) in
                            UIView.animate(withDuration: 0.22, animations: { [unowned self] in
                                self.view.transform = CGAffineTransform.identity
                                self.imageView.image = UIImage(contentsOfFile: self.path.path)
                                }, completion: nil)
                    })
                    self.title = self.searchedArray[self.indexPath - 1].name
                    self.searchedArray.remove(at: self.indexPath)
                    self.savedSearch()
                    for name in self.searchedArray {
                        if name.name == self.title {
                            if let index = self.photos.index(of: name) {
                                self.indexPath = index
                            }
                        }
                        
                    }

                    self.saved()
                    self.savedSearch()
                    self.delegate?.updateSearchResults(returnedFromSearch: true, clearSearch: false)
                    
                } else if self.searchedArray.indices.contains(self.indexPath + 1) {
                    self.path = getDocumentsDirectory().appendingPathComponent(self.searchedArray[self.indexPath + 1].image)
                    UIView.animate(withDuration: 0.23, animations: { [unowned self] in
                        self.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        }, completion: {[unowned self] (_: Bool) in
                            UIView.animate(withDuration: 0.22, animations: { [unowned self] in
                                self.view.transform = CGAffineTransform.identity
                                self.imageView.image = UIImage(contentsOfFile: self.path.path)
                                }, completion: nil)
                    })
                    self.title = self.searchedArray[self.indexPath + 1].name
                    self.searchedArray.remove(at: self.indexPath)
                    self.savedSearch()
                    for name in self.searchedArray {
                        if name.name == self.title {
                            if let index = self.photos.index(of: name) {
                                self.indexPath = index
                            }
                        }
                        
                    }
                    self.saved()
                    self.savedSearch()
                    self.delegate?.updateSearchResults(returnedFromSearch: true, clearSearch: false)
                    
                    
                } else {
                    UIView.animate(withDuration: 0.23, animations: { [unowned self] in
                        self.view.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                        }, completion: {[unowned self] (_: Bool) in
                            self.view.backgroundColor = UIColor.white
                            self.searchedArray.remove(at: self.indexPath)
                            self.savedSearch()
                            self.delegate?.updateSearchResults(returnedFromSearch: true, clearSearch: true)
                            self.navigationController?.popViewController(animated: true)
                            
                    })
                }
            } else {
                self.delegate?.updateSearchResults(returnedFromSearch: false, clearSearch: false)
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
        
       
    }

    
    func saved() {
        if int == 0 {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: photos)
        defaults.set(savedData, forKey: "photos")
        }
    }
    func savedSearch() {
        if int == 0{
        let savedData = NSKeyedArchiver.archivedData(withRootObject: searchedArray)
        defaults.set(savedData, forKey: "searchPhotos")
        }
    }
        
}
