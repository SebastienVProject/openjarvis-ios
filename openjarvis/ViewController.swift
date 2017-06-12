//
//  ViewController.swift
//  openjarvis
//
//  Created by utilisateur on 04/06/2017.
//  Copyright © 2017 SVInfo. All rights reserved.
//

import UIKit
import Speech
import SwiftyPlistManager

class ViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    static var urljarvis: String!
    static var portjarvis: String!
    static var audioServeur: Bool!
    static var audioApplication: Bool!
    static var fontSize: Int!
    static var fontSizeJarvis: Int!
    static var fontStyle: String!
    static var fontStyleJarvis: String!
    static var keyAPIJarvis: String?
    
    static var heightContainer: Double!
    
    @IBOutlet weak var imageJarvis: UIImageView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var scrollVue: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var MessageVue: UIView!
    
    var HandleDeleteAllBubble: ((UIAlertAction?) -> Void)!
    
    let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "fr-FR"))!
    
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    
    var whatIwant = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        microphoneButton.isEnabled = false
        
        speechRecognizer.delegate = self
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            var isButtonEnabled = false
            
            switch authStatus {
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        
        //on recupere les parametres de l'applicatif
        SwiftyPlistManager.shared.getValue(for: "urlJarvis", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.urljarvis = result as! String
            }
        }
        SwiftyPlistManager.shared.getValue(for: "portJarvis", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.portjarvis = result as! String
            }
        }
        SwiftyPlistManager.shared.getValue(for: "audioApplication", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.audioApplication = result as! Bool
            }
        }
        SwiftyPlistManager.shared.getValue(for: "audioServeur", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.audioServeur = result as! Bool
            }
        }
        SwiftyPlistManager.shared.getValue(for: "fontSize", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.fontSize = result as! Int
            }
        }
        SwiftyPlistManager.shared.getValue(for: "fontSizeJarvis", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.fontSizeJarvis = result as! Int
            }
        }
        SwiftyPlistManager.shared.getValue(for: "fontStyle", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.fontStyle = result as! String
            }
        }
        SwiftyPlistManager.shared.getValue(for: "fontStyleJarvis", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.fontStyleJarvis = result as! String
            }
        }
        SwiftyPlistManager.shared.getValue(for: "keyApiJarvis", fromPlistWithName: "parametres") { (result, err) in
            if err == nil {
                ViewController.keyAPIJarvis = result as? String
            }
        }
        
        ViewController.heightContainer = 10
        /*
         let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
         let blurEffectView = UIVisualEffectView(effect: blurEffect)
         blurEffectView.frame = imageJarvis.bounds
         imageJarvis.addSubview(blurEffectView)
         */
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.handleLongPress(_:)))
        lpgr.minimumPressDuration = 1.2
        scrollVue.addGestureRecognizer(lpgr)
        
        HandleDeleteAllBubble = { (action: UIAlertAction!) -> Void in
            while self.containerView.subviews.count > 0 {
                self.containerView.subviews.first?.removeFromSuperview()
            }
            ViewController.heightContainer = 10
        }
    }
    
    func handleLongPress(_ gesture: UILongPressGestureRecognizer){
        if gesture.state != .began { return }
        let alert = UIAlertController(title: "Supprimer l'historique", message: "Merci à vous de confirmer la suppression de l'historique", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Delete", style: UIAlertActionStyle.destructive, handler: HandleDeleteAllBubble))
        alert.addAction(UIAlertAction(title: "Annuler", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        //showPopup(sender: cell, mode: "edit", text: todoList[row], row: row)
    }


    

    /*
    @IBAction func purgeTapped(_ sender: AnyObject) {
       /*  while containerView.subviews.count > 0 {
            containerView.subviews.first?.removeFromSuperview()
        }*/
    }*/
    
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
            microphoneButton.setImage(UIImage(named: "micro.png"), for: .normal)
        } else {
            startRecording()
            microphoneButton.setTitle("Stop Recording", for: .normal)
            microphoneButton.setImage(UIImage(named: "microON.png"), for: .normal)
        }
        
        //AjouterBulle(jarvis: true, bulleText: "C'est fait", scrollVue: scrollVue)
    }
    
    func startRecording() {
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.textView.text = result?.bestTranscription.formattedString
                //self.whatIwant = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.microphoneButton.isEnabled = true
                TraiterDemande(bulleText: self.textView.text, containerVue: self.containerView, scrollVue: self.scrollVue, messageVue: self.MessageVue)
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        textView.text = ""
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
}


