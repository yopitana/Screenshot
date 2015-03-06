//
//  ViewController.swift
//  Screenshot
//
//  Created by kenji_sugimoto on 2015/03/05.
//  Copyright (c) 2015年 com.sugimoto.kenji. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    
    var targetURL = "http://www.yahoo.co.jp/"
    
    // ユーザーへの許可のリクエスト.
    var photoRequest : PHCollectionListChangeRequest!
    
    @IBAction func BtnCapTap(sender: UIButton) {
        capture()
        webViewEffect()
    }

    @IBAction func btnFullCapTap(sender: UIButton) {
        fullScreenCapture()
        webViewEffect()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAddressURL()
        var updateTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "setTime", userInfo: nil, repeats: true)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        //PhotoKitの使用をユーザーから許可を得る.
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            switch(status){
            case .Authorized:
                println("Authorized")
                
            case .Denied:
                println("Denied")
                
            case .NotDetermined:
                println("NotDetermined")
                
            case .Restricted:
                println("Restricted")
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func webViewEffect() {
        UIView.animateWithDuration(0.3, delay: 0.2, options:nil, animations: {
            self.webView.alpha = 0
            }, completion: {
                (finished: Bool) -> Void in
                self.webView.alpha = 1
            }
        )
    }
    
    func capture() {
        // webView to UIImage
        let scale = UIScreen.mainScreen().scale;
        UIGraphicsBeginImageContextWithOptions(webView.bounds.size, false, scale);
        webView.layer.renderInContext(UIGraphicsGetCurrentContext())
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // iOSのフォトアルバムにコレクション(アルバム)を追加する.
        PHPhotoLibrary.sharedPhotoLibrary().performChanges({ () -> Void in
            
            // iOSのフォトアルバムにコレクション(アルバム)を追加する.
            self.photoRequest = PHCollectionListChangeRequest.creationRequestForCollectionListWithTitle("Screenshot")
            
            }, completionHandler: { (isSuccess, error) -> Void in
                
                if isSuccess == true {
                    println("Success!")
                }
                else{
                    println("error occured")
                }
                
        })
        
        
        // PhotoAlbumに保存
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        println("save")
    }
    
    func fullScreenCapture() {
        // tempframe to reset view size after image was created
        var tmpFrame = webView.frame
        
        // set new Frame
        var aFrame         = webView.frame;
        aFrame.size.height = webView.sizeThatFits(UIScreen.mainScreen().bounds.size).height;
        webView.frame      = aFrame;
        let scale = UIScreen.mainScreen().scale;
        
        // webView to UIImage
        UIGraphicsBeginImageContextWithOptions(webView.sizeThatFits(UIScreen.mainScreen().bounds.size), false, scale);
        webView.layer.renderInContext(UIGraphicsGetCurrentContext())
        var image:UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        // reset Frame of view to origin
        webView.frame = tmpFrame;
        
        // PhotoAlbumに保存
        UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
        println("fullsave")
    }
    
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error != nil {
            //プライバシー設定不許可など書き込み失敗時は -3310 (ALAssetsLibraryDataUnavailableError)
            println(error.code)
        }
    }
    
    
    func loadAddressURL() {
        let requestURL = NSURL(string: targetURL)
        let req = NSURLRequest(URL: requestURL!)
        webView.loadRequest(req)
    }
    
    func setTime(){
        let dateFormatter = NSDateFormatter()                                   // フォーマットの取得
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")  // JPロケール
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss"         // フォーマットの指定
        timeLabel.text = dateFormatter.stringFromDate(NSDate())
    }
    
}

