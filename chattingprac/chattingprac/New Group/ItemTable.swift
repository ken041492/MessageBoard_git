//
//  ItemTable.swift
//  chattingprac
//
//  Created by imac-1682 on 2023/7/12.
//

import Foundation
import RealmSwift

struct ItemTable{

    var uuid: ObjectId
    var Name: String = ""
    var Content: String = ""
    var CurrentTime: String = ""
    var sortedIndex: Int = 0
    
    

}
