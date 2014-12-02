//
//  FirstViewController.swift
//  ConcentMeter
//
//  Created by bell on 2014/12/02.
//  Copyright (c) 2014年 Addon Inc. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController,HVC_Delegate {

	var HvcBLE:HVC_BLE = HVC_BLE()
	var ExecuteFlag:HVC_FUNCTION = HVC_ACTIV_FACE_DETECTION
	var Connected = false
	var faceOn:Float = 1.0
	var faceOff:Float = 1.0
	var timer = NSTimer()
	var startTime:NSTimeInterval = 0
	
	@IBOutlet weak var gaugeView: WMGaugeView!
	@IBOutlet weak var timeLabel: UILabel!
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		HvcBLE.delegateHVC = self
		
		
		gaugeView.maxValue = 100.0;
		gaugeView.scaleDivisions = 10;
		gaugeView.scaleSubdivisions = 5;
		gaugeView.scaleStartAngle = 80;
		gaugeView.scaleEndAngle = 280;
		gaugeView.innerBackgroundStyle = WMGaugeViewInnerBackgroundStyleFlat;
		gaugeView.showScaleShadow = false;
		gaugeView.scaleFont = UIFont(name: "AvenirNext-UltraLight", size: 0.065)
		gaugeView.scalesubdivisionsaligment = WMGaugeViewSubdivisionsAlignmentCenter;
		gaugeView.scaleSubdivisionsWidth = 0.002;
		gaugeView.scaleSubdivisionsLength = 0.04;
		gaugeView.scaleDivisionsWidth = 0.007;
		gaugeView.scaleDivisionsLength = 0.07;
		gaugeView.needleStyle = WMGaugeViewNeedleStyleFlatThin;
		gaugeView.needleWidth = 0.012;
		gaugeView.needleHeight = 0.4;
		gaugeView.needleScrewStyle = WMGaugeViewNeedleScrewStylePlain;
		gaugeView.needleScrewRadius = 0.05;
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	@IBAction func pushButton(sender: AnyObject) {
		HvcBLE.deviceSearch()
		let devices = HvcBLE.getDevices()
		
		//５秒後に選択を表示する - 直後だと反応しない...
		NSTimer.scheduledTimerWithTimeInterval(5.0, target: NSBlockOperation({
			MBProgressHUD.hideHUDForView(self.view, animated: true)
			var alertController = UIAlertController(title: "デバイス選択", message: "HVC-を選択してください", preferredStyle: .Alert)
			for device in devices{
				let action = UIAlertAction(title: device.name, style: UIAlertActionStyle.Default, handler: { (myaction) -> Void in
					self.HvcBLE.connect(device as CBPeripheral)
					println("\(device.name)接続開始")
				})
				alertController.addAction(action)
			}
			let action = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, handler: { (myaction) -> Void in
				println("キャンセル")
			})
			alertController.addAction(action)
			self.presentViewController(alertController, animated: true, completion: nil)
		}), selector: "main", userInfo: nil, repeats: false)
		var hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		hud.labelText = "デバイスを探しています"
	}
	
	@IBAction func doStart(sender: AnyObject) {
		timer.invalidate()
		HvcBLE.disconnect()
		Connected = false
		let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		hud.labelText = "切断処理中"
	}
	
	func onConnected() {
		let hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
		hud.labelText = "接続中"
		// Start
		let param = HVC_PRM()
		param.face().setMinSize(60)
		param.face().setMaxSize(480)
		HvcBLE.setParam(param)
	}
	
	func onDisconnected() {
		MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
	}
	
	func onPostSetParam(err: HVC_ERRORCODE, status outStatus: UInt8) {
		dispatch_async(dispatch_get_main_queue(),{
			var res = HVC_RES()
			self.HvcBLE.Execute(self.ExecuteFlag, result: res)
		})
	}
	
	func onPostExecute(result: HVC_RES!, errcode err: HVC_ERRORCODE, status outStatus: UInt8) {
		if (self.Connected == false){
			Connected = true
			MBProgressHUD.hideAllHUDsForView(self.view, animated: true)
			startTime = NSDate.timeIntervalSinceReferenceDate()
			timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "timeCount", userInfo: nil, repeats: true)
		}
		if (result.sizeFace() > 0){
			faceOn += 1.0
		}else{
			faceOff += 1.0
		}
		let faceRate:Float = (faceOn/faceOff) * 100
		gaugeView.setValue(faceRate, animated: true)
		
		dispatch_async(dispatch_get_main_queue(), {
			var res = HVC_RES()
			if (self.Connected == true){
				self.HvcBLE.Execute(self.ExecuteFlag, result: res)
			}
		})
	}
	
	func timeCount(){
		let cTime = NSDate.timeIntervalSinceReferenceDate() - self.startTime
		let hour = Int(cTime/(60*60))
		let minutes = Int(fmod((cTime/60),60))
		let secound = Int(fmod(cTime,60))
		timeLabel.text = NSString(format: "%02d:%02d:%02d", hour,minutes,secound)
	}

}

