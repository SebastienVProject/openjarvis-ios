//
//  gestionMessages.swift
//  openjarvis
//
//  Created by utilisateur on 04/06/2017.
//  Copyright © 2017 SVInfo. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import Speech

var montexte: UITextView!
var reponseJarvis: UITextView!
var imageJarvis: UIImageView!
var bulle: UITextView!

let distanceApresBulleJarvis = 30.0
let distanceApresBulleUser = 10.0
let bulleFontSize = 10
let bulleFontName = "Arial"
let bulleFontSizeJarvis = 11
let bulleFontNameJarvis = "Verdana"

let speechSynthesizer = AVSpeechSynthesizer()

public func TraiterDemande(bulleText: String, scrollVue: UIScrollView){
    AjouterBulle(jarvis: false, bulleText: bulleText, scrollVue: scrollVue)
    
    let URL_GET = ViewController.urljarvis + ":" + ViewController.portjarvis + "/get"
    var PARAMS : Parameters
    if !ViewController.audioServeur {
        PARAMS = ["order": bulleText, "mute": "true"]
    } else {
        PARAMS = ["order": bulleText, "mute": "false"]
    }
    print(URL_GET)
    print(PARAMS)
    
    Alamofire.request(URL_GET, parameters: PARAMS).responseJSON { response in
        
        if response.result.isSuccess {
            if let retour = response.result.value as? NSArray
            {
                let JSON = retour[0] as! NSDictionary
                if let answer = JSON["answer"]{
                    AjouterBulle(jarvis: true, bulleText: answer as! String, scrollVue: scrollVue)
                    if ViewController.audioApplication {
                        ReponseAudioDevice(reponse: answer as! String)
                    }
                }
            }
        } else {
            print("Requete invalide")
            print (response)
        }
    }
}

public func ReponseAudioDevice(reponse: String){
    
    let speechUtterance = AVSpeechUtterance(string: reponse)
    speechUtterance.voice=AVSpeechSynthesisVoice(language: "fr-FR")
    speechUtterance.volume = 10
    speechSynthesizer.speak(speechUtterance)
}

public func AjouterBulle(jarvis: Bool, bulleText: String, scrollVue: UIScrollView){
    
    var positionBulleSuivante = 10.0
    if let lastComponent = scrollVue.subviews[scrollVue.subviews.count - 1] as? UITextView{
        if jarvis {
            positionBulleSuivante = Double(lastComponent.frame.maxY) + distanceApresBulleUser
        } else  {
            positionBulleSuivante = Double(lastComponent.frame.maxY) + distanceApresBulleJarvis
        }
    }
    
    let bulleLargeur : Double = (Double(UIScreen.main.bounds.size.width)*60.0)/100.0
    var bulleLeft : Double
    if jarvis {
        bulleLeft = 42.0
    } else {
        bulleLeft = Double(UIScreen.main.bounds.size.width) - bulleLargeur - 40
    }
    
    //gestion de l'avatar
    if jarvis {
        imageJarvis = UIImageView(image: UIImage(named: "jarvisWhite.png"))
        imageJarvis.frame = CGRect(x: 0, y: positionBulleSuivante, width: 47, height: 48)
        //self.view.addSubview
        scrollVue.addSubview(imageJarvis)
    } else {
        imageJarvis = UIImageView(image: UIImage(named: "blueBulle.png"))
        imageJarvis.frame = CGRect(x: Double(UIScreen.main.bounds.size.width) - 45, y: positionBulleSuivante, width: 8, height: 14)
        scrollVue.addSubview(imageJarvis)
    }
    
    //gestion de la bulle à afficher
    //couleurBulle = UIColor(red: 241/255, green: 23/255, blue: 193/255, alpha: 1)      couleur verte sympa
    //couleurBulle = UIColor(red: 1/255, green: 144/255, blue: 146/255, alpha: 1)       couleur fushia
    var couleurBulle : UIColor
    var policeBulle : String
    var policeSizeBulle : Int
    var couleurTexte : UIColor
    if jarvis {
        couleurBulle = UIColor.white
        policeBulle = bulleFontNameJarvis
        policeSizeBulle = bulleFontSizeJarvis
        couleurTexte = UIColor(red: 241/255, green: 23/255, blue: 193/255, alpha: 1)
    } else {
        couleurBulle = UIColor(red: 1/255, green: 144/255, blue: 146/255, alpha: 1)
        policeBulle = bulleFontName
        policeSizeBulle = bulleFontSize
        couleurTexte = UIColor.white
    }
    bulle = UITextView()
    bulle.backgroundColor = couleurBulle
    bulle.textColor = couleurTexte
    bulle.layer.cornerRadius = 10
    bulle.font = UIFont(name: policeBulle, size: CGFloat(policeSizeBulle))
    bulle.text = bulleText
    bulle.frame = CGRect(x: bulleLeft, y: positionBulleSuivante, width: bulleLargeur, height: 80.0)
    
    //ajustement de la hauteur de la bulle en fonction de son contenu
    let fixedWidth = bulle.frame.size.width
    bulle.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    let newSize = bulle.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
    var newFrame = bulle.frame
    newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
    bulle.frame = newFrame;
    
    //let heightVue = newFrame.size.height + CGFloat(positionBulleSuivante)
    
    scrollVue.addSubview(bulle)
    //scrollVue.contentSize.height = 1000
}
