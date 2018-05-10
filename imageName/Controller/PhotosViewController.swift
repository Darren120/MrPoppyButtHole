//
//  PhotosViewController.swift
//  imageName
//
//  Created by Darren on 9/21/17.
//  Copyright © 2017 Darren. All rights reserved.
// MAIN PROJECT FILE. NOT A CLONE.
extension String {
    func containsString(string: String, instance: String) -> Bool {
        var int = 0
        var arrayOfCharacter = [Character]()
        for characters in string {
            arrayOfCharacter.append(characters)
        }
        
        for character in arrayOfCharacter {
            if instance.contains(character) {
                let value = arrayOfCharacter.index(of: character)
                arrayOfCharacter.remove(at: value!)
                print("fuckery")
            }
        }
        return false
    }
    
}
import UIKit
import CoreML
import Vision
import SVProgressHUD
let reuseIdentifier = "photoCell"
let defaults = UserDefaults.standard

class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate, UISearchResultsUpdating, clearSearch{
    
    
    func updateSearchResults(returnedFromSearch: Bool, clearSearch: Bool) {
        
        if clearSearch {
           

            searchController.searchBar.text = ""
            searchController.dismiss(animated: true, completion: nil)
        }
        if returnedFromSearch {
            
            if let data = defaults.object(forKey: "searchPhotos") as? Data {
                searchedArray = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
            }
            if let data = defaults.object(forKey: "photos") as? Data {
                photos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
                guard ciImages.count != photos.count else {return}
                ciImages.removeAll(keepingCapacity: true)
                for photo in photos {
                    let imagePath = getDocumentsDirectory().appendingPathComponent(photo.image)
                    if let image = CIImage(contentsOf: imagePath) {
                        if !ciImages.contains(image){
                            ciImages.append(image)
                            print("c")
                        }
                        
                    } else {
                        print("failure kys")
                        
                    }
                }
            }
        }
        
        saved()
        savedSearch()
        dismissKeyboard()
        photosCollection.reloadData()
    }
    
    var searchDelegate: searchArrayCheck?
    let picker = UIImagePickerController()
    var tap: UITapGestureRecognizer!
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var photosCollection: UICollectionView!
    var photos = [Photos]()
    var searchedArray = [Photos]()
    var picture: Photos!
    var label = UILabel()
    var noSearchResult = false
    var emptyArray = [Photos]()
    var ciImages = [CIImage]()
    var reload: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        
        label.layer.zPosition = 1
        label.text = "No search results found"
        print(view.frame.height)
        label.frame = CGRect(x: 0, y: 0, width: 500, height: view.frame.height - 500 )
        label.adjustsFontSizeToFitWidth = true
        view.addSubview(label)
        label.isHidden = true
        photosCollection.dataSource = self
        photosCollection.delegate = self
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
    
        if let data = defaults.object(forKey: "photos") as? Data {
            photos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
            guard ciImages.count != photos.count else {return}
            ciImages.removeAll(keepingCapacity: true)
           
            for photo in photos {
              let imagePath = getDocumentsDirectory().appendingPathComponent(photo.image)
                if let image = CIImage(contentsOf: imagePath) {
                    if !ciImages.contains(image){
                        ciImages.append(image)
                        
                    }
                    
                } else {
                    print("failure kys")
                
                }
            }
            
        }
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = false
        navigationController?.navigationBar.isHidden = false
        navigationController?.tabBarController?.tabBar.isHidden = false
        
        if let data = defaults.object(forKey: "photos") as? Data {
            photos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
             guard ciImages.count != photos.count else {return}
            ciImages.removeAll(keepingCapacity: true)
           
            for photo in photos {
                let imagePath = getDocumentsDirectory().appendingPathComponent(photo.image)
                if let image = CIImage(contentsOf: imagePath) {
                        ciImages.append(image)
                    }
            }
        }
      
