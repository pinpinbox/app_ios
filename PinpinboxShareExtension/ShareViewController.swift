//
//  ShareViewController.swift
//  PinpinboxShareExtension
//
//  Created by Antelis on 2019/3/19.
//  Copyright © 2019 Angus. All rights reserved.
//

import UIKit
import MobileCoreServices
import UserNotifications
import AVFoundation
import QuartzCore


class ShareViewController: UIViewController, UINavigationControllerDelegate {

     @IBOutlet weak var userName: UILabel?
     @IBOutlet weak var albumList: UITableView?
     @IBOutlet weak var groupAlbumList: UITableView?
     @IBOutlet weak var photoList: UICollectionView?
     @IBOutlet weak var textArea : UITextView?
     @IBOutlet weak var notLoginCover : UIView?
     @IBOutlet weak var coverNotice: UITextView?
     var albumlist: Array<[NSString: Any]> = []
     var groupalbumlist: Array<[NSString: Any]> = []
     var shareItems : Array<ShareItem> = []
     var selectedAlbum : String?
     var albumNames: String?
    
     @IBOutlet weak var progressView: UIView?
     @IBOutlet weak var postProgress: UIProgressView?
     @IBOutlet weak var postProgressStatus: UITextView?
     var isLoading : Bool = false
     var successCount: Int = 0
     var failCount: Int = 0
    
     @IBOutlet weak var retryBtn: UIButton?
    
     @IBOutlet weak var mylist: UIListButton?
     @IBOutlet weak var grouplist: UIListButton?
 
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}

extension ShareViewController : UITableViewDelegate{

}
extension ShareViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell(style: .default, reuseIdentifier: "")
    }
    
    
}
extension ShareViewController : UICollectionViewDelegateFlowLayout {
    
}
extension ShareViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell(frame: CGRect.zero)
    }
    
    
}
extension ShareViewController : UploadProgressDelegate {
    func uploadProgress(_ taskUUID: String?, _ progress: Float) {
        
    }
    
    
}
extension ShareViewController : PDFUploaderDelegate {
    func userInfo() -> [AnyHashable : Any] {
        return [:]
    }
    
    func retrieveSign(_ param: [AnyHashable : Any]) -> String {
        return ""
    }
    
    func isExporter() -> Bool {
        return false
    }
    
    
}

extension ShareViewController : ItemContentDelegate {
    func processInvalidItem(_ item: ShareItem?) {
        
    }
    
    
}
extension ShareViewController : AlbumSettingsDelegate {
    
}
