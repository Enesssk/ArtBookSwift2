//
//  DetailsViewController.swift
//  ArtBookAppSwift2
//
//  Created by Enes Kala on 2.03.2024.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameText: UITextField!
    
    @IBOutlet weak var artistNameText: UITextField!
    
    @IBOutlet weak var yearText: UITextField!
    
    var chosenName = ""
    var chosenId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if chosenName != "" {
            //coreData
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Arts")
            let idString = chosenId?.uuidString
            fetch.predicate = NSPredicate(format: "id = %@", idString!)
            fetch.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetch)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        if let name = result.value(forKey: "name") as? String {
                            nameText.text = name
                        }
                        if let artistName = result.value(forKey: "artistName") as? String {
                            artistNameText.text = artistName
                        }
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        if let data = result.value(forKey: "imageView") as? Data {
                            let image = UIImage(data: data)
                            imageView.image = image
                        }
                    }
                }
                
            }catch{
                print("Error info")
            }
            
        }else{
            
        }
        
        
        imageView.isUserInteractionEnabled = true
        
        let gestureImageRecognizer = UITapGestureRecognizer(target: self, action: #selector(changePic))
        
        imageView.addGestureRecognizer(gestureImageRecognizer)
        

        
        
        
    }
    
    @objc func changePic(){
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true)
        
    }
    

    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newArts = NSEntityDescription.insertNewObject(forEntityName: "Arts", into: context)
        
        newArts.setValue(nameText.text!, forKey: "name")
        newArts.setValue(artistNameText.text!, forKey: "artistName")
        
        if let year = Int(yearText.text!) {
            newArts.setValue(year, forKey: "year")
        }
        newArts.setValue(UUID(), forKey: "id")
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        newArts.setValue(data, forKey: "imageView")
        
        do{
            try context.save()
            print("Save is success")
        }catch{
            print("Error at save")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    

    

}
