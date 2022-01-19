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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.layer.cornerRadius = 10
      
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
        
//        //　テストデータを取得
//        do {
//            let realm = try Realm()
//            let results = realm.objects(MemoModel.self)
//            print(results)
//        } catch let error as NSError {
//            print(error)
//        }
    }


}

extension MemoListViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = UITableViewCell(style: .default, reuseIdentifier: "MemoListTableViewCellID") as? MemoListTableViewCell else {
            return UITableViewCell()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let memoEditViewController = self.storyboard?.instantiateViewController(withIdentifier: "segueToMemoEditViewController") as? MemoEditViewControlelr else {
            return
        }
        self.navigationController?.pushViewController(memoEditViewController, animated: true)
    }
}
