//
//  ViewController.swift
//  swift.db
//
//  Created by Podul on 11/15/2019.
//  Copyright (c) 2019 Podul. All rights reserved.
//

import UIKit
import SwiftDB

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        DBManager.open(tables: Model.self)

        var model = Model()
        model.name = "name111"
        model.text = "text111"
        DBManager.insert(model)
        
        model.text = "text222"
        model.id = 1
        DBManager.update(model)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}



struct Model: DataBaseModel {
    var id: DB.Primary = 0
    var name: String = "name"
    var text: DB.Text = "text"
    var optional: String? = nil
}


