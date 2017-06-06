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
    
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var scrollVue: UIScrollView!
    @IBOutlet weak var textView: UITextView!
    
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
        
        
    }
    
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
        } else {
            startRecording()
            microphoneButton.setTitle("Stop Recording", for: .normal)
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
                TraiterDemande(bulleText: self.textView.text, scrollVue: self.scrollVue)
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
        
        textView.text = "Say something, I'm listening!"
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
}


