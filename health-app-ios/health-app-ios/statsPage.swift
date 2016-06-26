
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
    
    let url = "http://52.201.248.82"
    
    let id = NSUserDefaults.standardUserDefaults().stringForKey("id")
    let fname = NSUserDefaults.standardUserDefaults().stringForKey("fname")
    let lname = NSUserDefaults.standardUserDefaults().stringForKey("lname")
    let phwn = NSUserDefaults.standardUserDefaults().stringForKey("phwn")
    let email = NSUserDefaults.standardUserDefaults().stringForKey("email")
    let bdate = NSUserDefaults.standardUserDefaults().stringForKey("bdate")
    
    let names = ["Sodium", "Fat", "Saturated Fat", "Calcium"]
    let numbers : [Double] = [10, 10, 5, 5]
    var warningArray = [String()]
    var labelArray = [String()]

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        update()
        y.hidden = true
        n.hidden = true
    }
    
    @IBAction func reload(sender: UIButton) {
        update()
    }
    
    let headers = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    
    let params = [
        "uuid": "Lh21idoIDHiohoid3iodj",
        "email": "datboi625625@gmail.com",
        "phone": "1231231234",
        "birth_date": "1999-05-10",
        "last_name": "boi",
        "first_name": "dat"
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
        
        Alamofire.request(.POST, url + "/schedule_appointment", parameters: params, headers: headers, encoding: .JSON)
            .responseJSON { response in
                print(response.request)
                
                if let JSON = response.result.value {
                    print(JSON)
                }
        }

    }
    @IBOutlet weak var wheel: UIActivityIndicatorView!
    
    func update() {
        
        wheel.hidden = false
        wheel.startAnimating()
        
        labelArray.removeAll()
        warningArray.removeAll()
        
        label.text = ""
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
                    let calc = JSON[0]["total_calcium"] as! Double
                    let chol = JSON[0]["total_cholesterol"] as! Double
                    let satfat = JSON[0]["total_sat_fat"] as! Double
                    let salt = JSON[0]["total_sodium"] as! Double
                    let fat = JSON[0]["total_total_fat"] as! Double
                    
                
                    let things = [salt, fat, satfat, calc]
                    
                    
                    let numLabels: Int = self.names.count
                    
                    if numLabels > 0 {
                        for i in 0..<numLabels {
                            if (self.numbers[i] + 2 < things[i]) {
                                self.warningArray.append("Excessive " + self.names[i])
                                
                            } else if (self.numbers[i] - 2 > things[i]) {
                                self.warningArray.append("Insufficient " + self.names[i])
                            }
                        }
                    }
                    
                    if (self.warningArray.count == 0) {
                        self.label.text = "Good Job!"
                    } else {
                        let string = self.warningArray.joinWithSeparator(",\n")
                        self.label.text = "Make an Appointment with your Doctor?"
                        self.otherlabel.text = string
                        self.y.hidden = false
                        self.n.hidden = false
                    }
                    
                    for i in 0..<self.names.count {
                        let why = "\(self.names[i]): \(things[i])"
                        self.labelArray.append(why)
                    }
                    
                    let statstring = self.labelArray.joinWithSeparator(",\n")
                    self.statslabel.text = "Stats: \n\(statstring)"
                    
                    self.wheel.stopAnimating()
                    self.wheel.hidden = true
                }
        }

        
    }
    
}
