//
//  CheckOutViewController.swift
//  TechNiche
//
//  Created by Manas Mishra on 01/06/17.
//  Copyright © 2017 Manas Mishra. All rights reserved.
//

import UIKit

class CheckOutViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var cartItemArray: [[String: Any?]]?

    @IBOutlet weak var priceStackView: UIStackView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var itemTableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        itemTableView.delegate = self
        itemTableView.dataSource = self
        reloadCart()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cartItemArray!.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! ItemTableViewCell
        let item = cartItemArray?[indexPath.row]["item"] as? [String: Any?]
        cell.containerView.layer.borderWidth = 0.5
        cell.containerView.layer.borderColor = UIColor.lightText.cgColor
        cell.containerView.layer.cornerRadius = 8
        cell.itemName.text = (item)?["name"] as? String
        let price = (item)?["price"] as? Int
        cell.itemPrice.text = "Rs \(price!).00"
        cell.itemPrice.layer.cornerRadius = 8.0
        cell.itemQuantity.text = (item)?["unit"] as? String
        cell.addButton.addTarget(self, action: #selector(CheckOutViewController.addNewButton(sender:)), for: .touchUpInside)
        cell.minusButton.addTarget(self, action: #selector(CheckOutViewController.minusButton(sender:)), for: .touchUpInside)
        cell.addButton.tag = indexPath.row
        cell.minusButton.tag = indexPath.row
        let count = cartItemArray?[indexPath.row]["count"] as? Int
        cell.numberLabel.text = String(describing: count!)
        let netPrice = count! * price!
        cell.netPrice.text = "Rs \(netPrice).00"
        return cell
    }
    func addNewButton(sender: UIButton){
        let index = sender.tag
        var eachCount = 0
        let each = cartItemArray?[index]
        var newEach = [String: Any?]()
        newEach["_id"] = each?["_id"]
        newEach["item"] = each?["item"]
        newEach["count"] = each?["count"] as! Int + 1
        cartItemArray?[index] = newEach
        itemTableView.reloadData()
        reloadCart()
        
    }
    func minusButton(sender: UIButton){
        let index = sender.tag
        let each = cartItemArray?[index]
        var newEach = [String: Any?]()
        newEach["_id"] = each?["_id"]
        newEach["item"] = each?["item"]
        newEach["count"] = each?["count"] as! Int - 1
        let count = (newEach)["count"] as? Int
        cartItemArray?[index] = newEach
        reloadCart()
        if count == 0 {
            cartItemArray?.remove(at: index)
        }
        itemTableView.reloadData()
    }

    func reloadCart() -> () {
        var totalPrice = 0
        var itemCount = 0
        for each in cartItemArray!{
            let item = each["item"] as? [String: Any]
            let price = item?["price"] as! Int
            let count = (each["count"] as! Int)
            itemCount = count + itemCount
            totalPrice = (count * price) + totalPrice
        }
        priceLabel.text = "Rs \(totalPrice).00"
        totalPriceLabel.text = "Rs \(totalPrice).00"
    }
    @IBAction func dismiss(_ sender: Any) {
        let vc = self.navigationController?.viewControllers[0] as! ViewController
        vc.cartItems = cartItemArray!
        navigationController?.popViewController(animated: true)
    }

}
