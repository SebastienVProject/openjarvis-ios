//
//  HelpViewController.swift
//  openjarvis
//
//  Created by utilisateur on 12/06/2017.
//  Copyright © 2017 SVInfo. All rights reserved.
//

import UIKit
import Alamofire

class HelpViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var imageJarvisHelp: UIImageView!
    @IBOutlet weak var pickerViewType: UIPickerView!
    
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var textFieldEmail: UITextField!
    
    var pickerText: String!
    
    var pickerDataSource = ["Question", "Encouragement", "Evolution", "Bug"]
    var emailSaisiOK: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerViewType.dataSource = self
        pickerViewType.delegate = self
        textViewMessage.delegate = self
        
        pickerText = pickerDataSource[0]

        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = imageJarvisHelp.bounds
        imageJarvisHelp.addSubview(blurEffectView)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HelpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerText = pickerDataSource[row]
    }
    
  
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func isValidEmail(emailSaisi:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailSaisi)
    }
    
    @IBAction func ValidationFormulaire(_ sender: UIButton) {
        
        let emailOK: Bool = isValidEmail(emailSaisi: textFieldEmail.text!)
        let msgOK: Bool = !textViewMessage.text.isEmpty
        
        if emailOK && msgOK {
            var message = textViewMessage.text + "\n\n" + "(Message provenant de l'application openjarvis-ios"
            if !((textFieldEmail.text?.isEmpty)!) {
                message += ", et laissé par l'utilisateur suivant: " + textFieldEmail.text! + ")"
            }
            else {
                message += ")"
            }
            
            let titre = "openjarvis-ios - " + pickerText + " - "
            
            CreateIssue(titleIssue: titre, bodyIssue: message, typeIssue: pickerText)
        }
        else {
            if !emailOK {
                let alert = UIAlertController(title: "Saisir un email valide", message: "Merci à vous de saisir au préalable un email valide", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: "Saisir votre message", message: "Merci à vous de saisir au préalable un message", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func CreateIssue(titleIssue: String, bodyIssue: String, typeIssue: String) {
        let URL_POST = "https://api.github.com/repos/SebastienVProject/openjarvis-ios/issues"
        
        var headers: HTTPHeaders = [:]
        headers["Authorization"] = "token 36422879102eb5fd3388e580bf051445d831e086"
        
        var PARAMS : Parameters = [:]
        PARAMS["title"] = titleIssue
        PARAMS["body"] = bodyIssue
        PARAMS["labels"] = [typeIssue]
        
        Alamofire.request(URL_POST, method: .post, parameters: PARAMS, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            switch response.result {
            case .success:
                self.textFieldEmail.text=""
                self.textViewMessage.text=""
                let alert = UIAlertController(title: "Message envoyé", message: "Message envoyé avec succès.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            case .failure(let error):
                print(error)
            }
        }
        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the se
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     
     lected object to the new view controller.
    }
    */

}
