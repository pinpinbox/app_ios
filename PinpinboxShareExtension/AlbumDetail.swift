//
//  AlbumDetail.swift
//  PinpinboxShareExtension
//
//  Created by Antelis on 2019/3/21.
//  Copyright © 2019 Angus. All rights reserved.
//

import Foundation

public struct AlbumDetail: Codable, Hashable {
    public let album: Album
    public let albumstatistics: Albumstatistics
    public let event: JSONNull?
    public let eventjoin: JSONNull?
    public let photo: [Photo]
    public let photousefor: JSONNull?
    public let photouseforUser: JSONNull?
    public let user: User
    
    enum CodingKeys: String, CodingKey {
        case album = "album"
        case albumstatistics = "albumstatistics"
        case event = "event"
        case eventjoin = "eventjoin"
        case photo = "photo"
        case photousefor = "photousefor"
        case photouseforUser = "photousefor_user"
        case user = "user"
    }
    
    public init(album: Album, albumstatistics: Albumstatistics, event: JSONNull?, eventjoin: JSONNull?, photo: [Photo], photousefor: JSONNull?, photouseforUser: JSONNull?, user: User) {
        self.album = album
        self.albumstatistics = albumstatistics
        self.event = event
        self.eventjoin = eventjoin
        self.photo = photo
        self.photousefor = photousefor
        self.photouseforUser = photouseforUser
        self.user = user
    }
}

fileprivate struct Album: Codable, Hashable {
    public let countPhoto: Int
    public let description: String
    public let displayNumOfCollect: Bool
    public let inserttime: String
    public let isLikes: Bool
    public let location: String
    public let name: String
    public let own: Bool
    public let audioMode: String
    public let audioLoop: Bool
    public let audioRefer: String
    public let audioTarget: JSONNull?
    public let point: Int
    public let previewPageNum: Int
    public let rewardAfterCollect: Bool
    public let rewardDescription: JSONNull?
    public let usefor: Usefor
    
    enum CodingKeys: String, CodingKey {
        case countPhoto = "count_photo"
        case description = "description"
        case displayNumOfCollect = "display_num_of_collect"
        case inserttime = "inserttime"
        case isLikes = "is_likes"
        case location = "location"
        case name = "name"
        case own = "own"
        case audioMode = "audio_mode"
        case audioLoop = "audio_loop"
        case audioRefer = "audio_refer"
        case audioTarget = "audio_target"
        case point = "point"
        case previewPageNum = "preview_page_num"
        case rewardAfterCollect = "reward_after_collect"
        case rewardDescription = "reward_description"
        case usefor = "usefor"
    }
    
    public init(countPhoto: Int, description: String, displayNumOfCollect: Bool, inserttime: String, isLikes: Bool, location: String, name: String, own: Bool, audioMode: String, audioLoop: Bool, audioRefer: String, audioTarget: JSONNull?, point: Int, previewPageNum: Int, rewardAfterCollect: Bool, rewardDescription: JSONNull?, usefor: Usefor) {
        self.countPhoto = countPhoto
        self.description = description
        self.displayNumOfCollect = displayNumOfCollect
        self.inserttime = inserttime
        self.isLikes = isLikes
        self.location = location
        self.name = name
        self.own = own
        self.audioMode = audioMode
        self.audioLoop = audioLoop
        self.audioRefer = audioRefer
        self.audioTarget = audioTarget
        self.point = point
        self.previewPageNum = previewPageNum
        self.rewardAfterCollect = rewardAfterCollect
        self.rewardDescription = rewardDescription
        self.usefor = usefor
    }
}

fileprivate struct Usefor: Codable, Hashable {
    public let exchange: Bool
    public let image: Bool
    public let slot: Bool
    public let video: Bool
    public let audio: Bool
    
    enum CodingKeys: String, CodingKey {
        case exchange = "exchange"
        case image = "image"
        case slot = "slot"
        case video = "video"
        case audio = "audio"
    }
    
    public init(exchange: Bool, image: Bool, slot: Bool, video: Bool, audio: Bool) {
        self.exchange = exchange
        self.image = image
        self.slot = slot
        self.video = video
        self.audio = audio
    }
}

