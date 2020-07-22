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
import Speech

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, AVAudioPlayerDelegate, SFSpeechRecognizerDelegate {
    
    
    
    var appDelegate: AppDelegate!
    var audioplayer:AVAudioPlayer!
    @IBOutlet weak var myTableView: UITableView!
    var isRecordingBeingPlayed:Bool = false
    var indexOfCurrentRecording:Int = -1 ///?? why is this -1
    var recordingIndexToEdit: Int?
    var updater : CADisplayLink! = nil
    var pendingAudioTranscription: NSManagedObject!
    
    // This variable is set to nil
    var isTranscriptionEnabled:Bool?
    
    /**
     3 cases -
        1. User has never given permission
        2. User has given permission
        3. User has denied permission
     */
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        self.appDelegate = appDelegate
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        myTableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditRecordingName" {
            let popup = segue.destination as! EditRecordingViewController
            popup.recordingIndexToEdit = self.recordingIndexToEdit
            
            popup.doneSaving = {
                [weak self] in self?.myTableView.reloadData()
            }
        } else if segue.identifier == "showTextOfRecording" {
            let transcribe = segue.destination as! AudioTranscriptionViewController
            transcribe.recordingToTranscribe = self.pendingAudioTranscription
    
        }
    }
    
    
    //Displays alert message
     func displayAlert(title:String, message:String) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
         present(alert, animated: true, completion: nil)
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
                let path = try FileHelper.getRecordingFileName(filename)
                audioplayer = try AVAudioPlayer(contentsOf: path)
                audioplayer.delegate = self
                audioplayer.play()
            } catch {
                displayAlert(title: "Ooops", message: "Playing Audio Failed :(")
            }
        }
        
        if let cell = myTableView.cellForRow(at: IndexPath(row: indexOfCurrentRecording, section: 0)) as? ListViewCell {
            changeButtonImage(cell.playPause, play: isRecordingBeingPlayed)
            updater = CADisplayLink(target: self, selector: #selector(self.trackAudio))
            updater.preferredFramesPerSecond = 60
            updater.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
        }
    }
    
    //progression bar
    @objc func trackAudio() {
        if let cell = myTableView.cellForRow(at: IndexPath(row: indexOfCurrentRecording, section: 0)) as? ListViewCell {
            let normalizedTime = Float(audioplayer.currentTime / audioplayer.duration)
            cell.progressBar.progress = normalizedTime
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let cell = myTableView.cellForRow(at: IndexPath(row: indexOfCurrentRecording, section: 0)) as? ListViewCell {
            changeButtonImage(cell.playPause, play: false)
        }
    }
    
    
    
    
    //changing image
    func changeButtonImage(_ button: UIButton, play: Bool) {
        UIView.transition(with: button, duration: 0.4,
                          options: .transitionCrossDissolve, animations: {
                            button.setImage(UIImage(systemName: play ? "pause.fill" : "play.fill"), for: .normal)
        }, completion: nil)
    }
    

    @objc func transcribeButtonAction(_ sender: UIButton) {
        if let indexPath = getViewIndexInTableView(tableView: myTableView, view: sender){
            pendingAudioTranscription = appDelegate.recordings[indexPath.row]
            //making a segue here manually
            performSegue(withIdentifier: "showTextOfRecording", sender: sender)
        }
    }

    //getting the row position of button
    func getViewIndexInTableView(tableView: UITableView, view: UIView) -> IndexPath? {
        let pos = view.convert(CGPoint.zero, to: tableView)
        return tableView.indexPathForRow(at: pos)
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if let indexPath = getViewIndexInTableView(tableView: myTableView, view: sender){
            playAudio(index: indexPath.row)
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
        //selector for transcription button
        
        // Check for current audio permissions
        // If not determined, or allowed - > show the button
        // If denied -> don't show the button
        
        switch SFSpeechRecognizer.authorizationStatus() {
        case .authorized, .notDetermined:
            //show this button when user has enabled transcription
            cell.transcriptionButton.isHidden = false
            cell.transcriptionButton.addTarget(self, action: #selector(transcribeButtonAction(_:)) , for: .touchUpInside)
            // show the button
        case .denied, .restricted:
            cell.transcriptionButton.isHidden = true
        @unknown default:
            cell.transcriptionButton.isHidden = true
        }
        
        cell.progressBar.progress = 0.0
        
        return cell
    }
    
    //deleting a recording
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //deleting from coreData
        appDelegate.deleteRecording(indexPath: indexPath.row)
        //deleting from the array
        appDelegate.recordings.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
//        tableView.indexPath.backgroundColor = #colorLiteral(red: 1, green: 0.5176470588, blue: 0.4862745098, alpha: 1)
//        tableView.indexPath.image = UIImage(systemName: "folder.badge.plus")
        
    }
    
    //editing a recording's name
    func tableView(_ tableView: UITableView,
                   leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "Edit") {(contextualAction, view, actionPerformed: (Bool) -> ()) in     self.recordingIndexToEdit = indexPath.row
            self.performSegue(withIdentifier: "toEditRecordingName", sender: nil)
            print(indexPath.row)
            actionPerformed(true)
        }
        edit.backgroundColor = #colorLiteral(red: 0.9647058824, green: 0.6705882353, blue: 0.4235294118, alpha: 1)
        edit.image = UIImage(systemName: "pencil")
        
        return UISwipeActionsConfiguration(actions: [edit])
    }
    
    //changing the height of the rows displayed 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Change this value to modify the cell's height
        return 146
    }
}
  

