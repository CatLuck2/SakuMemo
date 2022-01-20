//
//  ViewController.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/18.
//

import UIKit
import RealmSwift

class MemoListViewController: UIViewController {
    
    @IBOutlet weak var listTableView: UITableView!
    private var memoListDatas: [MemoModel] = []
    @IBOutlet weak var editListBarButton: UIBarButtonItem!
    @IBOutlet weak var addMemoButton: UIButton!
    
    
    @IBAction func editListBarButton(_ sender: UIBarButtonItem) {
        if listTableView.isEditing == true {
            editListBarButton.title = "編集"
            listTableView.isEditing = false
        } else {
            editListBarButton.title = "完了"
            listTableView.isEditing = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(UINib(nibName: "MemoListTableViewCell", bundle: nil), forCellReuseIdentifier: "MemoListTableViewCellID")
        listTableView.layer.cornerRadius = 10
        
        addMemoButton.layer.cornerRadius = 40
        addMemoButton.layer.backgroundColor = UIColor.white.cgColor
        addMemoButton.layer.shadowOpacity = 0.6
        addMemoButton.layer.shadowRadius = 8.0
        addMemoButton.layer.shadowColor = UIColor.black.cgColor
        addMemoButton.layer.shadowOffset = CGSize(width: 2.0, height: 1.0)
      
//        // テストデータを追加
//        let memoModel = MemoModel()
//        memoModel.title = "タイトル"
//        memoModel.sentence = "文章文章文章文章文章文章"
//        do {
//            let realm = try Realm()
//            try realm.write {
//                realm.add(memoModel)
//            }
//        } catch let error as NSError {
//            print(error)
//        }
        
        //　テストデータを取得
        do {
            let realm = try Realm()
            let results = realm.objects(MemoModel.self)
            for result in results {
                memoListDatas.append(result)
            }
            print(memoListDatas)
        } catch let error as NSError {
            print(error)
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
    }

}

extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoListDatas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MemoListTableViewCellID", for: indexPath) as? MemoListTableViewCell else {
            return UITableViewCell()
        }
        cell.setMemoDatasToCell(title: memoListDatas[0].title, sentence: memoListDatas[0].sentence)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let memoEditViewController = self.storyboard?.instantiateViewController(withIdentifier: "segueToMemoEditViewController") as? MemoEditViewControlelr else {
            return
        }
        self.navigationController?.pushViewController(memoEditViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                let realm = try Realm()
                try realm.write {
                    memoListDatas.remove(at: indexPath.row)
                }
            } catch let error as NSError {
                print(error)
            }
        }
        tableView.reloadData()
    }
}
