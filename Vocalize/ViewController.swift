//
//  ViewController.swift
//  Vocalize
//
//  Created by Maryam Heshmati on 7/7/20.
//  Copyright © 2020 Maryam Heshmati. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate {

    
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    //var audioplayer:AVAudioPlayer!
    var isAudioRecordingGranted: Bool!
    var numberOfRecords: Int = 0


    @IBOutlet weak var recordButton: UIButton! // aka buttonLabel
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setting up session
        recordingSession = AVAudioSession.sharedInstance()
        checkRecordPermission()
        
        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            numberOfRecords = number
        }
        
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
    
    // Getting the path directory
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //Displays alert message
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func startRecording(_ sender: UIButton) {
        //check if we have an active recorder
        if audioRecorder == nil {
            //need to start recording
            numberOfRecords += 1
            let filename = getDirectory().appendingPathComponent("\(numberOfRecords).m4a")
            
            
            //the format the recording we want it to be in
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 32000, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            
            //start audio recording
            do {
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
            
            //To make sure the recording number starts from the most recent one
            // ["myNumber": numberOfRecords]
            UserDefaults.standard.set(numberOfRecords, forKey: "myNumber")
        }
    }
    

}

