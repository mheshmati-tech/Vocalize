//
//  AudioTranscriptionViewController.swift
//  Vocalize
//
//  Created by Maryam Heshmati on 7/15/20.
//  Copyright © 2020 Maryam Heshmati. All rights reserved.
//

import UIKit
import Speech
import CoreData

//protocol AudioTranscriptionDelegate {
//    func transcriptionPermission(permission:Bool)
//}

class AudioTranscriptionViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        self.appDelegate = appDelegate
        initializeLabel()
    }
    
    
    @IBOutlet weak var transcribeText: UILabel!
    var recordingToTranscribe:NSManagedObject!
    var appDelegate: AppDelegate!
    var isTranscriptionEnabled:Bool!
//    var transcriptionDelegate: AudioTranscriptionDelegate?
    
    
    //Displays alert message
     func displayAlert(title:String, message:String) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         present(alert, animated: true, completion: nil)
     }
    
    //permission
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    
                    do {
                        let path = try FileHelper.getRecordingFileName((self.recordingToTranscribe.value(forKey: "fileName") as? String)!)
                        self.transcribeAudio(url: path)
                        self.isTranscriptionEnabled = true
//                        self.transcriptionDelegate?.transcriptionPermission(permission: true)
//
                    } catch {
                        self.displayAlert(title: "Permission Error", message: "Unable to find recording file to transcribe")
                    }
                } else {
                    self.transcribeText.text = "Transcription permission was declined."
                    self.isTranscriptionEnabled = false
//                    self.transcriptionDelegate?.transcriptionPermission(permission: false)
                }
            }
        }
    }
    
    func initializeLabel(){
        if let transcripton = recordingToTranscribe.value(forKey: "transcription") as? String {
            transcribeText.text = transcripton
        } else {
            //we don't have trancription and need permission from user
            requestTranscribePermissions()
        }
    }
    
    
    //audio transcripption
    func transcribeAudio(url: URL) {
        // create a new recognizer and point it at our audio
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: url)
        
        // start recognition!
        recognizer?.recognitionTask(with: request) { [unowned self] (resultParameter, error) in
            // abort if we didn't get any transcription back
            guard let result = resultParameter else {
                print("There was an error: \(error!)")
                return
            }
            
            // if we got the final transcription back, print it
            if result.isFinal {
                // pull out the best transcription...
                
                //TODO: add a loading icon while waiting
                //TODO: disable the button if the user has declined permission
                //TODO:
                //load transcription data from core data
                self.updateRecording(transcription: result.bestTranscription.formattedString )
            }
        }
    }
    
    
    func updateRecording(transcription:String){
        recordingToTranscribe.setValue(transcription, forKey: "transcription")
        self.transcribeText.text = transcription
        appDelegate.saveContext()
    }
    
    
    
    
    //    func authorizeSR() {
    //        SFSpeechRecognizer.requestAuthorization { authStatus in
    //
    //            OperationQueue.main.addOperation {
    //                switch authStatus {
    //                case .authorized:
    //                    self.transcriptionButton.isEnabled = true
    //
    //                case .denied:
    //                    self.transcriptionButton.isEnabled = false
    //                    self.transcriptionButton.setTitle("Speech recognition access denied by user", for: .disabled)
    //
    //                case .restricted:
    //                    self.transcriptionButton.isEnabled = false
    //                    self.transcriptionButton.setTitle("Speech recognition restricted on device", for: .disabled)
    //
    //                case .notDetermined:
    //                    self.transcriptionButton.isEnabled = false
    //                    self.transcriptionButton.setTitle("Speech recognition not authorized", for: .disabled)
    //                }
    //            }
    //        }
    //    }
    
    
    
    
}
