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
        n3Test()
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
    
    
    func n3Test() {
        
        guard let n3Path = Bundle.main.path(forResource: "n3bundle", ofType: "js")
            else { print("Unable to read resource files."); return }
        
        do {
            let jsCode = try String(contentsOfFile: n3Path, encoding: String.Encoding.utf8)
            _ = context?.evaluateScript(jsCode)
            
            context?.evaluateScript("var prsr = new N3.Parser();")
            context?.evaluateScript("var result = prsr.parse('PREFIX c: <http://example.org/cartoons#> c:Tom a c:Cat. c:Jerry a c:Mouse; c:smarterThan c:Tom.')")
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
        }
        catch {
            print("Evaluate script failed")
        }
    }
}


