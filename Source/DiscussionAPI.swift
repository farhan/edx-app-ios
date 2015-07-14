//
//  DiscussionAPI.swift
//  edX
//
//  Created by Tang, Jeff on 6/26/15.
//  Copyright (c) 2015 edX. All rights reserved.
//

import Foundation

struct Topic {
    var id: String?
    var name: String?
    var children: [Topic]?
    
    init(id: String?, name: String?, children: [Topic]?) {
        self.id = id
        self.name = name
        self.children = children
    }
    
    init?(json: JSON) {
        if  let name = json["name"].string {
            if let children = json["children"].array {
                self.id = json["id"].string
                self.name = name

                if children.count > 0 {
                    var resultChild: [Topic] = []
                    for child in children {
                        if  let name = child["name"].string {
                            resultChild.append(Topic(id: child["id"].string, name: name, children: nil))
                        }
                    }
                    self.children = resultChild
                }
                else {
                    self.children = nil
                }
            }
        }
        else {
            return nil
        }
    }
}

public class DiscussionAPI {
    static func createNewThread(newThread: DiscussionNewThread) -> NetworkRequest<DiscussionThread> {
        let json = JSON([
            "course_id" : newThread.courseID,
            "topic_id" : newThread.topicID,
            "type" : newThread.type,
            "title" : newThread.title,
            "raw_body" : newThread.rawBody,
            ])
        return NetworkRequest(
            method : HTTPMethod.POST,
            path : "/api/discussion/v1/threads/",
            requiresAuth : true,
            body: RequestBody.JSONBody(json),
            deserializer : {(response, data) -> Result<DiscussionThread> in
                return Result(jsonData : data, error : NSError.oex_unknownError()) {
                    return DiscussionThread(json: $0)
                }
        })
    }
    
    static func createNewComment(json: JSON) -> NetworkRequest<DiscussionComment> {
        return NetworkRequest(
            method : HTTPMethod.POST,
            path : "/api/discussion/v1/comments/",
            requiresAuth : true,
            body: RequestBody.JSONBody(json),
            deserializer : {(response, data) -> Result<DiscussionComment> in
                return Result(jsonData : data, error : NSError.oex_unknownError()) {
                    return DiscussionComment(json: $0)
                }
        })
    }
    
    // User can only vote on post and response not on comment.
    // thread is the same as post
    static func voteThread(json: JSON, threadID: String) -> NetworkRequest<DiscussionThread> {
        return NetworkRequest(
            method : HTTPMethod.PATCH,
            path : "/api/discussion/v1/threads/\(threadID)/",
            requiresAuth : true,
            body: RequestBody.JSONBody(json),
            deserializer : {(response, data) -> Result<DiscussionThread> in
                return Result(jsonData : data, error : NSError.oex_unknownError()) {
                    return DiscussionThread(json: $0)
                }
        })
    }
    
    static func voteResponse(json: JSON, responseID: String) -> NetworkRequest<DiscussionComment> {
        return NetworkRequest(
            method : HTTPMethod.PATCH,
            path : "/api/discussion/v1/comments/\(responseID)/",
            requiresAuth : true,
            body: RequestBody.JSONBody(json),
            deserializer : {(response, data) -> Result<DiscussionComment> in
                return Result(jsonData : data, error : NSError.oex_unknownError()) {
                    return DiscussionComment(json: $0)
                }
        })
    }
    
    // User can flag (report) on post, response, or comment
    static func flagThread(json: JSON, threadID: String) -> NetworkRequest<DiscussionThread> {
        return NetworkRequest(
            method : HTTPMethod.PATCH,
            path : "/api/discussion/v1/threads/\(threadID)/",
            requiresAuth : true,
            body: RequestBody.JSONBody(json),
            deserializer : {(response, data) -> Result<DiscussionThread> in
                return Result(jsonData : data, error : NSError.oex_unknownError()) {
                    return DiscussionThread(json: $0)
                }
        })
    }
    
