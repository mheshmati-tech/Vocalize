//
//  ListViewController.swift
//  Vocalize
//
//  Created by Maryam Heshmati on 7/8/20.
//  Copyright © 2020 Maryam Heshmati. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import CoreData

class ListViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    
    var audioplayer:AVAudioPlayer!
    var indexOfCurrentRecording:Int = -1
    @IBOutlet weak var myTableView: UITableView!
    var isRecordingBeingPlayed:Bool = false
    var appDelegate: AppDelegate!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        self.appDelegate = appDelegate
    
    }
    
    
    // Getting the path directory
    func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    //getting the folder directory
    func getRecordingsFolder() throws -> URL {
        let fileName = getDirectory().appendingPathComponent("Vocalize").appendingPathComponent("Recordings")
        
        
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: fileName.path, isDirectory: &isDirectory) {
            //need to create a folder
            try FileManager.default.createDirectory(at: fileName, withIntermediateDirectories: true, attributes: nil)
        }
        return fileName
    }
    
    //Displays alert message
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    //getting folder for where the recordings are being saved at
    func getRecordingFileName(_ fileName:String) throws -> URL {
        return try getRecordingsFolder().appendingPathComponent("\(fileName).m4a")
    }
    
    //playing audio
    func playAudio(index:Int) {
        
        // if clicked on existing cell
        if index == indexOfCurrentRecording {
            if isRecordingBeingPlayed {
                isRecordingBeingPlayed = false
                // Pause exiting recording if any
                if audioplayer != nil {
                    audioplayer.pause()
                }
                
            } else {
                isRecordingBeingPlayed = true
                //play from where left off and not the begging
                if audioplayer != nil {
                    audioplayer.play()
                }
            }
            //clicked on a different recording/cell
        } else {
            // Pause exiting recording if any
            if audioplayer != nil {
                audioplayer.pause()
            }
            
            if let cell = myTableView.cellForRow(at: IndexPath(row: indexOfCurrentRecording, section: 0)) as? ListViewCell {
                changeButtonImage(cell.playPause, play: false)
            }
            
            indexOfCurrentRecording = index
            isRecordingBeingPlayed = true
            // Play new selected recording
            let filename = appDelegate.recordings[indexOfCurrentRecording].value(forKey: "fileName") as! String
            
            
            do {
                let path = try getRecordingFileName(filename)
                audioplayer = try AVAudioPlayer(contentsOf: path)
                audioplayer.play()
            } catch {
                displayAlert(title: "Ooops", message: "Playing Audio Failed :(")
            }
        }
        
        if let cell = myTableView.cellForRow(at: IndexPath(row: indexOfCurrentRecording, section: 0)) as? ListViewCell {
            changeButtonImage(cell.playPause, play: isRecordingBeingPlayed)
        }
    }
    
    
    
    
    //changing image
    func changeButtonImage(_ button: UIButton, play: Bool) {
        UIView.transition(with: button, duration: 0.4,
                          options: .transitionCrossDissolve, animations: {
                            button.setImage(UIImage(named: play ? "pause" : "play"), for: .normal)
        }, completion: nil)
    }
    
    
    
    
    //getting the row position of button
    func getViewIndexInTableView(tableView: UITableView, view: UIView) -> IndexPath? {
        let pos = view.convert(CGPoint.zero, to: tableView)
        return tableView.indexPathForRow(at: pos)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        // Let's localize the index of the button using a helper method
        // and also localize the Song i the database
        if let indexPath = getViewIndexInTableView(tableView: myTableView, view: sender){
            playAudio(index: indexPath.row)
            // Change the tapped button to a Stop image
            //changeButtonImage(sender, play: false)
        }
    }
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.recordings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioRecordingCell", for: indexPath) as! ListViewCell
        
        let recording = appDelegate.recordings[indexPath.row]
        let name = recording.value(forKeyPath: "displayName") as? String
        cell.audioLabel.text = name
        
        //selector is a method reference
        cell.playPause.addTarget(self, action: #selector(buttonTapped(_:)),
                                 for: .touchUpInside)
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //deleting from coreData
        appDelegate.deleteRecording(indexPath: indexPath.row)
        //deleting from the array
        appDelegate.recordings.remove(at: indexPath.row)
//        let indexPaths = [indexPath]
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}


