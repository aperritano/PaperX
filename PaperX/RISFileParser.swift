//
//  ParseFileHelper.swift
//  PaperX
//
//  Created by Anthony Perritano on 3/13/16.
//  Copyright © 2016 so.raven. All rights reserved.
//

import Foundation

class RISFileParser {
    static let sharedInstance = RISFileParser()
    
    func isSectionStart(line:String) -> Bool {
        //print("doing reges \(line)")
        let regex = try? NSRegularExpression(pattern: "\\b[A-Z0-9]{2}\\b\\s\\s-",
                                             options:[])
        let matches = regex!.matchesInString(line, options: [], range: NSMakeRange(0, line.characters.count))
        //print(matches)
        if matches.count > 0  {
            return true
        }
        return false
    }
    
    class func readFile(filePath:String) -> [[String:AnyObject]] {        
        var lines = [String]()
        do {
            // Get the contents
            let contents = try NSString(contentsOfFile: filePath, encoding: NSUTF8StringEncoding)
            lines = contents.componentsSeparatedByString("\n")

        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
        return parseLines(lines)
    }
    
    class func parseLines(lines:[String]) -> [[String:AnyObject]] {
        var results = [[String:AnyObject]]()
        var tempDict = [String:AnyObject]()
        var sectionKey : String?
        
        for index in 0 ..< lines.count {
            let line = lines[index]
//            progressView.progress = Float(index)/Float(totalLineCount)
            if sharedInstance.isSectionStart(line) {
                let sections = line.characters.split {$0 == "-"}.map { String($0) }
               // print("\(index) - \(line)")
                let key = sections[0].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                var lastSection = ""
                if sections.count > 1 {
                    lastSection = sections[1].stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                }
                
                sectionKey =  key
                
                if key == "TY" {
                    tempDict = [String:String]()
                    tempDict[key] = lastSection
                } else if key == "ER" {
                    tempDict[key] = ""
                    results.append(tempDict)
                } else if key == "A1" {
                    //print(line)
                    if let authors = tempDict[key] {
                        
                        var a = authors as! [String]
                        
                        a.append(lastSection)
                        tempDict[key] = a
//                        print( tempDict[sectionKey])
                        // now val is not nil and the Optional has been unwrapped, so use it
                    } else {
                        //print(lastSection)
                        let n : [String] = [lastSection]
                        tempDict[key] = n
                    }
                } else {
                    tempDict[key] = lastSection
                }
            } else {
                
                let val = tempDict[sectionKey!]! as! String
                
                tempDict[sectionKey!] = val  + " " + line
            }
            
        }
        // do a post request and return post data
        return results
    }

}