    static func flagComment(json: JSON, commentID: String) -> NetworkRequest<DiscussionComment> {
        return NetworkRequest(
            method : HTTPMethod.PATCH,
            path : "/api/discussion/v1/comments/\(commentID)/",
            requiresAuth : true,
            body: RequestBody.JSONBody(json),
            deserializer : {(response, data) -> Result<DiscussionComment> in
                return Result(jsonData : data, error : NSError.oex_unknownError()) {
                    return DiscussionComment(json: $0)
                }
        })
    }
   
    // User can only follow original post, not response or comment.    
    static func followThread(json: JSON, threadID: String) -> NetworkRequest<DiscussionThread> {
        return NetworkRequest(
            method : HTTPMethod.PATCH,
            path : "/api/discussion/v1/threads/\(threadID)/",
            requiresAuth : true,
            body: RequestBody.JSONBody(json),
            deserializer : {(response, data) -> Result<DiscussionThread> in
                return Result(jsonData : data, error : NSError.oex_unknownError()) {
                    return DiscussionThread(json: $0)
                }
        })
    }
    
    
    static func getThreads(courseID: String) -> NetworkRequest<[DiscussionThread]> {
        return NetworkRequest(
            method : HTTPMethod.GET,
            path : "/api/discussion/v1/threads/",
            query: ["course_id" : JSON(courseID), "following": true],
            requiresAuth : true,
            deserializer : {(response, data) -> Result<[DiscussionThread]> in
                return Result(jsonData : data, error : NSError.oex_unknownError(), constructor: {
                    var result: [DiscussionThread] = []
                    if let threads = $0["results"].array {
                        for json in threads {
                            if let discussionThread = DiscussionThread(json: json) {
                                result.append(discussionThread)
                            }
                        }
                    }
                    return result
                })
        })
    }
    
    static func searchThreads(#courseID: String, searchText: String) -> NetworkRequest<[DiscussionThread]> {
        return NetworkRequest(
            method : HTTPMethod.GET,
            path : "/api/discussion/v1/threads/",
            query: ["course_id" : JSON(courseID), "text_search": JSON(searchText)],
            requiresAuth : true,
            deserializer : {(response, data) -> Result<[DiscussionThread]> in
                return Result(jsonData : data, error : NSError.oex_unknownError(), constructor: {
                    var result: [DiscussionThread] = []
                    if let threads = $0["results"].array {
                        for json in threads {
                            if let discussionThread = DiscussionThread(json: json) {
                                result.append(discussionThread)
                            }
                        }
                    }
                    return result
                })
        })
    }
    
    static func getResponses(threadID: String) -> NetworkRequest<[DiscussionComment]> {
        return NetworkRequest(
            method : HTTPMethod.GET,
            path : "/api/discussion/v1/comments/", // responses are treated similarly as comments
            query: ["page_size" : 20, "thread_id": JSON(threadID)],
            requiresAuth : true,
            deserializer : {(response, data) -> Result<[DiscussionComment]> in
                return Result(jsonData : data, error : NSError.oex_unknownError()) {                    
                    var result: [DiscussionComment] = []
                    if let threads = $0["results"].array {
                        for json in threads {
                            if let discussionComment = DiscussionComment(json: json) {
                                result.append(discussionComment)
                            }
                        }
                    }
                    return result
                }
        })
    }
    
    static func getCourseTopics(courseID: String) -> NetworkRequest<[Topic]> {
        return NetworkRequest(
                method : HTTPMethod.GET,
                path : "/api/discussion/v1/course_topics/\(courseID)",
                requiresAuth : true,
                deserializer : {(response, data) -> Result<[Topic]> in
                    return Result(jsonData : data, error : NSError.oex_unknownError()) {
                        var result: [Topic] = []
                        let topics = ["courseware_topics", "non_courseware_topics"]
                        for topic in topics {
                            if let results = $0[topic].array {
                                for json in results {
                                    if let topic = Topic(json: json) {
                                        result.append(topic)
                                    }
                                }
                            }
                        }
                        return result
                    }
            })
    }

}