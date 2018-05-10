//
//  ViewController.swift
//  imageName
//
//  Created by Darren on 9/21/17.
//  Copyright © 2017 Darren. All rights reserved.
// gay

import UIKit


class AlbumsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource,UINavigationControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, arrayCheck {
    func fillArray(array: [Photos], populate: Bool, index: Int) {
        
        if populate == false {
         
            let defaults = UserDefaults.standard
            let dictionary = defaults.dictionaryRepresentation()
            if dictionary.keys.contains(albumsArray[index].uniqueID) {
                print("fuck me in the ass")
                defaults.removeObject(forKey: albumsArray[index].uniqueID)
                albumsArray.remove(at: index)
                albumsCollectionView.reloadData()
               
            }
            
        } else if populate == true {
            print("\(populate)")
            if let data = defaults.object(forKey: albumsArray[index].uniqueID) as? Data {
                print("kunt")
                let photo = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
                
                
                if albumsArray.isEmpty {
                    
                } else {
                    print("eberything ok")
                    albumsArray[index].albumPictures = photo
                }
                
            }
            
        }
        
        print("fuck my ding\(populate)")
        
        
        
        albumsCollectionView.reloadData()
        saveAlbums()
        
        
        
        
    }
    
    
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
        
        print(albumsArray.count)
        label.layer.zPosition = 1
        label.text = "No search results found"
        print(view.frame.height)
        label.frame = CGRect(x: 0, y: 0, width: 500, height: view.frame.height - 530 )
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
//                resetDefaults()
        
        if let data = defaults.object(forKey: "albumsArray") as? Data {
            albumsArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Albums] ?? [Albums]()
        }
        
        
        
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        self.searchController.view.removeFromSuperview()
    }
    @objc func addAlbum(_: UIBarButtonItem) {
        let ac = UIAlertController(title: "album title", message: "Give your picture a name.", preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let albumTitle = ac.textFields![0]
            let uniqueID = UUID().uuidString
            let album = Albums(albumName: albumTitle.text!, uniqueID: uniqueID)
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
        searchController.dismiss(animated: true, completion: nil)
        
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
            searchedAlbumsArray.removeAll(keepingCapacity: true)
            for album in albumsArray {
                
                noSearchResult = false
                let searchText = searchResult()
                if album.name.lowercased().contains(searchText.lowercased()) == false {
                    number += 1
                }
                if album.name.lowercased().contains(searchText.lowercased()) {
                    
                    noSearchResult = false
                    if searchedAlbumsArray.contains(album) {
                        dismissKeyboard()
                        return
                    } else if !searchedAlbumsArray.contains(album) {
                        searchedAlbumsArray.append(album)
                        searchController.searchBar.showsCancelButton = false
                        albumsCollectionView.reloadData()
                    }
                    
                }
            }
        }
        if number >= albumsArray.count {
            noSearchResult = true
            number = 0
        }
        print(searchedAlbumsArray.count)
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
        if searchedAlbumsArray.isEmpty {
            return albumsArray.count
        } else {
            return searchedAlbumsArray.count
        }
        
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
            print("arrayCount: \(searchedAlbumsArray.count) index number: \(indexPath.item)")
            
            cellAlbum = searchedAlbumsArray[indexPath.item]
        }
        cell.albumName.text = cellAlbum.name
        if !albumsArray[indexPath.item].albumPictures.isEmpty {
            var int = 0
            for _ in albumsArray[indexPath.item].albumPictures {
                if int != 3 {
                    let path = getDocumentsDirectory().appendingPathComponent(albumsArray[indexPath.item].albumPictures[int].image)
                    if int == 0 {
                        cell.middleImage.image = UIImage(contentsOfFile: path.path)
                        
                    } else if int == 1 {
                        cell.lastImage.image = UIImage(contentsOfFile: path.path)
                    } else if int == 2 {
                       cell.frontImage.image = UIImage(contentsOfFile: path.path)
                    }
                    
                    
                    int += 1 
                }
            }
           
            
        } else {
            cell.frontImage.image = nil
            print("no image")
        }
        cell.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        
        saveAlbums()
        self.saveAlbumsSearchedArray()
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "albumsToPhotos") {
            if let controller = segue.destination as? AlbumsPhotosController {
                let index: NSIndexPath = self.albumsCollectionView.indexPath(for: sender as! UICollectionViewCell)! as NSIndexPath
                
                controller.arrayDelegate = self
                controller.albumsPhotos = albumsArray[index.item].albumPictures
                controller.indexPath = index.item
                controller.uniqueID = albumsArray[index.item].uniqueID
                
                
                
                
            }
        } else {
            print("fcuk")
        }
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


