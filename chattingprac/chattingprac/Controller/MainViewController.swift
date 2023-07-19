//
//  MainViewController.swift
//  chattingprac
//
//  Created by imac-1682 on 2023/7/12.
//
import UIKit
import RealmSwift
import SwiftUI

class MessageBoard: Object {
    @Persisted(primaryKey: true) var uuid: ObjectId
    @Persisted var Name: String = ""
    @Persisted var Content: String = ""
    @Persisted var CurrentTime: String = ""
    @Persisted var sortedIndex: Int = 0
    
    override static func primaryKey() -> String?{
        return "uuid"
    }
    
    convenience init(Name: String, Content: String, CurrentTime: String) {
       self.init()
       self.Name = Name
       self.Content = Content
       self.CurrentTime = CurrentTime
   }
}

class MainViewController: UIViewController {
    
    @IBOutlet weak var message_people: UITextField!
    @IBOutlet weak var message_content: UITextView!
    @IBOutlet weak var button_sent: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortBTN: UIButton!
    
    var deleteArr_cell: MessageBoard?
    var edit_cell: MessageBoard?
    var edit_uuid: ObjectId?
    var message_array: [MessageBoard] = []
    var editCell_Time: MessageBoard?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.register(UINib(nibName: "MainTableViewCell", bundle: nil), forCellReuseIdentifier: MainTableViewCell.identified)
        tableView.delegate = self
        tableView.dataSource = self
        button_sent.setTitle("送出", for: .normal)
        let realm = try! Realm()
        let Message_boards = realm.objects(MessageBoard.self)
        for messageboard in Message_boards{
            message_array.append(messageboard)
        }
        print("file: \(realm.configuration.fileURL!)")

    }
    
    @IBAction func SendMessageBTN(_ sender: UIButton) {
        
        let realm = try! Realm()
        if button_sent.currentTitle == "送出"{
            
            if let user = message_people.text, let message = message_content.text {
                if user == "" && message == "" {
                    let controller = UIAlertController(title: "沒有輸入任何文字", message: "請留言", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    controller.addAction(okAction)
                    present(controller, animated: true)
                }else {
                    let new_message = MessageBoard(Name: user, Content: message, CurrentTime: getSystemTime())
                    try! realm.write {
                        realm.add(new_message)
                    }
                    message_array.append(new_message)
                    tableView.reloadData()
                    message_people.text = ""
                    message_content.text = ""
                }
            }
        }
        
        if button_sent.currentTitle  == "編輯" {
            
            try! realm.write{
                edit_cell?.Name = self.message_people.text ?? ""
                edit_cell?.Content = self.message_content.text ?? ""
                edit_cell?.CurrentTime = getSystemTime()
                
                self.editCell_Time?.Name = self.edit_cell?.Name ?? ""
                self.editCell_Time?.Content = self.edit_cell?.Content ?? ""
                self.editCell_Time?.CurrentTime = edit_cell?.CurrentTime ?? ""
            }
        }
        
        tableView.reloadData()
        self.button_sent.setTitle("送出", for: .normal)
        self.button_sent.backgroundColor = UIColor.blue
        message_people.text = ""
        message_content.text = ""
    }
    
    @IBAction func SortBTN(_ sender: UIButton) {
        
        sortMessage()
    }
    
    func getSystemTime() -> String {
        
        let currectDate = Date()
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale.ReferenceType.system
        dateFormatter.timeZone = TimeZone.ReferenceType.system
        return dateFormatter.string(from: currectDate)
    }
    
    func sortMessage() {
        
        let realm = try! Realm()
        let MessageBoards = realm.objects(MessageBoard.self)
        
        if MessageBoards.count == 0 {
            let controller = UIAlertController(title: "沒有輸入留言", message: "請留言", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            controller.addAction(okAction)
            present(controller, animated: true)
        }else {
            
            let alertController = UIAlertController(title: "請選擇留言排序方式", message: "排序方式為送出/更新留言的時間早晚", preferredStyle: .actionSheet)
            
            let fromNewToOldAction = UIAlertAction(title: "從新到舊", style: .default) { _ in
                
                let sort_result = MessageBoards.sorted(byKeyPath: "CurrentTime" , ascending: false )
                try! realm.write {
                    for (index, messageBoard) in sort_result.enumerated() {
                        messageBoard.sortedIndex = index
                    }
                }
                
                self.message_array = []
                guard sort_result.count > 0 else{
                    self.tableView.reloadData()
                    return
                }
                for i in 0..<sort_result.count{
                    self.message_array.append(MessageBoard(Name: sort_result[i]["Name"] as! String,
                                                           Content: sort_result[i]["Content"] as! String,
                                                           CurrentTime: sort_result[i]["CurrentTime"] as! String)
                    )
                }
                
                self.tableView.reloadData()
                
            }
            let fromOldToNewAction = UIAlertAction(title: "從舊到新", style: .default) { _ in
                
                let sort_result = realm.objects(MessageBoard.self).sorted(byKeyPath: "CurrentTime" , ascending: true )
                try! realm.write {
                    for (index, messageBoard) in sort_result.enumerated() {
                        messageBoard.sortedIndex = index
                    }
                }
                
                self.message_array = []
                guard sort_result.count > 0 else{
                    self.tableView.reloadData()
                    return
                }
                for i in 0 ..< sort_result.count{
                    self.message_array.append(MessageBoard(Name: sort_result[i]["Name"] as! String,
                                                           Content: sort_result[i]["Content"] as! String,
                                                           CurrentTime: sort_result[i]["CurrentTime"] as! String)
                    )
                }
                self.tableView.reloadData()
            }
            let closeAction = UIAlertAction(title: "關閉", style: .cancel, handler: nil)
            alertController.addAction(fromNewToOldAction)
            alertController.addAction(fromOldToNewAction)
            alertController.addAction(closeAction)
            self.present(alertController, animated: true)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return message_array.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identified, for: indexPath) as! MainTableViewCell
        cell.label?.text = String(message_array[indexPath.row].Name)
        cell.label2?.text = String(message_array[indexPath.row].Content)
        return cell
    }

    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "delete") { (_, _, completionHandler) in
            
            let realm = try! Realm()
//            let Message_Boards = realm.objects(MessageBoard.self)
            if indexPath.row < self.message_array.count {
                
                self.deleteArr_cell = self.message_array[indexPath.row]
                let edit_CurrentTime = self.deleteArr_cell?.CurrentTime
                let delect_cell = realm.objects(MessageBoard.self).where {
                    $0.CurrentTime == edit_CurrentTime ?? ""
                }[0]
                
                try! realm.write {
                    realm.delete(delect_cell)
                }
                
                self.message_array.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .automatic)
//            tableView.reloadRows(at: IndexPath.row, with: .automatic)
            completionHandler(true) // 告訴系統滑動操作已完成
        }
        deleteAction.backgroundColor = UIColor.red
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let editAction = UIContextualAction(style: .normal, title: "edit") { [self] (_, _, completionHandler) in
            
            self.button_sent.setTitle("編輯", for: .normal)
            self.button_sent.backgroundColor = UIColor.magenta
            if indexPath.row < message_array.count{
                
                self.edit_cell = message_array[indexPath.row]
                self.message_people.text = self.edit_cell?.Name
                self.message_content.text = self.edit_cell?.Content
                let edit_CurrentTime = self.edit_cell?.CurrentTime
                let realm = try! Realm()
                editCell_Time = realm.objects(MessageBoard.self).where {
                    $0.CurrentTime == edit_CurrentTime ?? ""
                }[0]
            }
            tableView.reloadData()
            completionHandler(true)
        }
        
        editAction.backgroundColor = UIColor.blue // 設置編輯操作的背景顏色
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [editAction])
        return swipeConfiguration
    }
}


