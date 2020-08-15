//
//  CurrencyManager.swift
//  ByteCoin
//
//  Created by Andrés Berumen on 30/07/20.
//  Copyright © 2020 The App Brewery. All rights reserved.
//

import Foundation



protocol CurrencyManagerDelegate {
    func didFailWithError(error: Error)
    func didUpdate(_ currencyManager: CurrencyManager, currencyData: Float)
}



struct CurrencyManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate"
    let apiKey = "1E966D7F-6134-486C-8F6D-F9A4AA42A360"
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    let currencyArray2 = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    
    var delegate: CurrencyManagerDelegate?
    
    
    func getCurrency1(currency1: String, currency2: String) {
        let url = "\(baseURL)/\(currency1)/\(currency2)?apikey=\(apiKey)"
        self.performRequest(with: url)
    }
    
    func performRequest(with urlString: String) {
        // 1. Create the URL
        if let url = URL(string: urlString) {
            
            // 2. Create a URLSession
            let session = URLSession(configuration: .default)
            
            // 3. give the session a task
            let task = session.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
                if error != nil {
                    print(error!)
                }
                
                if let safeData = data {
                    if let price = self.parseJSON(safeData) {
                        self.delegate?.didUpdate(self, currencyData: price)
                    }
                }
            }
            // 4. Start the task
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Float? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CurrencyData.self, from: data)
            let lastPrice = decodedData.rate
            return lastPrice
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
}

