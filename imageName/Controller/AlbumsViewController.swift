//
//  ViewController.swift
//  imageName
//
//  Created by Darren on 9/21/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class AlbumsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UINavigationControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating {
    
    
    @IBOutlet weak var albumsCollectionView: UICollectionView!
    let searchController = UISearchController(searchResultsController: nil)
    var tap: UITapGestureRecognizer!
    var albumsArray = [Albums]()
    var searchedAlbumsArray = [Albums]()
    var cellAlbum: Albums!
    
    var noSearchResult = false
    var label = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        print("hi")
        label.layer.zPosition = 1
        label.text = "No search results found"
        print(view.frame.height)
        label.frame = CGRect(x: view.frame.midX - 95, y: 0, width: 500, height: view.frame.height - 530 )
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        self.albumsCollectionView.delegate = self
        self.albumsCollectionView.dataSource = self
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = true
        self.searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.sizeToFit()
        searchController.searchBar.becomeFirstResponder()
        self.navigationItem.titleView = searchController.searchBar
        searchController.searchBar.placeholder = "Search for a album"
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlbum))
        navigationItem.rightBarButtonItem = item
       
        if let data = defaults.object(forKey: "albumsArray") as? Data {
            albumsArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Albums] ?? [Albums]()
        }
        print(albumsArray.count)

    }
    
    
    
    @objc func addAlbum(_: UIBarButtonItem) {
        let ac = UIAlertController(title: "Picture Title", message: "Give your picture a name.", preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let albumTitle = ac.textFields![0]
            let album = Albums(albumName: albumTitle.text!)
            self.albumsArray.append(album)
            self.saveAlbums()
            self.saveAlbumsSearchedArray()
            self.albumsCollectionView.reloadData()
        }
       
        
        ac.addAction(submitAction)
        present(ac, animated: true)
        self.saveAlbums()
        self.saveAlbumsSearchedArray()
        self.albumsCollectionView.reloadData()
    }
    
    @objc func dismissKeyboard() {
        print("dismisskeyboard")

        if (view.gestureRecognizers?.contains(tap))!{
            view.removeGestureRecognizer(tap)
        }
        view.gestureRecognizers?.removeAll()
        
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
        
        if (searchController.searchBar.text?.isEmpty)! {
           
        }
        
        if(!(searchController.searchBar.text?.isEmpty)!){
            
            if !(view.gestureRecognizers?.contains(tap))! {
                dismissKeyboard()
            }
            searchedAlbumsArray.removeAll(keepingCapacity: true)
            for album in albumsArray {
                func searchResult() -> String {
                    return "\(searchController.searchBar.text!)"
                }
                if album.name.contains(searchResult().lowercased()) {
                    noSearchResult = false
                    
                    if searchedAlbumsArray.contains(album) {
                        dismissKeyboard()
                        return
                    } else if !searchedAlbumsArray.contains(album) {
                        searchedAlbumsArray.append(album)
                        searchController.searchBar.showsCancelButton = false
                        print("o \(searchedAlbumsArray.count)")
                        albumsCollectionView.reloadData()
                    }
                }
            }
        }
        self.reloadInputViews()
        albumsCollectionView.reloadData()
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            searchedAlbumsArray.removeAll(keepingCapacity: true)
            albumsCollectionView.reloadData()
            view.removeGestureRecognizer(tap)
            searchBar.showsCancelButton = false
            saveAlbumsSearchedArray()
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedAlbumsArray.removeAll(keepingCapacity: true)
        searchBar.text?.removeAll(keepingCapacity: true)
        dismissKeyboard()
        searchBar.showsCancelButton = false
        view.removeGestureRecognizer(tap)
        saveAlbumsSearchedArray()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albumsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! albumsCell
        if noSearchResult {
            cell.isHidden = true
            label.isHidden = false
        } else {
            cell.isHidden = false
            label.isHidden = true
        }
        if searchedAlbumsArray.isEmpty {
            cellAlbum = albumsArray[indexPath.item]

        } else {
            print("in \(searchedAlbumsArray.count)")
            cellAlbum = searchedAlbumsArray[indexPath.item]
        }
        cell.albumName.text = cellAlbum.name
//        let path = getDocumentsDirectory().appendingPathComponent(picture.image)
//        cell.imageView.image = UIImage(contentsOfFile: path.path)
//        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7


        saveAlbums()
        self.saveAlbumsSearchedArray()
        return cell
        
    }

    func saveAlbums() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: albumsArray)
        defaults.set(savedData, forKey: "albumsArray")
    }
    func saveAlbumsSearchedArray() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: searchedAlbumsArray)
        defaults.set(savedData, forKey: "searchedAlbumsArray")
    }


}


