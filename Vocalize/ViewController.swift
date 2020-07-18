//
//  ViewController.swift
//  Vocalize
//
//  Created by Maryam Heshmati on 7/7/20.
//  Copyright © 2020 Maryam Heshmati. All rights reserved.
//

import UIKit
import AVFoundation
import CoreData
import StatusAlert
///installing status alert
///https://github.com/LowKostKustomz/StatusAlert


class ViewController: UIViewController, AVAudioRecorderDelegate {
    
    
    var appDelegate: AppDelegate!
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    var currentRecordingId: String = ""
    
    
    @IBOutlet weak var recordButton: UIButton! // aka buttonLabel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting up session
        recordingSession = AVAudioSession.sharedInstance()
        checkRecordPermission()
        
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        self.appDelegate = appDelegate
        
    }
    
    //Asking for permission
    func checkRecordPermission()
    {
        switch AVAudioSession.sharedInstance().recordPermission {
        case AVAudioSessionRecordPermission.granted:
            isAudioRecordingGranted = true
            break
        case AVAudioSessionRecordPermission.denied:
            isAudioRecordingGranted = false
            break
        case AVAudioSessionRecordPermission.undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                if allowed {
                    self.isAudioRecordingGranted = true
                } else {
                    self.isAudioRecordingGranted = false
                }
            })
            break
        default:
            break
        }
    }

    //Displays alert message
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func startRecording(_ sender: UIButton) {
        //check if we have an active recorder, if not start recording
        if audioRecorder == nil {
            do {
                //generate a unique string and append that to the folder where it holds all the recordings
                currentRecordingId = UUID().uuidString
                let filename = try FileHelper.getRecordingFileName(currentRecordingId)
                
                
                
                //the format the recording we want it to be in
                let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 32000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
                
                
                //start audio recording
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                
                recordButton.setImage(UIImage(named: "Stop"), for: UIControl.State.normal)
            } catch {
                displayAlert(title: "Ooops!", message: "Recording Failed :(")
            }
        } else {
            // stopping audio recording
            audioRecorder.stop()
            audioRecorder = nil
            recordButton.setImage(UIImage(named: "Record"), for: UIControl.State.normal)
            
            //stop and save that recording to coredata?
            appDelegate.saveRecording(fileName: currentRecordingId, displayName: appDelegate.newDefaultDisplayName())
            
            
            // Creating StatusAlert instance
            let statusAlert = StatusAlert()
            //statusAlert.image = UIImage(named: "Some image name")
            statusAlert.title = "Success"
            statusAlert.message = "Your entry has been successfully saved!"
            //statusAlert.canBePickedOrDismissed = true
            //alertShowingDuration = 2

            // Presenting created instance
            statusAlert.showInKeyWindow()
           
            
            


        }
    }
}

