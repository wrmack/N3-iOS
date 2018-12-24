//
//  ViewController.swift
//  N3Test
//
//  Created by Warwick McNaughton on 22/12/18.
//  Copyright © 2018 Warwick McNaughton. All rights reserved.
//

import UIKit
import JavaScriptCore



class ViewController: UIViewController {
    var context = JSContext()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContext()
        setupN3()
        n3ParseSimple()
    }
    
    
    func setupContext() {
        
        // Catch JavaScript exceptions
        context!.exceptionHandler = { context, error in
            print("JS Error: \(error!)")
        }
        
        let nativePrint: @convention(block) (String) -> Void = { message in
            print("JS print: \(message)")
        }
        context!.setObject(nativePrint, forKeyedSubscript: "nativePrint" as NSString)
    }
    
    
    /*
     Write the bundled javascript N3 library into the javascript context.
     Note: the bundle was created with browserify standalone option set to "N3".
     All exports in N3.js are available to Swift through N3.
     */
    func setupN3() {
        
        guard let n3Path = Bundle.main.path(forResource: "n3bundle", ofType: "js")
            else { print("Unable to read resource files."); return }
        
        do {
            let jsCode = try String(contentsOfFile: n3Path, encoding: String.Encoding.utf8)
            _ = context?.evaluateScript(jsCode)
        }
        catch {
            print("Evaluate script failed")
        }
    }
    
    
    /*
     Create new Parser object in the javascript context.
     Pass the code to be parsed to the Parser parse function, storing the result in 'result' variable.
     Access the 'result' variable which contains an array of quads.
     Extract subject, predicate and object values from each quad.
     */
    func n3ParseSimple() {
        
        print("\n===================================\nTesting parsing a simple string...\n===================================\n")
        
        let codeToParse = "PREFIX c: <http://example.org/cartoons#> c:Tom a c:Cat. c:Jerry a c:Mouse; c:smarterThan c:Tom."
        print("Input string: \(codeToParse)\n")
        
        context?.evaluateScript("var prsr = new N3.Parser();")
        let jsScript = "var result = prsr.parse(`" + codeToParse + "`)"
        context?.evaluateScript(jsScript)
        
        print("Triples created:\n================\n")
        let quads = context?.objectForKeyedSubscript("result")?.toArray()
        for quad in quads! {
            var quadDict = quad as! [String : Any]
            
            var quadSubject = quadDict["subject"] as! [String : Any]
            let quadSubjectValue = quadSubject["id"]
            print("\nSubject: \(quadSubjectValue!)")
            
            var quadPredicate = quadDict["predicate"] as! [String : Any]
            let quadPredicateValue = quadPredicate["id"]
            print("Predicate: \(quadPredicateValue!)")
            
            var quadObject = quadDict["object"] as! [String : Any]
            let quadObjectValue = quadObject["id"]
            print("Object: \(quadObjectValue!)")
        }
        n3ParseRemote()
 
    }
    
    
    func n3ParseRemote() {
         print("\n======================================================\nTesting parsing a complex string retrieved remotely...\n======================================================\n")
        
        let urlStringToTest = "https://ruben.verborgh.org/profile/#me"
        print("Url: \(urlStringToTest)\n")
        
        let cardURL = URL(string: urlStringToTest)
        
        fetch(url: cardURL!, callback: { response, mimetype in
            print("\nReturned data: \n================ \n")
            print("Mime-type: \(mimetype)")
            print("Data: \n\(response)")
 
            self.context?.evaluateScript("prsr = new N3.Parser();")
            let jsScript = "result = prsr.parse(`" + response + "`)"
            self.context?.evaluateScript(jsScript)
            
            print("Triples created:\n================\n")
            let quads = self.context?.objectForKeyedSubscript("result")?.toArray()
            for quad in quads! {
                var quadDict = quad as! [String : Any]
                
                var quadSubject = quadDict["subject"] as! [String : Any]
                let quadSubjectValue = quadSubject["id"]
                print("\nSubject: \(quadSubjectValue!)")
                
                var quadPredicate = quadDict["predicate"] as! [String : Any]
                let quadPredicateValue = quadPredicate["id"]
                print("Predicate: \(quadPredicateValue!)")
                
                var quadObject = quadDict["object"] as! [String : Any]
                let quadObjectValue = quadObject["id"]
                print("Object: \(quadObjectValue!)")
            }
            
        })
    }
    
    
    /*
     Helper method
     Url fetcher
     */
    func fetch(url: URL, callback: @escaping (String, String) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            print("\nServer response:\n\(response! as Any)\n================\n")
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    print((response as? HTTPURLResponse)?.allHeaderFields as! [String : Any] )
                    return
            }
            print("\nAll headers:\n\(httpResponse.allHeaderFields as! [String : Any])")
            
            let string = String(data: data!, encoding: .utf8)
            callback(string!, httpResponse.mimeType!)
        }
        task.resume()
    }
}


