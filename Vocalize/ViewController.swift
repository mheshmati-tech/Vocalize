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

class ViewController: UIViewController, AVAudioRecorderDelegate {

    
    
    var recordingSession:AVAudioSession!
    var audioRecorder:AVAudioRecorder!
    var isAudioRecordingGranted: Bool!
    var appDelegate: AppDelegate!
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
    
    
    // Getting the path directory
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    func getRecordingsFolder() throws -> URL {
        let fileName = getDirectory().appendingPathComponent("Vocalize").appendingPathComponent("Recordings")
        
        
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: fileName.path, isDirectory: &isDirectory) {
            //need to create a folder
           try FileManager.default.createDirectory(at: fileName, withIntermediateDirectories: true, attributes: nil)
        }
        return fileName
    }
    
    
    
    @IBAction func startRecording(_ sender: UIButton) {
        //check if we have an active recorder, if not start recording
        if audioRecorder == nil {
            do {
            //generate a unique string and append that to the folder where it holds all the recordings
            currentRecordingId = UUID().uuidString
            let filename = try getRecordingsFolder().appendingPathComponent("\(currentRecordingId).m4a")
            
            
            
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
//            do {
                appDelegate.saveRecording(fileName: currentRecordingId, displayName: appDelegate.newDefaultDisplayName() )
                
//            } catch {
//                displayAlert(title: "Ooops!", message: "Recording Failed :(")
//            }
            
        }
    }
    

}

