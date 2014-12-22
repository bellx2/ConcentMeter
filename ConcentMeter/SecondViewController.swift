//
//  SecondViewController.swift
//  ConcentMeter2
//
//  Created by tanabe on 2014/12/22.
//  Copyright (c) 2014年 Addon Inc. All rights reserved.
//

import UIKit
import Realm

class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var tableView: UITableView!
    
    var events:RLMResults!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //        var obj = FCEvent()
        //        obj.datetime = "2014/12/03 10:15"
        //        obj.faceOK = 100
        //        obj.faceNG = 10
        //        let realm = RLMRealm.defaultRealm()
        //
        //        realm.transactionWithBlock { () -> Void in
        //            realm.addObject(obj)
        //        }
        
        println(RLMRealm.defaultRealmPath())
        events = FCEvent.allObjects()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(events.count)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        let cell: FCViewCell = self.tableView.dequeueReusableCellWithIdentifier("customCell") as FCViewCell
        let ev = events.objectAtIndex(UInt(indexPath.row)) as FCEvent
        //cell.textLabel?.text = ev.datetime
        cell.titleLabel.text = ev.datetime
        cell.rateLabel.text = "\(ev.faceOK*100/((ev.faceOK+ev.faceNG)))%"
        //        println("ok\(ev.faceOK):ng\(ev.faceNG)")
        return cell
    }
    
    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!){
        
        if(editingStyle == UITableViewCellEditingStyle.Delete){
            let realm = RLMRealm.defaultRealm()
            let ev = events.objectAtIndex(UInt(indexPath.row)) as FCEvent
            realm.transactionWithBlock({ () -> Void in
                realm.deleteObject(ev)
            })
//            tableView.reloadData()
        }
    }
    
    
}

