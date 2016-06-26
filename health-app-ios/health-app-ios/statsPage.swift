
//
//  statsPage.swift
//  health-app-ios
//
//  Created by Jesse Liang on 6/26/16.
//  Copyright © 2016 Jesse Liang. All rights reserved.
//

import UIKit
import Alamofire

class statsPage: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var otherlabel: UILabel!
    @IBOutlet weak var statslabel: UILabel!
    
    @IBOutlet weak var y: UIButton!
    @IBOutlet weak var n: UIButton!
    
    let url = NSUserDefaults.standardUserDefaults().stringForKey("url")
    let fname = NSUserDefaults.standardUserDefaults().stringForKey("fname")
    let lname = NSUserDefaults.standardUserDefaults().stringForKey("lname")
    let phwn = NSUserDefaults.standardUserDefaults().stringForKey("phwn")
    let email = NSUserDefaults.standardUserDefaults().stringForKey("email")
    let bdate = NSUserDefaults.standardUserDefaults().stringForKey("bdate")
    let id = NSUserDefaults.standardUserDefaults().stringForKey("uuid")
    
    let names = ["Calcium", "Carbs", "Cholesterol", "Iron", "Protein", "Saturated Fat", "Sodium", "Fat", "Trans Fat", "Vitamin A", "Vitamin C"]
    let numbers = [400, 400, 400, 400, 400, 400, 400, 400, 400, 400, 400]
    var warningArray = [String()]


    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        update()
        y.hidden = true
        n.hidden = true
    }
    
    let headers = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    
    let params : [String : String] = [
        "uuid": id,
        "email": email,
        "phone": phwn,
        "birth_date": bdate,
        "last_name": lname,
        "first_name": fname
    ]
    
    @IBAction func n(sender: UIButton) {
        label.text = "OK."
        y.hidden = true
        n.hidden = true
    }
    @IBAction func y(sender: UIButton) {
        label.text = "An Appointment has been made"
        y.hidden = true
        n.hidden = true
        
        Alamofire.request(.POST, url! + "/schedule_appointment", parameters: params, headers: headers, encoding: .JSON)
            .responseJSON { response in
                print(response.request)
                
                if let JSON = response.result.value {
                    print(JSON)
                }
        }

    }
    func update() {
        
        warningArray.removeAll()
        
        label.text = "Loading"
        otherlabel.text = ""
        statslabel.text = ""
        
        y.hidden = true
        n.hidden = true
        
        let urlstring = url as String!
        print(urlstring)
        Alamofire.request(.GET, urlstring + "/get_data")
            .responseJSON { response in
                print(response.request)
                
                if let JSON = response.result.value {
                    print(JSON)
                    let calc = JSON[0]["total_calcium"] as! Int
                    let carb = JSON[0]["total_carvs"] as! Int
                    let chol = JSON[0]["total_cholesterol"] as! Int
                    let iron = JSON[0]["total_iron"] as! Int
                    let prot = JSON[0]["total_protein"] as! Int
                    let satfat = JSON[0]["total_sat_fat"] as! Int
                    let salt = JSON[0]["total_sodium"] as! Int
                    let fat = JSON[0]["total_fat"] as! Int
                    let transfat = JSON[0]["total_trans_fat"] as! Int
                    let vita = JSON[0]["total_vit_a"] as! Int
                    let vitc = JSON[0]["total_vit_c"] as! Int
                
                    let things = [calc, carb, chol, iron, prot, satfat, salt, fat, transfat, vita, vitc]

                    let numLabels: Int = self.names.count
                    
                    if numLabels > 0 {
                        for i in 0..<numLabels {
                            if (self.numbers[i] + 50 < things[i]) {
                                self.warningArray.append("Too Much " + self.names[i])
                                
                            } else if (self.numbers[i] - 50 > things[i]) {
                                self.warningArray.append("Not Enough " + self.names[i])
                            }
                        }
                    }
                    
                    if (self.warningArray.count == 0) {
                        self.label.text = "Good Job!"
                    } else {
                        let string = self.warningArray.joinWithSeparator(", \n")
                        self.label.text = "Make an Appointment with your Doctor?"
                        self.otherlabel.text = string
                        self.y.hidden = false
                        self.n.hidden = false
                    }
                    
                    
                    self.statslabel.text = "Stats: \n Calcium : \(calc),\n Carbs : \(carb),\n Cholesterol : \(chol),\n Iron : \(iron),\n Protein : \(prot),\n Saturated Fat : \(satfat),\n Sodium : \(salt),\n Fat : \(fat),\n Trans Fat : \(transfat),\n Vitamin A : \(vita),\n Vitamin C : \(vitc)"
                }
        }

        
    }
    
}
