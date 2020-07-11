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

class ListViewController:UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var numberOfRecords: Int = 0
    var audioplayer:AVAudioPlayer!
    var indexOfCurrentRecording:Int = 0
    @IBOutlet weak var myTableView: UITableView!
    var isRecordingBeingPlayed:Bool = false
   
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let number:Int = UserDefaults.standard.object(forKey: "myNumber") as? Int {
            numberOfRecords = number
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
    
    func getRecordingFileName(index:Int) -> URL {
        return getDirectory().appendingPathComponent("\(index + 1).m4a")
    }
    
    //play the audio
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let path = getRecordingFileName(index: indexPath.row + 1)
//        do {
//            audioplayer = try AVAudioPlayer(contentsOf: path)
//            audioplayer.play()
//        } catch {
//            displayAlert(title: "Ooops", message: "Recording Failed :(")
//
//        }
//    }
    
    /**
    
     Cell is tapped ->
     if indexOfCell == indexOfCurrentRecording {
        set isRecordingBeingPlayed = !isRecordingBeingPlayed
     } else {
        set isRecordingBeingPlayed (for indexOfCurrentRecording) = false
        indexOfCurrentRecording = indexOfCell
        set isRecordingBeingPlayed (for currentCell) = true
     }
     */
    
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
            let path = getRecordingFileName(index: indexOfCurrentRecording)
            do {
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
            return numberOfRecords
        }
    
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AudioRecordingCell", for: indexPath) as! ListViewCell
            
            cell.audioLabel.text = String(indexPath.row + 1)
            
            //selector is a method reference
              cell.playPause.addTarget(self, action: #selector(buttonTapped(_:)),
                                  for: .touchUpInside)
            return cell
        }
    
}


