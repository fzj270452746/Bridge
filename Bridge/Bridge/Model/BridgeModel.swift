//
//  BridgeModel.swift
//  Bridge
//
//  Created by Zhao on 2025/11/29.
//

import UIKit

// MARK: - Mahjong Tile Category
enum MahjongCategory: String, CaseIterable {
    case bamboo = "Bamboo"
    case character = "Character"
    case dots = "Dots"
    
    var prefixIdentifier: String {
        switch self {
        case .bamboo: return "ari"
        case .character: return "bri"
        case .dots: return "cri"
        }
    }
    
    var displayTitle: String {
        return rawValue
    }
}

// MARK: - Mahjong Tile Model
struct MahjongTileEntity {
    let imagery: UIImage
    let magnitude: Int
    let category: MahjongCategory
    let uniqueIdentifier: String
    
    init(imagery: UIImage, magnitude: Int, category: MahjongCategory) {
        self.imagery = imagery
        self.magnitude = magnitude
        self.category = category
        self.uniqueIdentifier = UUID().uuidString
    }
}

// MARK: - Mahjong Repository
class MahjongTileRepository {
    static let shared = MahjongTileRepository()
    
    var bambooCollection: [MahjongTileEntity] = []
    var characterCollection: [MahjongTileEntity] = []
    var dotsCollection: [MahjongTileEntity] = []
    
    private init() {
        configureCollections()
    }
    
    private func configureCollections() {
        // Bamboo tiles
        for index in 1...9 {
            if let imagery = UIImage(named: "ari \(index)") {
                let tile = MahjongTileEntity(imagery: imagery, magnitude: index, category: .bamboo)
                bambooCollection.append(tile)
            } else {
            }
        }
        
        // Character tiles
        for index in 1...9 {
            if let imagery = UIImage(named: "bri \(index)") {
                let tile = MahjongTileEntity(imagery: imagery, magnitude: index, category: .character)
                characterCollection.append(tile)
            } else {
            }
        }
        
        // Dots tiles
        for index in 1...9 {
            if let imagery = UIImage(named: "cri \(index)") {
                let tile = MahjongTileEntity(imagery: imagery, magnitude: index, category: .dots)
                dotsCollection.append(tile)
            } else {
            }
        }
        
    }
    
    func fetchAllCategories() -> [MahjongCategory] {
        return MahjongCategory.allCases
    }
    
    func fetchTiles(for category: MahjongCategory) -> [MahjongTileEntity] {
        switch category {
        case .bamboo: return bambooCollection
        case .character: return characterCollection
        case .dots: return dotsCollection
        }
    }
    
    func generateRandomTiles(count: Int) -> [MahjongTileEntity] {
        var allTiles: [MahjongTileEntity] = []
        allTiles.append(contentsOf: bambooCollection)
        allTiles.append(contentsOf: characterCollection)
        allTiles.append(contentsOf: dotsCollection)
        
        return Array(allTiles.shuffled().prefix(count))
    }
}
