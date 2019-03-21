//
//  Creator.swift
//  PinpinboxShareExtension
//
//  Created by Antelis on 2019/3/21.
//  Copyright © 2019 Angus. All rights reserved.
//

import Foundation

public struct Creator: Codable, Hashable {
    
    struct Album: Codable, Hashable {
        public let albumId: Int
        public let name: String
        public let description: String
        public let cover: String
        public let coverHeight: Int
        public let coverHex: String
        public let coverWidth: Int
        public let inserttime: String
        public let usefor: Usefor
        
        enum CodingKeys: String, CodingKey {
            case albumId = "album_id"
            case name = "name"
            case description = "description"
            case cover = "cover"
            case coverHeight = "cover_height"
            case coverHex = "cover_hex"
            case coverWidth = "cover_width"
            case inserttime = "inserttime"
            case usefor = "usefor"
        }
        
        public init(albumId: Int, name: String, description: String, cover: String, coverHeight: Int, coverHex: String, coverWidth: Int, inserttime: String, usefor: Usefor) {
            self.albumId = albumId
            self.name = name
            self.description = description
            self.cover = cover
            self.coverHeight = coverHeight
            self.coverHex = coverHex
            self.coverWidth = coverWidth
            self.inserttime = inserttime
            self.usefor = usefor
        }
    }
    
    struct Usefor: Codable, Hashable {
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

    struct Creative: Codable, Hashable {
        public let infoUrl: String
        
        enum CodingKeys: String, CodingKey {
            case infoUrl = "info_url"
        }
        
        public init(infoUrl: String) {
            self.infoUrl = infoUrl
        }
    }
    
    struct Follow: Codable, Hashable {
        public let countFrom: Int
        public let follow: Bool
        
        enum CodingKeys: String, CodingKey {
            case countFrom = "count_from"
            case follow = "follow"
        }
        
        public init(countFrom: Int, follow: Bool) {
            self.countFrom = countFrom
            self.follow = follow
        }
    }
    
    struct Split: Codable, Hashable {
        public let identity: String
        public let ratio: String
        public let sum: Int
        public let sumofsettlement: Int
        public let sumofunsettlement: Int
        
        enum CodingKeys: String, CodingKey {
            case identity = "identity"
            case ratio = "ratio"
            case sum = "sum"
            case sumofsettlement = "sumofsettlement"
            case sumofunsettlement = "sumofunsettlement"
        }
        
        public init(identity: String, ratio: String, sum: Int, sumofsettlement: Int, sumofunsettlement: Int) {
            self.identity = identity
            self.ratio = ratio
            self.sum = sum
            self.sumofsettlement = sumofsettlement
            self.sumofunsettlement = sumofunsettlement
        }
    }
    
    struct User: Codable, Hashable {
        public let cover: String
        public let creativeName: String
        public let description: String
        public let discuss: Bool
        public let name: String
        public let picture: String
        public let sociallink: Sociallink
        public let viewed: Int
        
        enum CodingKeys: String, CodingKey {
            case cover = "cover"
            case creativeName = "creative_name"
            case description = "description"
            case discuss = "discuss"
            case name = "name"
            case picture = "picture"
            case sociallink = "sociallink"
            case viewed = "viewed"
        }
        
        init(cover: String, creativeName: String, description: String, discuss: Bool, name: String, picture: String, sociallink: Sociallink, viewed: Int) {
            self.cover = cover
            self.creativeName = creativeName
            self.description = description
            self.discuss = discuss
            self.name = name
            self.picture = picture
            self.sociallink = sociallink
            self.viewed = viewed
        }
    }
    
    struct Sociallink: Codable, Hashable {
        public let web: String
        public let facebook: String
        public let google: String
        public let twitter: String
        public let youtube: String
        public let instagram: String
        public let pinterest: String
        public let linkedin: String
        
        enum CodingKeys: String, CodingKey {
            case web = "web"
            case facebook = "facebook"
            case google = "google"
            case twitter = "twitter"
            case youtube = "youtube"
            case instagram = "instagram"
            case pinterest = "pinterest"
            case linkedin = "linkedin"
        }
        
        public init(web: String, facebook: String, google: String, twitter: String, youtube: String, instagram: String, pinterest: String, linkedin: String) {
            self.web = web
            self.facebook = facebook
            self.google = google
            self.twitter = twitter
            self.youtube = youtube
            self.instagram = instagram
            self.pinterest = pinterest
            self.linkedin = linkedin
        }
    }
    
    struct Userstatistics: Codable, Hashable {
        public let besponsored: Int
        
        enum CodingKeys: String, CodingKey {
            case besponsored = "besponsored"
        }
        
