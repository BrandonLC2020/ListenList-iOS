//
//  SpotifyAPIManager.swift
//  ListenList
//
//  Created by Brandon Lamer-Connolly on 10/12/24.
//

import Foundation

class SpotifyAPIManager: ObservableObject {
    
    var accessToken: String
    var tokenType: String
    
    init() {
        self.accessToken = ""
        self.tokenType = ""
    }
    
    init(access: String, token: String) {
        self.accessToken = access
        self.tokenType = token
    }
    
    func searchSongs(query: String, type: String, userCompletionHandler: @escaping (SongSearchResponse?) -> Void) {
        //print("this is the access token: \(accessToken)")
        let formattedQuery = query.replacingOccurrences(of: " ", with: "+")
        let urlStr = "https://api.spotify.com/v1/search?q=\(formattedQuery)&type=\(type)&market=US&limit=50&offset=0"
        let authorizationAccessTokenStr = accessToken
        let authorizationTokenTypeStr = tokenType
        let requestHeaders: [String:String] = ["Authorization" : "\(authorizationTokenTypeStr) \(authorizationAccessTokenStr)"]
        //print(requestHeaders)
        var request = URLRequest(url: URL(string: urlStr)!)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = requestHeaders
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            guard
                let data = data,
                let response = response as? HTTPURLResponse,
                error == nil
            else {
                print("error", error ?? URLError(.badServerResponse))
                return
            }
            
            guard (200 ... 299) ~= response.statusCode else {
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            do {
                //print(data)
                let responseObject: SongSearchResponse = try JSONDecoder().decode(SongSearchResponse.self, from: data)
                //print(responseObject)
                userCompletionHandler(responseObject)
                
            } catch {
                print(error) // parsing error
                if let responseString = String(data: data, encoding: .utf8) {
                    print("responseString = \(responseString)")
                } else {
                    print("unable to parse response as string")
                }
            }
        }).resume()
        //print(result)
    }
    
}
