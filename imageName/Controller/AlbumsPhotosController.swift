//
//  AlbumsPhotosView.swift
//  imageName
//
//  Created by Darren on 12/6/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import Foundation
import UIKit

class AlbumsPhotosController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, clearSearch  {
    func updateSearchResults(returnedFromSearch: Bool, clearSearch: Bool) {
        
    }
    
    @IBOutlet weak var albumsPhotosCollection: UICollectionView!
    
    
    var searchArrayCheckDelegate: searchArrayCheck?
    var arrayDelegate: arrayCheck?
    
    let picker = UIImagePickerController()
    var tap: UITapGestureRecognizer!
    let searchController = UISearchController(searchResultsController: nil)
    var indexPath: Int = 0
    var uniqueID = ""
    var populate: Bool = true
    var albumsPhotos = [Photos]()
    var searchedArray = [Photos]()
    var picture: Photos!
    var label = UILabel()
    var noSearchResult = false
    var emptyArray = [Photos]()
    override func viewDidLoad() {
        super.viewDidLoad()
        print(indexPath)
        
        
        label.layer.zPosition = 1
        label.text = "No search results found"
        print(view.frame.height)
        label.frame = CGRect(x: 0, y: 0, width: 500, height: view.frame.height - 500 )
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        label.isHidden = true
        albumsPhotosCollection.dataSource = self
        albumsPhotosCollection.delegate = self
//        automaticallyAdjustsScrollViewInsets = false
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
        fillNavBarItem()
        if let data = defaults.object(forKey: "albumsPhotos\(indexPath)") as? Data {
            albumsPhotos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
            
            
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = false
        navigationController?.navigationBar.isHidden = false
        navigationController?.tabBarController?.tabBar.isHidden = false
        
    }
    override func viewDidAppear(_ animated: Bool) {
        print(indexPath)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        arrayDelegate?.fillArray(array: albumsPhotos, populate: populate, index: indexPath)
        self.searchController.view.removeFromSuperview()

    }
    
    
    @objc func dismissKeyboard() {
        print("dismisskeyboard")
        searchController.dismiss(animated: true, completion: nil)
        if (view.gestureRecognizers?.contains(tap))!{
            view.removeGestureRecognizer(tap)
        }
        view.gestureRecognizers?.removeAll()
        fillNavBarItem()
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
        self.navigationItem.setRightBarButtonItems( [], animated: true)
        tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    func updateSearchResults(for searchController: UISearchController){
        var number = 0
        func searchResult() -> String {
            return "\(searchController.searchBar.text!)"
        }
        
        if view.gestureRecognizers?.contains(tap) == false {
            view.addGestureRecognizer(tap)
        }
        
        if (searchController.searchBar.text?.isEmpty)! {
            noSearchResult = false
        }
        
        if(!(searchController.searchBar.text?.isEmpty)!){
            
            if !(view.gestureRecognizers?.contains(tap))! {
                dismissKeyboard()
            }
            searchedArray.removeAll(keepingCapacity: true)
            for pictures in albumsPhotos {
                
                noSearchResult = false
                let searchText = searchResult()
                if pictures.name.lowercased().contains(searchText.lowercased()) == false {
                    number += 1
                }
                if pictures.name.lowercased().contains(searchText.lowercased()) {
                    print("does contan \(pictures.name)")
                    noSearchResult = false
                    if searchedArray.contains(pictures) {
                        dismissKeyboard()
                        return
                    } else if !searchedArray.contains(pictures) {
                        searchedArray.append(pictures)
                        searchController.searchBar.showsCancelButton = false
                        albumsPhotosCollection.reloadData()
                    }
                    
                }
            }
        }
        if number >= albumsPhotos.count {
            noSearchResult = true
            number = 0
        }
        
        albumsPhotosCollection.reloadData()
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            searchedArray.removeAll(keepingCapacity: true)
            albumsPhotosCollection.reloadData()
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
            return albumsPhotos.count
        } else {
            return searchedArray.count
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cunt")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "albumsPhotos", for: indexPath) as! albumsPhotosCell
        if noSearchResult {
            cell.isHidden = true
            label.isHidden = false
        } else {
            cell.isHidden = false
            label.isHidden = true
        }
        if searchedArray.isEmpty {
            picture = albumsPhotos[indexPath.item]
            
        } else {
            picture = searchedArray[indexPath.item]
        }
        cell.title.text = picture.name
        let path = getDocumentsDirectory().appendingPathComponent(picture.image)
        cell.image.image = UIImage(contentsOfFile: path.path)
        cell.image.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        self.savePhotos()

        
   
        
        return cell
        
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "fullPicture") {
//            
//            let controller: FullPictureController = segue.destination as! FullPictureController
//            searchDelegate = controller
//            let index: NSIndexPath = self.albumsPhotosCollection.indexPath(for: sender as! UICollectionViewCell)! as NSIndexPath
//            if searchedArray.isEmpty {
//                controller.indexPath = index.item
//                searchDelegate?.fillArray(array: albumsPhotos, populate: false)
//            } else {
//                controller.delegate = self
//                searchDelegate?.fillArray(array: searchedArray, populate: true)
//                controller.indexPath = index.item
//                print(searchedArray[index.item].name)
//            }
//        }
//        
//    }
    
    @objc func deleteAlbum() {
        let ac = UIAlertController(title: "Delete", message: "Do YOU wish to delete the entire album? This action cannot be undone.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { [unowned self]
                _ in
                
                for albums in self.albumsPhotos {
                   
                    let path = getDocumentsDirectory().appendingPathComponent(albums.image)
                    let fileManager = FileManager.default
                    do {
                        try fileManager.removeItem(at: path)
                    } catch {
                       
                        print("delete failed")
                    }
                    self.albumsPhotos.removeAll()
                    self.savePhotos()
                    
                    
                }
                self.savePhotos()
                self.populate = false
               self.navigationController?.popToRootViewController(animated: true)
                
            }))
            ac.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
            present(ac, animated: true)
    }
    @objc func takePicBtn() {
        searchedArray.removeAll(keepingCapacity: true)
        searchController.searchBar.text?.removeAll(keepingCapacity: true)
        if view.gestureRecognizers?.contains(tap) == true {
            view.removeGestureRecognizer(tap)
            dismissKeyboard()
        }
        searchController.searchBar.reloadInputViews()
        albumsPhotosCollection.reloadData()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .camera
        present(picker, animated: true)
    }
    @objc func pickImgBtn() {
        searchedArray.removeAll(keepingCapacity: true)
        searchController.searchBar.text?.removeAll(keepingCapacity: true)
        if view.gestureRecognizers?.contains(tap) == true {
            view.removeGestureRecognizer(tap)
            dismissKeyboard()
        }
        
        searchController.searchBar.reloadInputViews()
        albumsPhotosCollection.reloadData()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        print("camera")
        noSearchResult = false
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = UIImageJPEGRepresentation(image, 1.0){
            try? jpegData.write(to: imagePath)
        }
        
        let picture = Photos(name: "Name", image: imageName)
        picker.dismiss(animated: true)
        let ac = UIAlertController(title: "Picture Title", message: "Give your picture a name.", preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let pictureTitle = ac.textFields![0]
            picture.name = pictureTitle.text!
            self.albumsPhotos.append(picture)
           
            self.savePhotos()
            self.albumsPhotosCollection.reloadData()
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
       
     
        albumsPhotosCollection.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fullPicture" {
            if let controller = segue.destination as? FullPictureController {
                controller.int = 5
                
                let index: NSIndexPath = self.albumsPhotosCollection.indexPath(for: sender as! UICollectionViewCell)! as NSIndexPath
                searchArrayCheckDelegate = controller
                if searchedArray.isEmpty {
                    
                    controller.indexPath = index.item
                    print("ll\(index.item)")
                    searchArrayCheckDelegate?.fillArray(array: albumsPhotos, populate: false)
                } else {
                    controller.delegate = self
                    searchArrayCheckDelegate?.fillArray(array: searchedArray, populate: true)
                    controller.indexPath = index.item
                    print(searchedArray[index.item].name)
                }
            }
        }
    }
    func savePhotos() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: albumsPhotos)
        defaults.set(savedData, forKey: uniqueID)
    }
    func fillNavBarItem() {
        let pickImgButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pickImgBtn))
        let takeImgButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePicBtn))
        let deleteAlbumButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAlbum))
        self.navigationItem.setRightBarButtonItems( [deleteAlbumButton,pickImgButton,takeImgButton], animated: true)
    }
}
