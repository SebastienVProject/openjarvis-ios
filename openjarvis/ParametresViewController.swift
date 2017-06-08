//
//  ParametresViewController.swift
//  openjarvis
//
//  Created by utilisateur on 05/06/2017.
//  Copyright © 2017 SVInfo. All rights reserved.
//

import UIKit
import SwiftyPlistManager

class ParametresViewController: UIViewController {

    @IBOutlet weak var urlJarvisText: UITextField!
    @IBOutlet weak var portJarvisText: UITextField!
    @IBOutlet weak var swichAudioServeur: UISwitch!
    @IBOutlet weak var swichAudioApplication: UISwitch!
    @IBOutlet weak var sizeFontBubble: UITextField!
    @IBOutlet weak var sizeFontBubbleJarvis: UITextField!
    @IBOutlet weak var sizeFontBubbleStepper: UIStepper!
    @IBOutlet weak var sizeFontBubbleJarvisStepper: UIStepper!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        urlJarvisText.text = ViewController.urljarvis
        portJarvisText.text = ViewController.portjarvis
        swichAudioServeur.setOn(ViewController.audioServeur, animated: false)
        swichAudioApplication.setOn(ViewController.audioApplication, animated: false)
        sizeFontBubble.text = String(ViewController.fontSize)
        sizeFontBubbleJarvis.text = String(ViewController.fontSizeJarvis)
        sizeFontBubbleStepper.value = Double(ViewController.fontSize)
        sizeFontBubbleJarvisStepper.value = Double(ViewController.fontSizeJarvis)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func updateAudioServeur(_ sender: UISwitch) {
        ViewController.audioServeur = sender.isOn
        updatePlistParametres(key: "audioServeur", valeur: ViewController.audioServeur)
    }
    @IBAction func updateAudioApplication(_ sender: UISwitch) {
        ViewController.audioApplication = sender.isOn
        updatePlistParametres(key: "audioApplication", valeur: ViewController.audioApplication)
    }
    
    @IBAction func updateUrlJarvis(_ sender: UITextField) {
        ViewController.urljarvis = sender.text
        updatePlistParametres(key: "urlJarvis", valeur: ViewController.urljarvis)
    }

    @IBAction func updatePortJarvis(_ sender: UITextField) {
        ViewController.portjarvis = sender.text
        updatePlistParametres(key: "portJarvis", valeur: ViewController.portjarvis)
    }
    
    func updatePlistParametres(key: String, valeur: Any){
        
        SwiftyPlistManager.shared.save(valeur, forKey: key, toPlistWithName: "parametres") { (err) in
            if err == nil {
                print("Value successfully saved into plist.")
            }
        }
       
    }
    
    @IBAction func updateFontSizeBubble(_ sender: UIStepper) {
        sizeFontBubble.text = String(Int(sender.value))
        ViewController.fontSize = Int(sender.value)
        updatePlistParametres(key: "fontSize", valeur: ViewController.fontSize)
    }
    
    @IBAction func updateFontSizeBubbleJarvis(_ sender: UIStepper) {
        sizeFontBubbleJarvis.text = String(Int(sender.value))
        ViewController.fontSizeJarvis = Int(sender.value)
        updatePlistParametres(key: "fontSizeJarvis", valeur: ViewController.fontSizeJarvis)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
