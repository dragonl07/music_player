//
//  URLTableViewController.swift
//  Audio Streaming
//
//  Created by Sherzod on 1/16/19.
//  Copyright © 2019 Humanz. All rights reserved.
//

import UIKit
import RealmSwift


class URLTableViewController: NSObject, UITableViewDelegate, UITableViewDataSource
{
    var streams = [StreamObject]()

    override init()
    {
        super.init()
        let realm = try! Realm()
        self.streams.append(contentsOf: realm.objects(StreamObject.self))
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.streams.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "streamCell")!
        cell.detailTextLabel?.text = self.streams[indexPath.row].urlString
        cell.textLabel?.text = self.streams[indexPath.row].title
        return cell
    }

    func addStream(_ stream: StreamObject)
    {
        self.streams.append(stream)
        let realm = try! Realm()
        try! realm.write {
            realm.add(stream)
        }
    }
}

class StreamObject: Object
{
    static let MediaTitleKey = "title";
    static let MediaArtistKey = "artist";
    static let MediaUrlKey = "url";
    static let MediaIdKey = "id";
    
    @objc dynamic var urlString: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var id: String = UUID().uuidString

    convenience init(_ urlString: String, _ title: String = "")
    {
        self.init()
        self.urlString = urlString
        self.title = title
    }

//    func writeImage(_ image: UIImage) -> Bool
//    {
//        let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
//        let writePath = URL(fileURLWithPath: documentPath).appendingPathComponent(self.id)
//        if let data = image.jpegData(compressionQuality: 0.5)
//        {
//            do {
//               try data.write(to: writePath, options: .atomic)
//            } catch  {
//                print("Error while writing")
//                return false
//            }
//            return true
//        }
//        return false
//    }

    override static func primaryKey() -> String?
    {
        return "id"
    }
    
    static func generateFlutterData(_ streams: [StreamObject]) -> [[String: Any]]
    {
        var data = [[String: Any]]()
        
        for stream in streams
        {
            var metadata = [String: Any]()
            metadata[MediaTitleKey] = stream.title
            metadata[MediaUrlKey] = stream.urlString
            metadata[MediaIdKey] = stream.id
            data.append(metadata)
        }
        
        return data
    }
}


