//
//  FileHelperMethods.swift
//  Vocalize
//
//  Created by Maryam Heshmati on 7/15/20.
//  Copyright © 2020 Maryam Heshmati. All rights reserved.
//

import Foundation

class FileHelper {
    
    static func getDirectory() -> URL
    {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
     //getting the folder directory
    static func getRecordingsFolder() throws -> URL {
        let fileName = getDirectory().appendingPathComponent("Vocalize").appendingPathComponent("Recordings")
        
        
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: fileName.path, isDirectory: &isDirectory) {
            //need to create a folder
            try FileManager.default.createDirectory(at: fileName, withIntermediateDirectories: true, attributes: nil)
        }
        return fileName
    }
    
    
    //getting folder for where the recordings are being saved at
    static func getRecordingFileName(_ fileName:String) throws -> URL {
        return try getRecordingsFolder().appendingPathComponent("\(fileName).m4a")
    }

}