fileprivate struct Albumstatistics: Codable, Hashable {
    public let count: Int
    public let exchange: Int
    public let likes: Int
    public let messageboard: Int
    public let viewed: Int
    
    enum CodingKeys: String, CodingKey {
        case count = "count"
        case exchange = "exchange"
        case likes = "likes"
        case messageboard = "messageboard"
        case viewed = "viewed"
    }
    
    public init(count: Int, exchange: Int, likes: Int, messageboard: Int, viewed: Int) {
        self.count = count
        self.exchange = exchange
        self.likes = likes
        self.messageboard = messageboard
        self.viewed = viewed
    }
}

fileprivate struct Photo: Codable, Hashable {
    public let audioLoop: Bool
    public let audioRefer: String
    public let audioTarget: String?
    public let description: JSONNull?
    public let duration: Int
    public let location: String?
    public let name: JSONNull?
    public let photoId: Int
    public let usefor: String
    public let videoRefer: String
    public let videoTarget: JSONNull?
    public let imageUrl: String
    public let imageUrlThumbnail: String
    public let hyperlink: JSONNull?
    
    enum CodingKeys: String, CodingKey {
        case audioLoop = "audio_loop"
        case audioRefer = "audio_refer"
        case audioTarget = "audio_target"
        case description = "description"
        case duration = "duration"
        case location = "location"
        case name = "name"
        case photoId = "photo_id"
        case usefor = "usefor"
        case videoRefer = "video_refer"
        case videoTarget = "video_target"
        case imageUrl = "image_url"
        case imageUrlThumbnail = "image_url_thumbnail"
        case hyperlink = "hyperlink"
    }
    
    public init(audioLoop: Bool, audioRefer: String, audioTarget: String?, description: JSONNull?, duration: Int, location: String?, name: JSONNull?, photoId: Int, usefor: String, videoRefer: String, videoTarget: JSONNull?, imageUrl: String, imageUrlThumbnail: String, hyperlink: JSONNull?) {
        self.audioLoop = audioLoop
        self.audioRefer = audioRefer
        self.audioTarget = audioTarget
        self.description = description
        self.duration = duration
        self.location = location
        self.name = name
        self.photoId = photoId
        self.usefor = usefor
        self.videoRefer = videoRefer
        self.videoTarget = videoTarget
        self.imageUrl = imageUrl
        self.imageUrlThumbnail = imageUrlThumbnail
        self.hyperlink = hyperlink
    }
}

struct User: Codable, Hashable {
    public let name: String
    public let picture: String
    public let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case picture = "picture"
        case userId = "user_id"
    }
    
    public init(name: String, picture: String, userId: Int) {
        self.name = name
        self.picture = picture
        self.userId = userId
    }
}

// MARK: Convenience initializers and mutators

