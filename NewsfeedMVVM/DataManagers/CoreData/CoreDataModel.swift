//
//  NewsEntity+CoreDataClass.swift
//  
//
//  Created by Alexander Milgunov on 30.07.2020.
//
//

import CoreData

@objc(NewsEntity)
public class NewsEntity: NSManagedObject {

}

extension NewsEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<NewsEntity> {
        return NSFetchRequest<NewsEntity>(entityName: NewsEntity.entityName)
    }

    @NSManaged public var urlToImage: String?
    @NSManaged public var title: String?
    @NSManaged public var newsDescription: String?
    @NSManaged public var publishedAt: Date?
    @NSManaged public var author: String?
    @NSManaged public var content: String?
    
    static let entityName = "NewsEntity"
    
    static let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "YYYY-MM-dd hh:mm"
        return df
    }()
    
    func update(with jsonData: News) throws {

        self.urlToImage = jsonData.urlToImage
        self.title = jsonData.title
        self.newsDescription = jsonData.newsDescription
        self.publishedAt = ISO8601DateFormatter().date(from: jsonData.publishedAt ?? "")
        self.author = jsonData.author
        self.content = jsonData.content
    }

}
