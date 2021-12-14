//
//  AuthManager.swift
//  spotify
//
//  Created by Bryan on 2021/11/25.
//

import Foundation

final class AuthManager{
    
    static let shared = AuthManager()
    
    private var refreshingToken = false
    
    struct Constant {
        static let clientID = "b7c8f1649f3b494b92bb613e41ef0746"
        static let clientSerect = "4387ec5cdaf6453bb3e8a7bb56712d8e"
        static let tokenAPIURL =  "https://accounts.spotify.com/api/token"
        static let redirectURI = "http://mysite.com/callback/"
        static let scopes = "user-read-private%20playlist-modify-public%20playlist-read-private%20playlist-modify-private%20user-follow-read%20user-library-modify%20user-library-read%20user-read-email"
    }
    
    private init(){}
    
    public var signInURL:URL?{
       
        
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constant.clientID)&scope=\(Constant.scopes)&redirect_uri=\(Constant.redirectURI)&show_dialog=TRUE"
        return URL(string: string)

    }
    
    
    
    
    var isSignin:Bool{
        return accessToken != nil
    }
    
    private var accessToken:String?{
        return UserDefaults.standard.string(forKey: "access_token")
    }
    
    private var refreshToken:String?{
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate:Date?{
        return UserDefaults.standard.string(forKey: "expirationDate") as? Date
    }
    
    
    private var shouldRefreshToke:Bool{
        
        guard let expirationDate = tokenExpirationDate else {return false}
        let currentDate = Date()
        let fiveMinutes:TimeInterval = 300

        return  currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
    }
    
    //最有價值的在這裡！！
    public func exchangeCodeForToken(code:String,completion:@escaping (Bool)->Void){
        //GET Token
        
        guard let url = URL(string: AuthManager.Constant.tokenAPIURL) else {return}
        
        var request = URLRequest(url: url)
        
        //body 資料
        var component = URLComponents()
        component.queryItems = [URLQueryItem(name: "grant_type", value: "authorization_code"),
                                URLQueryItem(name: "code", value: code),
                                URLQueryItem(name: "redirect_uri", value: Constant.redirectURI)
        ]
        
        //header 資料
        let basicToken = Constant.clientID + ":" + Constant.clientSerect
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else{
            print("Failure to get base 64")
            completion(false)
            return
        }
        
        //header
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        //Method
        request.httpMethod = "POST"
        //Body
        request.httpBody  = component.query?.data(using: .utf8)
        
        //網路處理
        let task = URLSession.shared.dataTask(with: request) {[weak self] data, _, error in
            guard let data = data , error == nil else {
                completion(false)
                return
            }
            do{
                //把得到的資料轉成struct 裡面有token
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("SUCCESS \(result)")
                self?.cacheToken(result:result)
                completion(true)
            }catch{
                print(error.localizedDescription)
                completion(false)
            }
        }
        task.resume()
        

    }
    
    private var onRefreshBlocks = [((String)->Void)]()
    
    //提供API Caller 使用有效的Token
    public func withVaildToken(completion:@escaping (String) -> Void){
        guard !refreshingToken else{
            //append the completion
            onRefreshBlocks.append(completion)
            return
        }
        
        if shouldRefreshToke {
            //如果需要更新TOKEN 執行更新Token
            refreshIfNeeded { [weak self]success in
                if let token = self?.accessToken,success{
                    completion(token)
                }
            }
        }
        else if let token = accessToken{
            completion(token)
        }
    }
    
    public func refreshIfNeeded(completion:((Bool)->Void)?){
//        guard !refreshingToken else {return}
//        
//        guard shouldRefreshToke else{
//            completion(true)
//            return
//        }
//        guard let refreshToken = refreshToken else {
//            return
//        }
        
        //refresh Token
        
        guard let url = URL(string: AuthManager.Constant.tokenAPIURL) else {return}
        
        refreshingToken = true
        
        var request = URLRequest(url: url)
        
        var component = URLComponents()
        component.queryItems = [URLQueryItem(name: "grant_type", value: "refresh_token"),
                                URLQueryItem(name: "refresh_token", value:refreshToken)
        ]
        
        let basicToken = Constant.clientID + ":" + Constant.clientSerect
        //轉成data
        let data = basicToken.data(using: .utf8)
        //轉成base64
        guard let base64String = data?.base64EncodedString() else{
            print("Failure to get base 64")
            completion?(false)
            return
        }
        
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"
        request.httpBody  = component.query?.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) {[weak self] data, _, error in
            self?.refreshingToken = false
            guard let data = data , error == nil else {
                completion?(false)
                return
            }
            do{
                let result = try JSONDecoder().decode(AuthResponse.self, from: data)
                print("Successfullt refreshed")
                self?.onRefreshBlocks.forEach{$0(result.access_token)}
                self?.onRefreshBlocks.removeAll()
                self?.cacheToken(result:result)
                completion?(true)
            }catch{
                print(error.localizedDescription)
                completion?(false)
            }
        }
        task.resume()

    }
    
    public func cacheToken(result:AuthResponse){
        UserDefaults.standard.set(result.access_token, forKey: "access_token")
        
        if let refresh_token = result.refresh_token{
            UserDefaults.standard.set(refresh_token, forKey: "refresh_token")
        }
        
        UserDefaults.standard.set(Date().addingTimeInterval(_:TimeInterval(result.expires_in)), forKey: "expirationDate")
    }
    
    public func signOut(completion:(Bool)->Void){
        UserDefaults.standard.set(nil, forKey: "access_token")
        UserDefaults.standard.set(nil, forKey: "refresh_token")
        UserDefaults.standard.set(nil, forKey: "expirationDate")
        completion(true)
    }
    
}
