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

    @IBOutlet weak var textHelpIntroduction: UITextView!
    @IBOutlet weak var labelEmail: UILabel!
    @IBOutlet weak var labelType: UILabel!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelButtonSent: UIButton!
    
    @IBOutlet var globalView: UIView!
    @IBOutlet weak var imageJarvisHelp: UIImageView!
    @IBOutlet weak var pickerViewType: UIPickerView!
    
    @IBOutlet weak var textViewMessage: UITextView!
    @IBOutlet weak var textFieldEmail: UITextField!
    
    var pickerText: String!
    
    var pickerDataSource = [NSLocalizedString("pickerQuestion", comment: "Question"), NSLocalizedString("pickerEncouragement", comment: "Encouragement"), NSLocalizedString("pickerEvolution", comment: "Evolution"), NSLocalizedString("pickerBug", comment: "Bug")]
    var emailSaisiOK: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HelpViewController.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        textHelpIntroduction.text = NSLocalizedString("helpIntroduction", comment: "Introductory text on the help screen")
        labelEmail.text = NSLocalizedString("helpLabelEmail", comment: "your email")
        labelType.text = NSLocalizedString("helpLabelType", comment: "message type")
        labelMessage.text = NSLocalizedString("helpLabelMessage", comment: "your message")
        labelButtonSent.setTitle(NSLocalizedString("helpButtonLabel", comment: "send your message"), for: .normal)
        
        pickerViewType.dataSource = self
        pickerViewType.delegate = self
        textViewMessage.delegate = self
        
        pickerText = pickerDataSource[0]

        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        blurEffectView.frame = globalView.bounds
        imageJarvisHelp.addSubview(blurEffectView)
        print(blurEffectView.frame)
        print(globalView.frame)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HelpViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        //textFieldEmail.becomeFirstResponder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func rotated() {
        imageJarvisHelp.subviews.first?.removeFromSuperview()
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.dark))
        blurEffectView.frame = globalView.bounds
        imageJarvisHelp.addSubview(blurEffectView)
        print("rotated")
        print(blurEffectView.frame)
        print(globalView.frame)
        
        if UIDevice.current.orientation.isPortrait {
            print ("portrait")
        } else {
            print("landscape")
        }
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
            var message = textViewMessage.text + "\n\n" + NSLocalizedString("gitIssueMessage", comment: "Message from the openjarvis-ios application")
            if !((textFieldEmail.text?.isEmpty)!) {
                message += NSLocalizedString("gitIssueUser", comment: "User in message") + textFieldEmail.text! + ")"
            }
            else {
                message += ")"
            }
            
            let titre = "openjarvis-ios - " + pickerText + " - "
            
            CreateIssue(titleIssue: titre, bodyIssue: message, typeIssue: pickerText)
        }
        else {
            if !emailOK {
                let alert = UIAlertController(title: NSLocalizedString("popupEmailKOTitle", comment: "Thank you for entering a valide email Title"), message: NSLocalizedString("popupEmailKOMessage", comment: "Thank you for entering a valide email Message"), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
            else {
                let alert = UIAlertController(title: NSLocalizedString("popupMessageKOTitle", comment: "Enter a message"), message: NSLocalizedString("popupMessageKOMessage", comment: "Thank you for entering a message"), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func CreateIssue(titleIssue: String, bodyIssue: String, typeIssue: String) {
        let URL_POST = "https://api.github.com/repos/SebastienVProject/openjarvis-ios/issues"
        
        var headers: HTTPHeaders = [:]
        headers["Authorization"] = "token 8adc04cbea1d6d76e308c198f00a72be1424466b"
        
        var PARAMS : Parameters = [:]
        PARAMS["title"] = titleIssue
        PARAMS["body"] = bodyIssue
        PARAMS["labels"] = [typeIssue]
        
        Alamofire.request(URL_POST, method: .post, parameters: PARAMS, encoding: JSONEncoding.default, headers: headers).responseJSON { response in
            
            switch response.result {
            case .success:
                self.textFieldEmail.text=""
                self.textViewMessage.text=""
                let alert = UIAlertController(title: NSLocalizedString("popupSentMessageTitle", comment: "Sent message"), message: NSLocalizedString("popupSentMessageMessage", comment: "message sent successfully"), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                break
            case .failure(let error):
                print(error)
            }
        }
    }
}
