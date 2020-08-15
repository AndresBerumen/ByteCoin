//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation


protocol CoinManagerDelegate {
    func didUpdate(_ coinManager: CoinManager, coin: Double)
}


struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "1E966D7F-6134-486C-8F6D-F9A4AA42A360"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    var delegate: CoinManagerDelegate?
    
    
    func getCoinPrice(for currency: String) {
        let urlString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        self.performRequest(with: urlString)
    }
    
    func performRequest(with URLString: String) {
        // 1. Create the URL
        if let url = URL(string: URLString) {
            
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. give the session a task
            let task = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil {
                    print(error!)
                }
                
                if let safeData = data {
                    if let coin = self.parseJSON(safeData) {
                        self.delegate?.didUpdate(self, coin: coin)
                    }
                }
            }
            
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        } catch {
            print(error)
            return nil
        }
    }
}