        photosCollection.reloadData()
        
    }
    
    
    
    
    @objc func dismissKeyboard() {
        
        searchController.dismiss(animated: true, completion: nil)
        if (view.gestureRecognizers?.contains(tap))!{
            view.removeGestureRecognizer(tap)
        }
        view.gestureRecognizers?.removeAll()
        fillNavBarItem()
        self.view.endEditing(true)
        
        
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
        func characters() -> [Character] {
            var characters = [Character]()
            for character in searchController.searchBar.text! {
                characters.append(character)
            }
           return characters
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
            let searchText = searchResult()
            if searchText.first == "#" && searchText.last == "#" && searchText.count >= 5 {
              
                guard reload == true else {return}
                
               SVProgressHUD.show()
                self.searchController.searchBar.endEditing(true)
                
                DispatchQueue.global(qos: .userInitiated).async { [unowned self] in
                   
                    var array = [Int]()
                    var int = 0
                    for image in self.ciImages {
                        
                        
                        if self.detectImage(image: image, characters: searchResult(), int: int) == true {
                            array.append(int)
                            
                            self.noSearchResult = false
//                            self.searchedArray.append(self.photos[int])
                            
                        }
                        
                        int+=1
                    }
                    
                    SVProgressHUD.dismiss()
                    DispatchQueue.main.async { [unowned self] in
                        

                        for inte in array {
                            self.searchedArray.append(self.photos[inte])
                        }
                        self.reload = false
                        self.photosCollection.reloadData()
                        print("search \(self.searchedArray)")
                       
                    }
                   
                }
             
                
                
            } else{
            for pictures in photos {
                
                noSearchResult = false
                
                // test
               
                
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
                            photosCollection.reloadData()
                        }
                        
                    }

                
                
                
                
            }
        }
        }
            
        if number >= photos.count {
            noSearchResult = true
            number = 0
        }
        reload = true
        photosCollection.reloadData()
        
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if (searchText.isEmpty) {
            searchedArray.removeAll(keepingCapacity: true)
            photosCollection.reloadData()
            view.removeGestureRecognizer(tap)
            searchBar.showsCancelButton = false
            savedSearch()
        }
    }
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchedArray.removeAll(keepingCapacity: true)
        searchBar.text?.removeAll(keepingCapacity: true)
        dismissKeyboard()
        searchBar.showsCancelButton = false
        view.removeGestureRecognizer(tap)
        savedSearch()
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
        if noSearchResult {
            cell.isHidden = true
            label.isHidden = false
        } else {
            cell.isHidden = false
            label.isHidden = true 
        }
        if searchedArray.isEmpty {
            picture = photos[indexPath.item]
            
        } else {
            picture = searchedArray[indexPath.item]
        }
        cell.label.text = picture.name
        let path = getDocumentsDirectory().appendingPathComponent(picture.image)
        let uiImage = UIImage(contentsOfFile: path.path)
        cell.imageView.image = uiImage
       
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7       
        
        
        saved()
        self.savedSearch()
       
        return cell
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fullPicture") {
            print("okokokok")
            let controller: FullPictureController = segue.destination as! FullPictureController
            searchDelegate = controller
            let index: NSIndexPath = self.photosCollection.indexPath(for: sender as! UICollectionViewCell)! as NSIndexPath
            if searchedArray.isEmpty {
                controller.indexPath = index.item
                searchDelegate?.fillArray(array: photos, populate: false)
            } else {
                controller.delegate = self
                searchDelegate?.fillArray(array: searchedArray, populate: true)
                controller.indexPath = index.item
                print(searchedArray[index.item].name)
            }
        }
        
    }
    
    
    @objc func takePicBtn() {
        searchedArray.removeAll(keepingCapacity: true)
        searchController.searchBar.text?.removeAll(keepingCapacity: true)
        if view.gestureRecognizers?.contains(tap) == true {
            view.removeGestureRecognizer(tap)
            dismissKeyboard()
        }
        searchController.searchBar.reloadInputViews()
        photosCollection.reloadData()
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
        photosCollection.reloadData()
        picker.delegate = self
        picker.allowsEditing = false 
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        noSearchResult = false 
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {return}
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
            self.photos.append(picture)
            self.saved()
            self.savedSearch()
            self.photosCollection.reloadData()
        }
        
        ac.addAction(submitAction)
        present(ac, animated: true)
        saved()
        savedSearch()
        photosCollection.reloadData()
        
    }
    
    func detectImage(image: CIImage, characters: String, int: Int) -> Bool {
        
        var num = 0
        if #available(iOS 11.0, *) {
            
          
            guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {fatalError("failed")}
            let request = VNCoreMLRequest(model: model) { [] (request, error)  in
                guard let results = request.results as? [VNClassificationObservation] else {
                    fatalError("cant get results")
                }
                
//                print(results)
                for result in results.prefix(through: 4) {
                    if result.confidence > 0.51 {
                    
                        if result.identifier.localizedCaseInsensitiveContains(characters) {
//                          result.identifier.lowercased().contains(character)
                                num += 1
                        }
                    
                }
                }
            }

            let handler = VNImageRequestHandler(ciImage: image)
            do {
              
                try handler.perform([request])
                if num >= 3 {
                  
                    print(num)
                    print("true\(int)")
                    return true
                } else {
                    print("false\(int)")
                    return false
                }
            } catch {
              
                print(error)
                return false
            }
        } else {
            // Fallback on earlier versions
            return false
        }
        
    }
    func saved() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: photos)
        defaults.set(savedData, forKey: "photos")
    }
    func savedSearch() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: searchedArray)
        defaults.set(savedData, forKey: "searchPhotos")
    }
    func fillNavBarItem() {
        let pickImgButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pickImgBtn))
        let takeImgButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(takePicBtn))
        self.navigationItem.setRightBarButtonItems( [pickImgButton,takeImgButton], animated: true)
    }
    
    
}
