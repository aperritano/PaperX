//: Playground - noun: a place where people can play

import UIKit

let progressView = UIProgressView(progressViewStyle: UIProgressViewStyle.Default)


var str = "Hello, playground"



var error: NSError?

    var filePath = NSBundle.mainBundle().pathForResource("ris", ofType: "ris")

let s = try! NSString(contentsOfFile: filePath!, encoding: NSASCIIStringEncoding) as? String
//print(s!)
let lines = s!.componentsSeparatedByString("\n")
let totalLineCount = lines.count
//var h = s!!.characters.split { $0 == "\n" }
//print(array)
//do {
//    let template = try String(contentsOfFile: path!, encoding: NSUTF8StringEncoding)
//    // Use the template
//} catch let error as NSError {
//    // Handle the error
//}




class Helper {
    static let sharedInstance = Helper()
    
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
    
    class func parseEndnote(lines:[String], progressView: UIProgressView) -> [[String:AnyObject]] {
        let totalLineCount = lines.count
        var results = [[String:AnyObject]]()
        var tempDict = [String:AnyObject]()
        var lastSectionKey : String?
        
        for var index = 0; index < totalLineCount; ++index {
            let line = lines[index]
            progressView.progress = Float(index)/Float(totalLineCount)
            if sharedInstance.isSectionStart(line) {
                let sections = line.characters.split {$0 == "-"}.map { String($0) }
            
                let sectionKey = sections.first!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                let lastSection = sections.last!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
                
                lastSectionKey =  sectionKey
                
                if sectionKey == "TY" {
                    tempDict = [String:String]()
                    tempDict[sectionKey] = lastSection
                } else if sectionKey == "ER" {
                    tempDict[sectionKey] = ""
                    results.append(tempDict)
                } else if sectionKey == "A1" {
                    //print(line)
                    if let authors = tempDict[sectionKey] {
                        
                        var a = authors as! [String]
                        
                        a.append(lastSection)
                        tempDict[sectionKey] = a
                        print( tempDict[sectionKey])
                        // now val is not nil and the Optional has been unwrapped, so use it
                    } else {
                        //print(lastSection)
                        let n : [String] = [lastSection]
                        tempDict[sectionKey] = n
                    }
                } else {
                    tempDict[sectionKey] = lastSection
                }
            } else {
                
                let val = tempDict[lastSectionKey!]!
                
                tempDict[lastSectionKey!] = val as! String + " " + line
            }
            
        }
        // do a post request and return post data
        return results
    }
}


var results = Helper.parseEndnote(lines,progressView: progressView)

print(results[1]["A1"])
    
//    dict[b.first as! String] = b.popLast()
//    print(b)
    
    
//    print(item)

//String.stringwi
//let content = String.stringWithContentsOfFile(filePath, encoding: NSUTF8StringEncoding, error: error)

//let content = String(contentsOfURL: contentData!, encoding: NSUTF8StringEncoding, error:&error) as? String
//print(content)


//        do {
//            let contents = NSString(contentsOfFile: filepath)
//            print(contents)
//        } catch {
//            // contents could not be loaded
//        }
//    } else {
//        // example.txt not found!
//    }



//func readFile(fileName: String, fileType: String) -> String{
//    var fileRoot = NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)
//    var contents = NSString.init(contentsOfFile: fileName, encoding: NSUTF8StringEncoding)
//   
//    return contents
//}
