//
//  Protocols.swift
//  PinpinboxShareExtension
//
//  Created by Antelis on 2019/3/19.
//  Copyright © 2019 Angus. All rights reserved.
//

import Foundation
import UIKit

protocol UploadProgressDelegate {
    func uploadProgress(_ taskUUID: String?,_ progress:Float)
}

protocol ItemPostLoadDelegate: NSObject {
    func loadCompletedWith(_ thumbnail: UIImage?, _ type: String?,_ hasVideo: Bool, isDark: Bool)
}

protocol ItemContentDelegate: NSObject  {
    func processInvalidItem(_ item: ShareItem? )
}

@objc protocol AlbumSettingsDelegate {
    @objc optional func reloadAlbumList()
}
