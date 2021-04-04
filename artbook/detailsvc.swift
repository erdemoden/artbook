//
//  detailsvc.swift
//  artbook
//
//  Created by erdem öden on 16.02.2021.
//  Copyright © 2021 erdem öden. All rights reserved.
//

import UIKit
import CoreData
class detailsvc: UIViewController , UIImagePickerControllerDelegate , UINavigationControllerDelegate {

    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var nametext: UITextField!
    @IBOutlet weak var artisttext: UITextField!
    @IBOutlet weak var yeartext: UITextField!
    @IBOutlet weak var savebutton: UIButton!
    
    var chosenpainting = ""
    var chosenpaintingid : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenpainting != ""{
            
            savebutton.isHidden = true
            //coredata
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Paintings")
           
            let idstring = chosenpaintingid?.uuidString
            
            fetch.predicate = NSPredicate(format: "id = %@", idstring!)
            
            fetch.returnsObjectsAsFaults = false
            do{
               
                let oldu = try context.fetch(fetch)
                if oldu.count > 0{
                for olmuş in oldu as! [NSManagedObjectModel]{
                    if let name = olmuş.value(forKey: "name") as? String{
                        nametext.text = name
                        
                    }
                    if let artist = olmuş.value(forKey: "artis") as? String{
                                           artisttext.text = artist
                                           
                                       }
                    if let year = olmuş.value(forKey: "year") as? Int{
                                           yeartext.text = String(year)
                                           
                                       }
                    if let imageol = olmuş.value(forKey: "image") as? Data{
                        image.image = UIImage(data: imageol)
                                           
                                       }
                    }
                }
                
            }
            catch{
                print("Hata")
            }
        }
        else{
            savebutton.isHidden = false
            savebutton.isEnabled = false
            nametext.text = ""
            artisttext.text = ""
            yeartext.text = ""
        }
        
        
       
        
        // Recognizers
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(hidekeyboard))
        view.addGestureRecognizer(gesture)
    
        
        image.isUserInteractionEnabled = true
        let imagegesture = UITapGestureRecognizer(target: self, action: #selector(selectimage))
        image.addGestureRecognizer(imagegesture)
    
    
    }
    
    @IBAction func savebutton(_ sender: Any) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        
        let newpainting = NSEntityDescription.insertNewObject(forEntityName: "Paintings", into: context)
        
    // Att/Users/erdemoden/Desktop/ios deneme/artbook/artbook.xcodeprojributes
        
        newpainting.setValue(nametext.text!, forKey: "name")
        newpainting.setValue(artisttext.text, forKey: "artist")
        
        if let year = Int(yeartext.text!){
            newpainting.setValue(year, forKey: "year")
        }
        newpainting.setValue(UUID(), forKey: "id")
        
        let data = image.image!.jpegData(compressionQuality: 0.5)
        newpainting.setValue(data, forKey: "image")
        do{
            try context.save()
            print("success")
        } catch{
            print("Error")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name("newdata"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    @objc func hidekeyboard(){
        view.endEditing(true)
    }

    @objc func selectimage(){
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        //güzel bişey
        picker.allowsEditing = true
        self.present(picker,animated: true,completion: nil);
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image.image = info[.editedImage] as? UIImage
        savebutton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }

}