public extension AlbumDetail {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(AlbumDetail.self, from: data)
    }
    
    public init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    public init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    public func with(
        album: Album? = nil,
        albumstatistics: Albumstatistics? = nil,
        event: JSONNull?? = nil,
        eventjoin: JSONNull?? = nil,
        photo: [Photo]? = nil,
        photousefor: JSONNull?? = nil,
        photouseforUser: JSONNull?? = nil,
        user: User? = nil
        ) -> AlbumDetail {
        return AlbumDetail(
            album: album ?? self.album,
            albumstatistics: albumstatistics ?? self.albumstatistics,
            event: event ?? self.event,
            eventjoin: eventjoin ?? self.eventjoin,
            photo: photo ?? self.photo,
            photousefor: photousefor ?? self.photousefor,
            photouseforUser: photouseforUser ?? self.photouseforUser,
            user: user ?? self.user
        )
    }
    
    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Album {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(Album.self, from: data)
    }
    
    public init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    public init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    public func with(
        countPhoto: Int? = nil,
        description: String? = nil,
        displayNumOfCollect: Bool? = nil,
        inserttime: String? = nil,
        isLikes: Bool? = nil,
        location: String? = nil,
        name: String? = nil,
        own: Bool? = nil,
        audioMode: String? = nil,
        audioLoop: Bool? = nil,
        audioRefer: String? = nil,
        audioTarget: JSONNull?? = nil,
        point: Int? = nil,
        previewPageNum: Int? = nil,
        rewardAfterCollect: Bool? = nil,
        rewardDescription: JSONNull?? = nil,
        usefor: Usefor? = nil
        ) -> Album {
        return Album(
            countPhoto: countPhoto ?? self.countPhoto,
            description: description ?? self.description,
            displayNumOfCollect: displayNumOfCollect ?? self.displayNumOfCollect,
            inserttime: inserttime ?? self.inserttime,
            isLikes: isLikes ?? self.isLikes,
            location: location ?? self.location,
            name: name ?? self.name,
            own: own ?? self.own,
            audioMode: audioMode ?? self.audioMode,
            audioLoop: audioLoop ?? self.audioLoop,
            audioRefer: audioRefer ?? self.audioRefer,
            audioTarget: audioTarget ?? self.audioTarget,
            point: point ?? self.point,
            previewPageNum: previewPageNum ?? self.previewPageNum,
            rewardAfterCollect: rewardAfterCollect ?? self.rewardAfterCollect,
            rewardDescription: rewardDescription ?? self.rewardDescription,
            usefor: usefor ?? self.usefor
        )
    }
    
    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Usefor {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(Usefor.self, from: data)
    }
    
    public init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    public init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    public func with(
        exchange: Bool? = nil,
        image: Bool? = nil,
        slot: Bool? = nil,
        video: Bool? = nil,
        audio: Bool? = nil
        ) -> Usefor {
        return Usefor(
            exchange: exchange ?? self.exchange,
            image: image ?? self.image,
            slot: slot ?? self.slot,
            video: video ?? self.video,
            audio: audio ?? self.audio
        )
    }
    
    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Albumstatistics {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(Albumstatistics.self, from: data)
    }
    
    public init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    public init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    public func with(
        count: Int? = nil,
        exchange: Int? = nil,
        likes: Int? = nil,
        messageboard: Int? = nil,
        viewed: Int? = nil
        ) -> Albumstatistics {
        return Albumstatistics(
            count: count ?? self.count,
            exchange: exchange ?? self.exchange,
            likes: likes ?? self.likes,
            messageboard: messageboard ?? self.messageboard,
            viewed: viewed ?? self.viewed
        )
    }
    
    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Photo {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(Photo.self, from: data)
    }
    
    public init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    public init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    public func with(
        audioLoop: Bool? = nil,
        audioRefer: String? = nil,
        audioTarget: String?? = nil,
        description: JSONNull?? = nil,
        duration: Int? = nil,
        location: String?? = nil,
        name: JSONNull?? = nil,
        photoId: Int? = nil,
        usefor: String? = nil,
        videoRefer: String? = nil,
        videoTarget: JSONNull?? = nil,
        imageUrl: String? = nil,
        imageUrlThumbnail: String? = nil,
        hyperlink: JSONNull?? = nil
        ) -> Photo {
        return Photo(
            audioLoop: audioLoop ?? self.audioLoop,
            audioRefer: audioRefer ?? self.audioRefer,
            audioTarget: audioTarget ?? self.audioTarget,
            description: description ?? self.description,
            duration: duration ?? self.duration,
            location: location ?? self.location,
            name: name ?? self.name,
            photoId: photoId ?? self.photoId,
            usefor: usefor ?? self.usefor,
            videoRefer: videoRefer ?? self.videoRefer,
            videoTarget: videoTarget ?? self.videoTarget,
            imageUrl: imageUrl ?? self.imageUrl,
            imageUrlThumbnail: imageUrlThumbnail ?? self.imageUrlThumbnail,
            hyperlink: hyperlink ?? self.hyperlink
        )
    }
    
    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension User {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(User.self, from: data)
    }
    
    public init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    public init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    public func with(
        name: String? = nil,
        picture: String? = nil,
        userId: Int? = nil
        ) -> User {
        return User(
            name: name ?? self.name,
            picture: picture ?? self.picture,
            userId: userId ?? self.userId
        )
    }
    
    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

// MARK: Encode/decode helpers

public class JSONNull: Codable, Hashable {
    
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    
    public var hashValue: Int {
        return 0
    }
    
    public init() {}
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}

fileprivate func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

fileprivate func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}
