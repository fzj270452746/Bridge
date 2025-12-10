//
//  GameRecordManager.swift
//  Bridge
//
//  Created by Zhao on 2025/11/29.
//

import Foundation

// MARK: - Game Record Entity
struct GameRecordEntity: Codable {
    let identifier: String
    let score: Int
    let timestamp: Date
    
    init(score: Int, timestamp: Date) {
        self.identifier = UUID().uuidString
        self.score = score
        self.timestamp = timestamp
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - Game Record Manager
class GameRecordManager {
    
    static let shared = GameRecordManager()
    
    private let storageKey = "MahjongBridgeRecords"
    private var records: [GameRecordEntity] = []
    
    private init() {
        loadRecords()
    }
    
    func fetchAllRecords() -> [GameRecordEntity] {
        let sorted = records.sorted { $0.timestamp > $1.timestamp }

        return sorted
    }
    
    func appendRecord(_ record: GameRecordEntity) {
        records.append(record)
        persistRecords()

    }
    
    func removeRecord(at index: Int) {
        let sortedRecords = fetchAllRecords()
        guard index < sortedRecords.count else { return }
        
        let recordToRemove = sortedRecords[index]
        records.removeAll { $0.identifier == recordToRemove.identifier }
        persistRecords()
    }
    
    func purgeAllRecords() {
        records.removeAll()
        persistRecords()

    }
    
    func calculateHighestScore() -> Int {
        return records.map { $0.score }.max() ?? 0
    }
    
    func calculateAverageScore() -> Double {
        guard !records.isEmpty else { return 0 }
        let total = records.reduce(0) { $0 + $1.score }
        return Double(total) / Double(records.count)
    }
    
    private func persistRecords() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(records)
            UserDefaults.standard.set(data, forKey: storageKey)

        } catch {
            print("Failed to persist records: \(error)")
        }
    }
    
    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            records = try decoder.decode([GameRecordEntity].self, from: data)

        } catch {
            print("Failed to load records: \(error)")
        }
    }
}

