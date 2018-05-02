//
//  Ex_RegistController.swift
//  GopleTrader
//
//  Created by 김민주 on 2017. 11. 21..
//  Copyright © 2017년 김민주. All rights reserved.
//

import UIKit
import Alamofire
import DKImagePickerController

extension RegistController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openCamera() {

        let pickerController = DKImagePickerController()
        pickerController.sourceType = .camera
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            for each in assets {
                each.fetchImageDataForAsset(true, completeBlock: { (data, result) in
                    if let data = data {
                        self.imageDataArr.append(data)
                    }
                })
            }
            self.uploadImages(self.imageDataArr)
        }
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func openPhotoLibrary() {
        let pickerController = DKImagePickerController()
        pickerController.assetType = .allPhotos
        pickerController.showsCancelButton = true
        pickerController.maxSelectableCount = 5
        pickerController.singleSelect = true
        pickerController.defaultSelectedAssets = self.pickerController.selectedAssets
        pickerController.didSelectAssets = { [unowned self] (assets: [DKAsset]) in
            for each in assets {
                each.fetchImageDataForAsset(true, completeBlock: { (data, result) in
                    if let data = data {
                        self.imageDataArr.append(data)
                    }
                })
            }
            self.uploadImages(self.imageDataArr)
        }
        
        self.present(pickerController, animated: true, completion: nil)
    }
    
    func uploadImages(_ dataArray: [Data]) {
        let headers = [
            "Content-Type": "application/json"
        ]
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            for (i, data) in dataArray.enumerated() {
                print(i, data)
                multipartFormData.append(data, withName: "file[\(i)]", fileName: "image.jpg", mimeType: "image/jpeg")
            }
        }, to: domain + imgRegistURL,
           method: .post,
           headers: headers) { (result) in
            switch result{
            case .success(let upload, _, _):
                upload.responseJSON { response in
                    print("Succesfully uploaded")
//                    print("result : \(result)")
//                    print("response : \(response)")
                    
                    if let imgs = response.result.value as? [[String : String]] {
                        print(imgs)
                        print(response.value!)
                        var imageUrlArray = [String]()
                        
                        for img in imgs {
                            imageUrlArray.append(img["src"]!)
                        }
                        let imageParameter = imageUrlArray.joined(separator: ",")
                        print("\(imageParameter)")
                        self.wkWebView.evaluateJavaScript("gRun.iOSfilePaging('\(imageParameter)')") { result, error in
                            if let error = error {
                                print(error)
                            } else {
                                self.imageDataArr.removeAll()
                                print(result)
                            }
                        }

                    }
                }
            case .failure(let error):
                print("Error in upload: \(error.localizedDescription)")
            }
        }
    }
    
    func createComment() {
        
        let width = self.view.frame.width
        let height = self.view.frame.height
        
        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 0.5))
        lineView.backgroundColor = UIColor.init(hex: "e1e1e1")
        commentView.addSubview(lineView)
        
        commentView.frame = CGRect(x: 0, y: 0, width: width, height: 47)
        commentBackImg.image = #imageLiteral(resourceName: "text_box")
        let commentBackImgX = commentView.frame.origin.x + 12
        let commentBackImgY = commentView.frame.height / 2
        commentBackImg.frame = CGRect(x: commentBackImgX, y: height, width: width - 69, height: 33)
        commentBackImg.center.y = commentBackImgY
        commentView.backgroundColor = UIColor.white
        commentView.addSubview(commentBackImg)
        
        sendBtn.setImage(#imageLiteral(resourceName: "send_n"), for: .normal)
        sendBtn.frame = CGRect(x: commentBackImg.frame.width + 12, y: 0, width: 45, height: 33)
        sendBtn.center.y = commentBackImgY
        sendBtn.addTarget(self, action: #selector(sendAction(_:)), for: .touchUpInside)
        commentView.addSubview(sendBtn)
        
        commentTF.frame = CGRect(x: 8, y: 0, width: 290, height: 13)
        commentTF.font = UIFont(name: "DaeHan", size: 13)
        commentTF.textColor = textColor
        commentTF.center.y = commentBackImg.frame.height / 2
        
        commentTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        commentBackImg.addSubview(commentTF)
        
        if commentBottom > 0 {
            commentView.frame.origin.y = wkWebView.frame.height - (commentBottom + commentView.frame.height)
        }
        
        wkWebView.addSubview(commentView)
        commentTF.becomeFirstResponder()
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        
        if textField.text! != "" {
            sendBtn.setImage(#imageLiteral(resourceName: "send_p"), for: .normal)
        } else {
            sendBtn.setImage(#imageLiteral(resourceName: "send_n"), for: .normal)
        }
    }
    
    func sendAction(_ sender: UIButton) {
        
        if commentTF.text!.isEmpty == true {
            basicAlert(target: self, title: nil, message: "댓글을 입력해주세요.")
        } else {
            let commentIdx = UserDefaults.standard.object(forKey: "commentIdx") as! Int
            let str = commentTF.text!
            
            if UserDefaults.standard.object(forKey: "commentUpdate") != nil {
                wkWebView.evaluateJavaScript("gRun.setModText('\(commentIdx)', '\(str)')", completionHandler: { (result, error) in
                    if let error = error {
                        print(error)
                    } else {
                        self.removeComment()
                        UserDefaults.standard.removeObject(forKey: "commentUpdate")
                    }
                })
            } else {
                wkWebView.evaluateJavaScript("gRun.setLoadText('\(commentIdx)', '\(str)')", completionHandler: { (result, error) in
                    if let error = error {
                        print(error)
                    } else {
                        self.removeComment()
                    }
                })
            }
           
        }
        
    }
    
    func removeComment(){
        commentTF.text = ""
        commentView.removeFromSuperview()
    }
}
