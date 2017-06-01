//
//  ViewController.swift
//  TechNiche
//
//  Created by Manas Mishra on 31/05/17.
//  Copyright © 2017 Manas Mishra. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate {
    var menuArray = [[String: Any?]]()
    var subMenuArray = [[String: Any?]]()
    var itemArray = [[String: Any?]]()
    var selectedMenuIndex = IndexPath(row: 0, section: 0)
    var arrayForBool = [Bool]()
    var sectionValue: Int?
    var cartItems = [[String: Any?]]()

    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var subMenuTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationController?.navigationBar.barTintColor = UIColor(hex: 0xD0EA94, alpha: 1.0)
        cartButton.isHidden = true
        reload()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        itemArray.removeAll()
        menuCollectionView.reloadData()
        subMenuTableView.reloadData()
        reloadCartButton()
    }
    @IBAction func reload(_ sender: Any) {
        reload()
    }
    func reload() {
        ConnectionManager.get("http://35.154.42.68/testing/productList", showProgressView: true, parameter: nil, completionHandler: {(status, response) in
            if status == 200{
                if let responseDict = response as? [[String: Any?]]{
                    self.menuArray = responseDict
                    if self.menuArray.count > 0{
                        self.subMenuArray = (self.menuArray[0])["childrens"] as! [[String : Any?]]
                        for _ in self.subMenuArray{
                            self.arrayForBool.append(false)
                        }
                        DispatchQueue.main.async {
                            self.subMenuTableView.delegate = self
                            self.subMenuTableView.dataSource = self
                        }
                        
                    }
            DispatchQueue.main.async {
                self.menuCollectionView.delegate = self
                self.menuCollectionView.dataSource = self
                        self.menuCollectionView.reloadData()
                        self.subMenuTableView.reloadData()
                    }
                }
            }else{
                DispatchQueue.main.async {
                    let vc = Utilities.alertViewController(title: "NetworkError!", msg: "Please try again!!")
                    self.present(vc, animated: true, completion: nil)
                }
            }
        })
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       
        return menuArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HeadingCell", for: indexPath) as! MenuCollectionViewCell
        cell.title.text = (menuArray[indexPath.row])["name"] as! String
        if indexPath.row == selectedMenuIndex.row {
            cell.bottomBar.backgroundColor = UIColor(hex: 0xFFAC34, alpha: 1.0)
        }else{
            cell.bottomBar.backgroundColor = UIColor(hex: 0xD0E186, alpha: 1.0)
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        subMenuArray.removeAll()
        if let dictArray = (menuArray[indexPath.row])["childrens"] as? [[String: Any?]]{
            subMenuArray = dictArray
            subMenuTableView.delegate = self
            subMenuTableView.dataSource = self
            if let cell = collectionView.cellForItem(at: selectedMenuIndex) as? MenuCollectionViewCell{
                cell.bottomBar.backgroundColor = UIColor(hex: 0xD0E186, alpha: 1.0)
            }
            selectedMenuIndex = indexPath
            
            let cell = collectionView.cellForItem(at: selectedMenuIndex) as! MenuCollectionViewCell
            cell.bottomBar.backgroundColor = UIColor(hex: 0xFFAC34, alpha: 1.0)
            itemArray.removeAll()
            subMenuTableView.reloadData()
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sectionValue != nil{
            if section == sectionValue!{
                return itemArray.count
            }
        }
        
        return 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemTableViewCell
            cell.containerView.layer.borderWidth = 0.5
            cell.containerView.layer.borderColor = UIColor.lightText.cgColor
            cell.containerView.layer.cornerRadius = 10
            cell.itemName.text = (itemArray[indexPath.row])["name"] as? String
            let price = (itemArray[indexPath.row])["price"] as? Int
            cell.itemPrice.text = "Rs \(price!).00"
            cell.itemQuantity.text = (itemArray[indexPath.row])["unit"] as? String
            cell.minusButton.isHidden = true
            cell.numberLabel.isHidden = true
            cell.addButton.addTarget(self, action: #selector(ViewController.addNewButtonTapped(sender:)), for: .touchUpInside)
            cell.minusButton.addTarget(self, action: #selector(ViewController.minusButtonTapped(sender:)), for: .touchUpInside)
            cell.addButton.tag = indexPath.row
            cell.minusButton.tag = indexPath.row
        
        for each in cartItems{
            if each["_id"] as! String == (itemArray[indexPath.row])["_id"] as! String{
                let count = each["count"] as! Int
                cell.numberLabel.text = String(count)
                cell.minusButton.isHidden = false
                cell.numberLabel.isHidden = false
                break
            }
        }
        return cell
    }
    func addNewButtonTapped(sender: UIButton){
        let index = sender.tag
        var eachCount = 0
        var itemNotFound = true
        for each in cartItems{
            
            if each["_id"] as! String == (itemArray[index])["_id"] as! String{
                var newEach = [String: Any?]()
                newEach["_id"] = each["_id"]
                newEach["item"] = each["item"]
                newEach["count"] = each["count"] as! Int + 1
                cartItems[eachCount] = newEach
                subMenuTableView.reloadData()
                eachCount = eachCount + 1
                itemNotFound = false
                break
            }
            eachCount = eachCount + 1
        }
        if itemNotFound || eachCount == 0{
            let eachItem = itemArray[index]
            var newEach = [String: Any?]()
            newEach["_id"] = eachItem["_id"]
            newEach["item"] = eachItem
            newEach["count"] =  1
            cartItems.append(newEach)
            subMenuTableView.reloadData()
        }
        reloadCartButton()
    }
    func minusButtonTapped(sender: UIButton){
        let index = sender.tag
        var eachCount = 0
        for each in cartItems{
            
            if each["_id"] as! String == (itemArray[index])["_id"] as! String{
                if each["count"] as! Int > 0{
                    var newEach = [String: Any?]()
                    newEach["_id"] = each["_id"]
                    newEach["item"] = each["item"]
                    newEach["count"] = each["count"] as! Int - 1
                    cartItems[eachCount] = newEach
                    subMenuTableView.reloadData()
                }
                eachCount = eachCount + 1
                break
            }
            eachCount = eachCount + 1
        }
        reloadCartButton()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        print(subMenuArray.count)
        return subMenuArray.count
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
     func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 5
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = tableView.dequeueReusableCell(withIdentifier: "SectionHeaderTableViewCell") as! SectionHeaderTableViewCell
        headerView.title.text = (subMenuArray[section])["name"] as? String
        headerView.tag = section
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleTap(sender:)))
        tapGestureRecognizer.delegate = self
        headerView.addGestureRecognizer(tapGestureRecognizer)
    
        return headerView
    }
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            // handling code
            itemArray.removeAll()
            sectionValue = sender.view?.tag
            itemArray = (subMenuArray[sectionValue!])["products"] as! [[String : Any?]]
            subMenuTableView.reloadData()
        }
    }
    func reloadCartButton() -> () {
        var totalPrice = 0
        var itemCount = 0
        for each in cartItems{
            let item = each["item"] as? [String: Any]
            let price = item?["price"] as! Int
            let count = (each["count"] as! Int)
            itemCount = count + itemCount
            totalPrice = (count * price) + totalPrice
        }
        if itemCount == 0{
            cartButton.isHidden = true
        }else if itemCount > 0{
            let cartText = "\(itemCount) items in Cart Rs.\(totalPrice)/-"
            cartButton.isHidden = false
            cartButton.setTitle(cartText, for: .normal)
        }
    }
    @IBAction func cartButtonTapped(_ sender: Any) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CheckOutViewController") as! CheckOutViewController
        vc.cartItemArray = cartItems
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
}








































 
