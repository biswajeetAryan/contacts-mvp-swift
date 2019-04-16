//
//  GKURLConnectionManager.swift
//  Contacts
//
//  Created by Tirupati Balan on 16/04/19.
//  Copyright © 2019 Tirupati Balan. All rights reserved.
//

import Foundation

class GKURLConnectionManager {
    class var sharedInstance : GKURLConnectionManager {
        struct Singleton {
            static let instance = GKURLConnectionManager()
        }
        
        return Singleton.instance
    }
    
    func shouldReadResponseForRequest(_ apiRequest : GKAPIRequest) -> Bool  {
        switch apiRequest.requestType {
        case GKAPIRequestType.APIRequestContactList?:
            return true
        default:
            return false
        }
    }
    
    func connectionWithRequest(_ apiRequest: GKAPIRequest) -> URLSessionTask {
        return self.connectionWithRequest(apiRequest, success: nil, failure: nil)
    }
    
    func connectionWithRequest(_ apiRequest: GKAPIRequest, success: ((Any) ->
        Void)!, failure:((Error) -> Void)!) -> URLSessionTask {
        var dataRequest : URLSessionTask!
        dataRequest = GKURLSessionManager.performRequest(apiRequest, success: { (response) in
            self.didPerformRequest(apiRequest)
            self.request(apiRequest, didReceiveResponse: response, success: success)
        }, failure: { (error) in
            self.didPerformRequest(apiRequest)
            self.remoteRequestDidFail(apiRequest, error, failure: failure)
        })
        
        return dataRequest
    }
    
    func request(_ apiRequest: GKAPIRequest, didReceiveResponse response : JSON, success: ((Any) ->
        Void)!) { //handle response either insert into database and notify controller or use local notification to notifiy
        
        switch apiRequest.requestType {
        case .APIRequestContactList?:
            var arrayObject : [Contact] = []
            if let responseObject = response as? NSArray {
                for value in responseObject {
                    if let value = value as? Data {
                        let contact = try? JSONDecoder().decode(Contact.self, from: value)
                        if let contact = contact {
                            arrayObject.append(contact)
                        }
                    }
                }
            }
            success(arrayObject as JSONArray)
            break
        default:
            success(response as JSON)
            break
        }
    }
    
    func didPerformRequest(_ apiRequest : GKAPIRequest) {
        apiRequest.completed = true
    }
    
    func remoteRequestDidFail(_ apiRequest: GKAPIRequest, _ error : Error, failure:((Error) -> Void)!) { //handle error with custom error and use local notification for error
        failure(error)
    }
    
}