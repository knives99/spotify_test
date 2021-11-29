//
//  APICaller.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import Foundation

final class APICaller{
    
    static let shared = APICaller()
    private init(){}
    
    struct Constants{
        static let baseAPIURL :String = "https://api.spotify.com/v1"
    }
    
    enum APIError {
        case failedToGetData
    }
    
    public func  getCurrentUserProfile(completion:@escaping (Result<UserProfile,Error>)->Void){
        
        createRequest(with: URL(string: Constants.baseAPIURL + "/me"), type: .GET) { baseRequest in
            
            let task = URLSession.shared.dataTask(with: baseRequest) { data, response, error in
                guard let data = data ,error == nil else {
                    completion(.failure(error!))
                    return}
                do{
                    let result = try JSONDecoder().decode(UserProfile.self, from: data)
//                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    completion(.success(result))
                }catch{
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    enum HTTPMethod:String{
        case GET
        case POST
    }
    
    private func createRequest(with url:URL? ,type:HTTPMethod,completion:@escaping(URLRequest)->Void){
        guard let apiURL = url else {return}
        
        AuthManager.shared.withVaildToken { token in
            var request = URLRequest(url: apiURL)
            request.httpMethod = type.rawValue
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 30
            
            completion(request)
        }
    }
    
}
