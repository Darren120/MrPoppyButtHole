//
//  PhotosViewController.swift
//  imageName
//
//  Created by Darren on 9/21/17.
//  Copyright © 2017 Darren. All rights reserved.
// MAIN PROJECT FILE. NOT A CLONE.

import UIKit
import Photos
let reuseIdentifier = "photoCell"
let defaults = UserDefaults.standard
protocol clearSearch {
    func clearSearchOnDismiss(clear: Bool)
}
class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, clearSearch {
    func clearSearchOnDismiss(clear: Bool) {
        guard clear else{return}
        print("in")
        searchController.searchBar.text = ""
        searchedArray.removeAll(keepingCapacity: true)
        dismissKeyboard()
        photoCollectionCell.reloadData()
    }
    
    
    let picker = UIImagePickerController()
    var tap: UITapGestureRecognizer!
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var photoCollectionCell: UICollectionView!
    var photos = [Photos]()
    var searchedArray = [Photos]()
    var picture: Photos!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoCollectionCell.dataSource = self
        photoCollectionCell.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        print("didload")
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search for tools and resources"
        searchController.searchBar.sizeToFit()
        searchController.searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchController.searchBar
        searchController.searchBar.placeholder = "Search for a picture"
        if let data = defaults.object(forKey: "photos") as? Data {
            photos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = false
        navigationController?.navigationBar.isHidden = false
        navigationController?.tabBarController?.tabBar.isHidden = false
        
        if let data = defaults.object(forKey: "photos") as? Data {
            photos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
        }
        photoCollectionCell.reloadData()
        print("appear")
    }
    
    
    
    
    @objc func dismissKeyboard() {
        print("dismisskeyboard")
        searchController.dismiss(animated: true, completion: nil)
        if (view.gestureRecognizers?.contains(tap))!{
            view.removeGestureRecognizer(tap)
        }
        
        self.view.endEditing(true)
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func updateSearchResults(for searchController: UISearchController){
        
        if view.gestureRecognizers?.contains(tap) == false {
            view.addGestureRecognizer(tap)
        }
        
        if(!(searchController.searchBar.text?.isEmpty)!){
            
            if !(view.gestureRecognizers?.contains(tap))! {
                dismissKeyboard()
            }
            searchedArray.removeAll(keepingCapacity: true)
            for pictures in photos {
                func searchResult() -> String {
                    return "\(searchController.searchBar.text!)"
                }
                if pictures.name.contains(searchResult().lowercased()) {
                    
                    if searchedArray.contains(pictures) {
                        dismissKeyboard()
                        return
                    } else if !searchedArray.contains(pictures) {
                        searchedArray.append(pictures)
                        searchController.searchBar.showsCancelButton = false
                        photoCollectionCell.reloadData()
                    }
                }
            }
        }
        
        photoCollectionCell.reloadData()
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            searchedArray.removeAll(keepingCapacity: true)
            photoCollectionCell.reloadData()
            view.removeGestureRecognizer(tap)
            searchBar.showsCancelButton = false
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedArray.removeAll(keepingCapacity: true)
        searchBar.text?.removeAll(keepingCapacity: true)
        dismissKeyboard()
        searchBar.showsCancelButton = false
        view.removeGestureRecognizer(tap)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if searchedArray.isEmpty {
            return photos.count
        } else {
            return searchedArray.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! photoCell
        if searchedArray.isEmpty {
            picture = photos[indexPath.item]
            
        } else {
            picture = searchedArray[indexPath.item]
        }
        cell.label.text = picture.name
        let path = getDocumentsDirectory().appendingPathComponent(picture.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7       
        
        
        saved()
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fullPicture") {
            
            let controller: FullPictureController = segue.destination as! FullPictureController
            
            let index: NSIndexPath = self.photoCollectionCell.indexPath(for: sender as! UICollectionViewCell)! as NSIndexPath
            if searchedArray.isEmpty {
                controller.indexPath = index.item
                controller.photos = photos
            } else {
                controller.delegate = self
                controller.isSearched = true
               
                controller.indexPath = index.item
                controller.photos = searchedArray
            }
        }
        
    }
    
    
    @IBAction func takePicBtn(_ sender: Any) {
        searchedArray.removeAll(keepingCapacity: true)
        searchController.searchBar.text?.removeAll(keepingCapacity: true)
        if view.gestureRecognizers?.contains(tap) == true {
            view.removeGestureRecognizer(tap)
            dismissKeyboard()
        }
        searchController.searchBar.reloadInputViews()
        photoCollectionCell.reloadData()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    @IBAction func pickImgBtn(_ sender: Any) {
        searchedArray.removeAll(keepingCapacity: true)
        searchController.searchBar.text?.removeAll(keepingCapacity: true)
        if view.gestureRecognizers?.contains(tap) == true {
            view.removeGestureRecognizer(tap)
            dismissKeyboard()
        }
        
        searchController.searchBar.reloadInputViews()
        photoCollectionCell.reloadData()
        
        picker.allowsEditing = true
        
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = UIImageJPEGRepresentation(image, 1.0){
            try? jpegData.write(to: imagePath)
        }
        
        let picture = Photos(name: "Name", image: imageName)
        picker.dismiss(animated: true)
        if picture.image == nil {
            if view == picker.view {
                picker.dismiss(animated: true, completion: nil)
            }
        }
        let ac = UIAlertController(title: "Picture Title", message: "Give your picture a name.", preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let pictureTitle = ac.textFields![0]
            picture.name = pictureTitle.text!
            self.photos.append(picture)
            self.saved()
            self.photoCollectionCell.reloadData()
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
        saved()
        photoCollectionCell.reloadData()
        
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
