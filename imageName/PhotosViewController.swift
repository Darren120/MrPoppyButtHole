//
//  PhotosViewController.swift
//  imageName
//
//  Created by Darren on 9/21/17.
//  Copyright © 2017 Darren. All rights reserved.
//

import UIKit
import Photos
let reuseIdentifier = "photoCell"
let defaults = UserDefaults.standard
class PhotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchResultsUpdating {
    
    @IBOutlet weak var photoCollectionCell: UICollectionView!
    var photos = [Photos]()
    var searchedArray = [Photos]()
    var searchController = UISearchController()
    var resultsController = UICollectionViewController()
    override func viewDidLoad() {
        super.viewDidLoad()
//        resultsController.collectionView?.dataSource = self
//        resultsController.collectionView?.delegate = self
        searchController = UISearchController(searchResultsController: resultsController)
        let searchBar = searchController.searchBar
        searchBar.frame = CGRect(x: 0, y: 7, width: UIScreen.main.bounds.width, height: 33)
        photoCollectionCell.addSubview(searchBar)
        
        
        photoCollectionCell.dataSource = self
        photoCollectionCell.delegate = self
        
        if let data = defaults.object(forKey: "photos") as? Data {
            photos = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Photos] ?? [Photos]()
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateSearchResults(for searchController: UISearchController) {

        searchedArray = photos.filter({ (picture: Photos) -> Bool in
            if picture.name.contains(searchController.searchBar.text!) {
                return true
            } else {
                return false
            }
        })

    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == resultsController.collectionView {
            return searchedArray.count
        } else {
            return photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! photoCell
        
        let picture = photos[indexPath.item]
        cell.label.text = picture.name
        let path = getDocumentsDirectory().appendingPathComponent(picture.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
        cell.layer.borderWidth = 2
        cell.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        saved()
//        if collectionView == resultsController.collectionView {
//            let picture = searchedArray[indexPath.item]
//            cell.label.text = picture.name
//            let path = getDocumentsDirectory().appendingPathComponent(picture.image)
//            cell.imageView.image = UIImage(contentsOfFile: path.path)
//            cell.imageView.layer.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).cgColor
//            cell.layer.borderWidth = 2
//            cell.layer.cornerRadius = 3
//            cell.layer.cornerRadius = 7
//            saved()
//
//        }

        return cell
    }
    @IBAction func takePicBtn(_ sender: Any) {
    }
    @IBAction func pickImgBtn(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        if let jpegData = UIImageJPEGRepresentation(image, 80){
            try? jpegData.write(to: imagePath)
        }
        
        let picture = Photos(name: "", image: imageName)
        dismiss(animated: true)
        
        let ac = UIAlertController(title: "Picture Title", message: "Give your picture a name.", preferredStyle: .alert)
        ac.addTextField()
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] (action: UIAlertAction) in
            let pictureTitle = ac.textFields![0]
            picture.name = pictureTitle.text!
            self.photoCollectionCell.reloadData()
            self.saved()
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
        photos.append(picture)
        photoCollectionCell.reloadData()
        saved()
    }
    func getDocumentsDirectory() -> URL {
        //This call for path always returns an array containing one thing, the user's personal directory.
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = path[0]
        return documentsDirectory
        
    }
    
    func saved() {
        let savedData = NSKeyedArchiver.archivedData(withRootObject: photos)
        defaults.set(savedData, forKey: "photos")
    }
    //layout stuff
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 3 - 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
}
