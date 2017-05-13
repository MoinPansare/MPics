//
//  MPics.swift
//  Pods
//
//  Created by Moin Pansare on 05/05/17.
//
//

import UIKit

public class MPics: NSObject {
    
    private var selection : MPicsSource = .camera;
    
    public func loadMPics(source : MPicsSource,parent : UIViewController) {
        
        self.selection = source;
        let story : UIStoryboard = UIStoryboard(name: "MPicsStoryBoard", bundle: Bundle(for: self.classForCoder));
        let destination : MPicsHome = story.instantiateViewController(withIdentifier: "MPicsHome") as! MPicsHome;
        destination.selection = source;
        destination.MPicsDelegate = parent as! MPicsProtocol;
        parent.present(destination, animated: true, completion: nil);
    }
    
    
}

public enum MPicsSource {
    case gallery;
    case camera;
    case videos;
}
