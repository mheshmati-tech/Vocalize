//
//  EditRecordingViewController.swift
//  Vocalize
//
//  Created by Maryam Heshmati on 7/13/20.
//  Copyright © 2020 Maryam Heshmati. All rights reserved.
//

import UIKit
import CoreData

class EditRecordingViewController: UIViewController {

    
    var recordingIndexToEdit: Int?
    var appDelegate: AppDelegate!
    var doneSaving: (() -> ())?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
          return
        }
        self.appDelegate = appDelegate

        if let index = recordingIndexToEdit {
            let recording = appDelegate.recordings[index]
            recordingTextField.text = recording.value(forKeyPath: "displayName") as? String
        }
    }
    
    @IBOutlet weak var recordingTextField: UITextField!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
  
    @IBAction func save(_ sender: UIButton) {
        
        if let doneSaving = doneSaving {
            doneSaving()
        }
        appDelegate.updateRecordingName(userEntryForDisplayName: (recordingTextField.text)!, indexOfRecordingBeingUpdated: recordingIndexToEdit!)
        dismiss(animated: true)
        
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}
