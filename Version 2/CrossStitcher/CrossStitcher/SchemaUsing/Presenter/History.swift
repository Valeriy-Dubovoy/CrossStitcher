//
//  History.swift
//  CrossStitcher
//
//  Created by Valery Dubovoy on 13.04.2024.
//

import Foundation

struct HistoryItem {
    let id: Int
    let oldTool: Int16?
    let newTool: Int16?
}

class History {
    var steps: [[ HistoryItem]] = []
    
    func addStep( action: HistoryItem  ) {
        steps.append([action])
    }
    
    var dept: Int {
        return self.steps.count
    }
    
    var available: Bool {
        return dept > 0
    }
}
