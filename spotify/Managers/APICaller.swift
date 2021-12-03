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
    
    enum APIError:Error {
        case failedToGetData
    }
    
    
    //MARK: - Browse
    public func gerNewRelease(completion:@escaping(Result<NewReleaseResponse,Error>) -> Void){
        createRequest(with: URL(string: Constants.baseAPIURL  + "/browse/new-releases?limit=50"), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(error!))
                    return
                }
                do{
                    let result = try JSONDecoder().decode(NewReleaseResponse.self, from: data)
                    completion(.success(result))
                }catch{
                    completion(.failure(APIError.failedToGetData ))
                    print(error)
                }
             
            }
            task.resume()
        }
    }
    
    public func getFeaturedPlaylists(completion:@escaping (Result<FeaturedPlaylistsResponse,Error>)->Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/featured-playlists?limit=20"),
                      type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data , error == nil else {
                    completion(.failure(error!))
                    return
                }
                do{
//                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    let result = try JSONDecoder().decode(FeaturedPlaylistsResponse.self, from: data)
                    completion(.success(result))
                }catch{
                    completion(.failure(APIError.failedToGetData ))
                    print(error)
                }
             
            }
            task.resume()
        }
    }
    
    //MARK: - albums
    
    func getAlbumDetails(for album:Album,completion:@escaping (Result<AlbumDetailsResponse,Error>) -> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/albums/" + album.id), type: .GET) {  request in
 
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
//                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    let result = try JSONDecoder().decode(AlbumDetailsResponse.self, from: data)
                    completion(.success(result))
                }catch{
                    print(error)
                    completion(.failure(error))
                }
            }
            task.resume()
        }
    }
    
    //MARK: - Playlists
    public func getDetailPlaylist(with playlist:Playlist,completion:@escaping (Result<PlaylistDetailsResponse,Error>)-> Void){
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/" + playlist.id), type: .GET) { request in
            let task = URLSession.shared.dataTask(with: request) { data, _, error in
                
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    return
                }
                do{
//                    let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                    let result = try JSONDecoder().decode(PlaylistDetailsResponse.self, from: data)
                    completion(.success(result))
                }catch{
                    print(error)
                    assertionFailure()
                }

            }
            task.resume()
        }
    }
    
    //MARK: - Profile
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
    
    public func getRecommendations(genres:Set<String>,completion:@escaping((Result<RecommendationsResponse,Error>) -> Void)){
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=40&seed_genres=\(seeds)"), type: .GET) { baseRequest in

            let task = URLSession.shared.dataTask(with: baseRequest) { data, response, error in
                guard let data = data ,error == nil else {
                    completion(.failure(error!))
                    return}
                do{
                    let result = try JSONDecoder().decode(RecommendationsResponse.self, from: data)
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
    
    public func getRecommendedGenres(completion:@escaping (Result<RecommendedGenresResponse,Error>) -> Void){
        
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"), type: .GET) { baseRequest in
            let task = URLSession.shared.dataTask(with: baseRequest) { data, response, error in
                guard let data = data ,error == nil else {
                    completion(.failure(error!))
                    return}
                do{
                    let result = try JSONDecoder().decode(RecommendedGenresResponse.self, from: data)
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
    
    //MARK: - Private
    
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
