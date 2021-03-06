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
        //every time the table is rendered, it's reloaded
        myTableView.reloadData()
    }
    
    //performing segues
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
    
    //progression bar tracker
    @objc func trackAudio() {
        if let cell = myTableView.cellForRow(at: IndexPath(row: indexOfCurrentRecording, section: 0)) as? ListViewCell {
            let normalizedTime = Float(audioplayer.currentTime / audioplayer.duration)
            cell.progressBar.progress = normalizedTime
        }
    }
    
    //did audio  finish playing
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
    
    //getting the row position of button
    func getViewIndexInTableView(tableView: UITableView, view: UIView) -> IndexPath? {
        let pos = view.convert(CGPoint.zero, to: tableView)
        return tableView.indexPathForRow(at: pos)
    }
    
    @objc func transcribeButtonAction(_ sender: UIButton) {
        if let indexPath = getViewIndexInTableView(tableView: myTableView, view: sender){
            pendingAudioTranscription = appDelegate.recordings[indexPath.row]
            //making a segue here manually
            performSegue(withIdentifier: "showTextOfRecording", sender: sender)
        }
    }
    
    @objc func buttonTapped(_ sender: UIButton) {
        if let indexPath = getViewIndexInTableView(tableView: myTableView, view: sender){
            playAudio(index: indexPath.row)
        }
    }
    
    
    //The number of cells rendered
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appDelegate.recordings.count
    }
    
    //The content of each cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioRecordingCell", for: indexPath) as! ListViewCell
        
        let recording = appDelegate.recordings[indexPath.row]
        let name = recording.value(forKeyPath: "displayName") as? String
        cell.audioLabel.text = name
        
        //selector is a method reference
        cell.playPause.addTarget(self, action: #selector(buttonTapped(_:)),
                                 for: .touchUpInside)
        
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
        if let sentiment = appDelegate.recordings[indexPath.row].value(forKey: "sentimentValue") as? String {
            if sentiment == "positive" {
                cell.sentiment.text = "😃"
            } else if sentiment == "negative" {
                cell.sentiment.text = "☹️"
            } else if sentiment == "neutral" {
                cell.sentiment.text = "😐"
            }
        }
        return cell
    }
    
    //Swiping actions
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
    
    //deleting recording
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") {(contextualAction, view, actionPerformed: (Bool) -> ()) in
            self.appDelegate.deleteRecording(indexPath: indexPath.row)
            //deleting from the array
            self.appDelegate.recordings.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            actionPerformed(true)
        }
        delete.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
        delete.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    //changing the height of the rows displayed 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 146
    }
}


