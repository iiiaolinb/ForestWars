//
//  GameCell.swift
//  ForestWars
//
//  Created by Егор Худяев on 09.10.2025.
//

struct GameCell {
    let type: CellType
    let number: Int
    let imageName: String
    var isSelected: Bool
    
    init(type: CellType, number: Int, imageName: String, isSelected: Bool = false) {
        self.type = type
        self.number = number
        self.imageName = imageName
        self.isSelected = isSelected
    }
}
