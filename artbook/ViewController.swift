//
//  ViewController.swift
//  artbook
//
//  Created by erdem öden on 16.02.2021.
//  Copyright © 2021 erdem öden. All rights reserved.
//

import UIKit
import CoreData
class ViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableview: UITableView!
    var namerarray = [String]()
    var idarray = [UUID]()
    
    var selectedpainting = ""
    var selectedpaintingid : UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem:
        UIBarButtonItem.SystemItem.add, target: self, action: #selector(addbuttonclicked))
        tableview.delegate = self
        tableview.dataSource = self
        getdata()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getdata), name: NSNotification.Name(rawValue: "newdata"), object: nil) 
    }
    @objc func addbuttonclicked(){
        selectedpainting = ""
        performSegue(withIdentifier: "todetailsvc", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return namerarray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = namerarray[indexPath.row]
        return cell
    }
    
    @objc func getdata(){
        namerarray.removeAll(keepingCapacity: true)
        idarray.removeAll(keepingCapacity: false)
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchrequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchrequest.returnsObjectsAsFaults = false
        do{
           let results =  try context.fetch(fetchrequest)
            for result in results as! [NSManagedObject]{
                if let name =  result.value(forKey: "name") as? String{
                    self.namerarray.append(name)
                    
                }
                if let id = result.value(forKey: "id") as? UUID{
                    self.idarray.append(id)
                }
                self.tableview.reloadData()
            }
        }catch{
            print("error")
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "todetailsvc"{
            let destinationvc = segue.destination as! detailsvc
            destinationvc.chosenpainting = selectedpainting
            destinationvc.chosenpaintingid = selectedpaintingid
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedpainting = namerarray[indexPath.row]
        selectedpaintingid = idarray[indexPath.row]
        performSegue(withIdentifier: "todetailsvc", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appdelegate.persistentContainer.viewContext
            
            let fetch = NSFetchRequest<NSFetchRequestResult>.init(entityName: "Paintings")
            fetch.returnsObjectsAsFaults = false
            let idstring = idarray[indexPath.row].uuidString
            fetch.predicate = NSPredicate(format: "id = %@", idstring)
            do{
                let results = try context.fetch(fetch)
                if results.count>0{
                    for result in results as! [NSManagedObject]{
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idarray[indexPath.row]{
                                context.delete(result)
                                namerarray.remove(at: indexPath.row)
                                idarray.remove(at: indexPath.row)
                                self.tableview.reloadData()
                                do{
                                   try  context.save()
                                    
                                }
                                catch {
                                    print("error")
                                }
                                break
                            }
                        }
                    }
                }
            }
            catch {
                print("Hata")
                
            }
    }

    }

}
