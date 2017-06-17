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
    @IBOutlet weak var keyAPIJarvis: UITextField!
    @IBOutlet weak var swichAudioServeur: UISwitch!
    @IBOutlet weak var swichAudioApplication: UISwitch!
    @IBOutlet weak var sizeFontBubble: UITextField!
    @IBOutlet weak var sizeFontBubbleJarvis: UITextField!
    @IBOutlet weak var sizeFontBubbleStepper: UIStepper!
    @IBOutlet weak var sizeFontBubbleJarvisStepper: UIStepper!

    @IBOutlet weak var taillePoliceText: UITextField!
    @IBOutlet weak var taillePoliceJarvisText: UITextField!
    
    @IBOutlet weak var labelUrl: UILabel!
    @IBOutlet weak var labelPort: UILabel!
    @IBOutlet weak var labelAPIKey: UILabel!
    @IBOutlet weak var labelAudioServer: UILabel!
    @IBOutlet weak var labelAudioApplication: UILabel!
    @IBOutlet weak var labelFont: UILabel!
    @IBOutlet weak var labelFontJarvis: UILabel!
    @IBOutlet weak var imageJarvisParam: UIImageView!
    @IBOutlet var GlobalView: UIView!
    
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
        keyAPIJarvis.text = ViewController.keyAPIJarvis
        
        labelUrl.text = NSLocalizedString("ParamLabelUrl", comment: "Enter URL")
        labelPort.text = NSLocalizedString("ParamLabelPort", comment: "Enter port number")
        labelAPIKey.text = NSLocalizedString("ParamLabelAPIKey", comment: "Enter API Key for Jarvis")
        labelAudioServer.text = NSLocalizedString("ParamLabelAudioServeur", comment: "enabling audio on the server")
        labelAudioApplication.text = NSLocalizedString("ParamLabelAudioAppli", comment: "enabling audio in the application")
        labelFont.text = NSLocalizedString("ParamFont", comment: "font size in the bubble")
        labelFontJarvis.text = NSLocalizedString("ParamFontJarvis", comment: "font size in the jarvis bubble")
        
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = GlobalView.bounds
        imageJarvisParam.addSubview(blurEffectView)
        
        if UIDevice.current.model == "iPad" {
            //on adapte la taille de police au format tablette
            let ajustement: CGFloat = 10
            labelUrl.font = labelUrl.font.withSize(labelUrl.font.pointSize + ajustement)
            labelPort.font = labelPort.font.withSize(labelPort.font.pointSize + ajustement)
            labelAPIKey.font = labelAPIKey.font.withSize(labelAPIKey.font.pointSize + ajustement)
            labelAudioServer.font = labelAudioServer.font.withSize(labelAudioServer.font.pointSize + ajustement)
            labelAudioApplication.font = labelAudioApplication.font.withSize(labelAudioApplication.font.pointSize + ajustement)
            labelFont.font = labelFont.font.withSize(labelFont.font.pointSize + ajustement)
            labelFontJarvis.font = labelFontJarvis.font.withSize(labelFontJarvis.font.pointSize + ajustement)
            
            urlJarvisText.font = urlJarvisText.font?.withSize((urlJarvisText.font?.pointSize)! + ajustement)
            portJarvisText.font = portJarvisText.font?.withSize((portJarvisText.font?.pointSize)! + ajustement)
            keyAPIJarvis.font = keyAPIJarvis.font?.withSize((keyAPIJarvis.font?.pointSize)! + ajustement)
            taillePoliceText.font = taillePoliceText.font?.withSize((taillePoliceText.font?.pointSize)! + ajustement)
            taillePoliceJarvisText.font = taillePoliceJarvisText.font?.withSize((taillePoliceJarvisText.font?.pointSize)! + ajustement)
        }
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
    
    @IBAction func updateKeyApiJarvis(_ sender: UITextField) {
        ViewController.keyAPIJarvis = sender.text
        updatePlistParametres(key: "keyApiJarvis", valeur: ViewController.keyAPIJarvis ?? "")
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
