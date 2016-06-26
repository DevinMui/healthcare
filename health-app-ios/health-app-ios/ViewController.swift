// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit
import SwiftyJSON
import Alamofire

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let white_list = ["doughnut", "hot dog", "hamburger", "donut", "burger", "pizza", "bagel", "sandwich", "coke", "coca cola", "soda", "coffee", "water", "chips", "fries", "candy", "redbull", "spaghetti", "pasta", "rice"]
    
    let url = "http://52.201.248.82"
    
    let save = NSUserDefaults.standardUserDefaults()
    let imagePicker: UIImagePickerController! = UIImagePickerController()
    
    @IBOutlet weak var titlelabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var API_KEY = "AIzaSyAdZdiG1Rybp0IgMf44DtPw4mH-vIEdhDg"
    
   
    @IBAction func Takepic(sender: UIButton) {
        
        if (UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) != nil {
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .Camera
                imagePicker.cameraCaptureMode = .Photo
                presentViewController(imagePicker, animated: true, completion: {})
            } else {
                print("Rear camera doesn't exist")
            }
        } else {
            print("Camera inaccessable")
        }
        titlelabel.hidden = true

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        print("Got an image")
        if let pickedImage:UIImage = (info[UIImagePickerControllerOriginalImage]) as? UIImage {
            let selectorToCall = Selector("imageWasSavedSuccessfully:didFinishSavingWithError:context:")
            UIImageWriteToSavedPhotosAlbum(pickedImage, self, selectorToCall, nil)
            
            let binaryImageData = base64EncodeImage(pickedImage)
            createRequest(binaryImageData)
        }
        imagePicker.dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user saves an image
        })
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        print("User canceled image")
        dismissViewControllerAnimated(true, completion: {
            // Anything you want to happen when the user selects cancel
        })
    }
    
    func imageWasSavedSuccessfully(image: UIImage, didFinishSavingWithError error: NSError!, context: UnsafeMutablePointer<()>){
        print("Image saved")
        if let theError = error {
            print("An error happened while saving the image = \(theError)")
        } else {
            self.imageView.image = image
        }
    }

    
    func resizeImage(imageSize: CGSize, image: UIImage) -> NSData {
        UIGraphicsBeginImageContext(imageSize)
        image.drawInRect(CGRectMake(0, 0, imageSize.width, imageSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        let resizedImage = UIImagePNGRepresentation(newImage)
        UIGraphicsEndImageContext()
        return resizedImage!
    }
    
    func base64EncodeImage(image: UIImage) -> String {
        var imagedata = UIImagePNGRepresentation(image)
        
        // Resize the image if it exceeds the 2MB API limit
        if (imagedata?.length > 2097152) {
            let oldSize: CGSize = image.size
            let newSize: CGSize = CGSizeMake(800, oldSize.height / oldSize.width * 800)
            imagedata = resizeImage(newSize, image: image)
        }
        
        return imagedata!.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
    }
    
    func createRequest(imageData: String) {
        // Create our request URL
        let request = NSMutableURLRequest(
            URL: NSURL(string: "https://vision.googleapis.com/v1/images:annotate?key=\(API_KEY)")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(
            NSBundle.mainBundle().bundleIdentifier ?? "",
            forHTTPHeaderField: "X-Ios-Bundle-Identifier")
        
        // Build our API request
        let jsonRequest: [String: AnyObject] = [
            "requests": [
                "image": [
                    "content": imageData
                ],
                "features": [
                    [
                        "type": "LABEL_DETECTION",
                        "maxResults": 10
                    ]
                ]
            ]
        ]
        
        // Serialize the JSON
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonRequest, options: [])
        
        // Run the request on a background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.runRequestOnBackgroundThread(request)
        });
        
    }
    
    func runRequestOnBackgroundThread(request: NSMutableURLRequest) {
        
        let session = NSURLSession.sharedSession()
        
        // run the request
        let task = session.dataTaskWithRequest(request, completionHandler: {data, response, error -> Void in
            self.analyzeResults(data!)
        })
        task.resume()
    }
    
    let headers = [
        "Accept": "application/json",
        "Content-Type": "application/json"
    ]
    
    func analyzeResults(dataToParse: NSData) {
        
        // Update UI on the main thread
        dispatch_async(dispatch_get_main_queue(), {
            
            
            // Use SwiftyJSON to parse results
            let json = JSON(data: dataToParse)
            let errorObj: JSON = json["error"]
            
            self.spinner.stopAnimating()
            self.imageView.hidden = true
            
            // Check for errors
            if (errorObj.dictionaryValue != [:]) {
            } else {
                // Parse the response
                print(json)
                let responses: JSON = json["responses"][0]
                
                // Get face annotations

                
                // Get label annotations
                let labelAnnotations: JSON = responses["labelAnnotations"]
                let numLabels: Int = labelAnnotations.count
                var labels: Array<String> = []
                if numLabels > 0 {
                    for index in 0..<numLabels {
                        let label = labelAnnotations[index]["description"].stringValue
                        labels.append(label)
                    }
                    var out = false
                    for label in labels {
                        
                        print(label)
                        // if it's not the last item add a comma
                        for item in self.white_list {
                            if (item == label) {
                                print(label)
                                Alamofire.request(.POST, self.url + "/add_data", parameters: ["food": label], headers: self.headers, encoding: .JSON)
                                    .responseJSON { response in
                                        print(response.request)
                                        
                                        if let JSON = response.result.value {
                                            print(JSON)
                                        }
                                }
                                out = true
                                break
                            }
                        }
                        if(out){
                            break
                        }
                    }
                } else {
                    print("error")
                }
            }
        })
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        imagePicker.delegate = self

        spinner.hidesWhenStopped = true
        
        save.setObject("Lh21idoIDHiohoid3iodj", forKey: "uuid")
        save.setObject("Dat", forKey: "fname")
        save.setObject("Boi", forKey: "lname")
        save.setObject("04-20-40", forKey: "bdate")
        save.setObject("datboi625625@gmail.com", forKey: "email")
        save.setObject("1231231234", forKey: "phwn")
        save.setObject("http://16e94129.ngrok.io", forKey: "url")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