        public init(besponsored: Int) {
            self.besponsored = besponsored
        }
    }
    
    let album: [Album]
    let creative: Creative
    let follow: Follow
    let split: Split
    let user: User
    let userstatistics: Userstatistics
    
    enum CodingKeys: String, CodingKey {
        case album = "album"
        case creative = "creative"
        case follow = "follow"
        case split = "split"
        case user = "user"
        case userstatistics = "userstatistics"
    }
    
    public init(album: [Album], creative: Creative, follow: Follow, split: Split, user: User, userstatistics: Userstatistics) {
        self.album = album
        self.creative = creative
        self.follow = follow
        self.split = split
        self.user = user
        self.userstatistics = userstatistics
    }
}




// MARK: Convenience initializers and mutators

public extension Creator {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Creator.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        album: [Album]? = nil,
        creative: Creative? = nil,
        follow: Follow? = nil,
        split: Split? = nil,
        user: User? = nil,
        userstatistics: Userstatistics? = nil
        ) -> Creator {
        return Creator(
            album: album ?? self.album,
            creative: creative ?? self.creative,
            follow: follow ?? self.follow,
            split: split ?? self.split,
            user: user ?? self.user,
            userstatistics: userstatistics ?? self.userstatistics
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Album {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Album.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    public func with(
        albumId: Int? = nil,
        name: String? = nil,
        description: String? = nil,
        cover: String? = nil,
        coverHeight: Int? = nil,
        coverHex: String? = nil,
        coverWidth: Int? = nil,
        inserttime: String? = nil,
        usefor: Usefor? = nil
        ) -> Album {
        return Album(
            albumId: albumId ?? self.albumId,
            name: name ?? self.name,
            description: description ?? self.description,
            cover: cover ?? self.cover,
            coverHeight: coverHeight ?? self.coverHeight,
            coverHex: coverHex ?? self.coverHex,
            coverWidth: coverWidth ?? self.coverWidth,
            inserttime: inserttime ?? self.inserttime,
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
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Usefor.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
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

public extension Creative {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Creative.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    public func with(
        infoUrl: String? = nil
        ) -> Creative {
        return Creative(
            infoUrl: infoUrl ?? self.infoUrl
        )
    }
    
    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Follow {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(Follow.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    public func with(
        countFrom: Int? = nil,
        follow: Bool? = nil
        ) -> Follow {
        return Follow(
            countFrom: countFrom ?? self.countFrom,
            follow: follow ?? self.follow
        )
    }
    
    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Split {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(Split.self, from: data)
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
        identity: String? = nil,
        ratio: String? = nil,
        sum: Int? = nil,
        sumofsettlement: Int? = nil,
        sumofunsettlement: Int? = nil
        ) -> Split {
        return Split(
            identity: identity ?? self.identity,
            ratio: ratio ?? self.ratio,
            sum: sum ?? self.sum,
            sumofsettlement: sumofsettlement ?? self.sumofsettlement,
            sumofunsettlement: sumofunsettlement ?? self.sumofunsettlement
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
        cover: String? = nil,
        creativeName: String? = nil,
        description: String? = nil,
        discuss: Bool? = nil,
        name: String? = nil,
        picture: String? = nil,
        sociallink: Sociallink? = nil,
        viewed: Int? = nil
        ) -> User {
        return User(
            cover: cover ?? self.cover,
            creativeName: creativeName ?? self.creativeName,
            description: description ?? self.description,
            discuss: discuss ?? self.discuss,
            name: name ?? self.name,
            picture: picture ?? self.picture,
            sociallink: sociallink ?? self.sociallink,
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

public extension Sociallink {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(Sociallink.self, from: data)
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
        web: String? = nil,
        facebook: String? = nil,
        google: String? = nil,
        twitter: String? = nil,
        youtube: String? = nil,
        instagram: String? = nil,
        pinterest: String? = nil,
        linkedin: String? = nil
        ) -> Sociallink {
        return Sociallink(
            web: web ?? self.web,
            facebook: facebook ?? self.facebook,
            google: google ?? self.google,
            twitter: twitter ?? self.twitter,
            youtube: youtube ?? self.youtube,
            instagram: instagram ?? self.instagram,
            pinterest: pinterest ?? self.pinterest,
            linkedin: linkedin ?? self.linkedin
        )
    }
    
    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

public extension Userstatistics {
    public init(data: Data) throws {
        self = try newJSONDecoder().decode(Userstatistics.self, from: data)
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
        besponsored: Int? = nil
        ) -> Userstatistics {
        return Userstatistics(
            besponsored: besponsored ?? self.besponsored
        )
    }
    
    public func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    public func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
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
