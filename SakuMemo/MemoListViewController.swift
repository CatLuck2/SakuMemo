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
    @IBOutlet weak var editListBarButton: UIBarButtonItem!
    @IBOutlet weak var addMemoButton: UIButton!
    private var memoListDatas: Results<MemoModel>!

    /*
     listTableViewの編集モードを切り替える
     */
    @IBAction func editListBarButton(_ sender: UIBarButtonItem) {
        if listTableView.isEditing == true {
            editListBarButton.title = "編集"
            listTableView.isEditing = false
        } else {
            editListBarButton.title = "完了"
            listTableView.isEditing = true
        }
    }

    /*
     MemoEditViewControllerへ遷移
     */
    @IBAction func addMemoButton(_ sender: UIButton) {
        guard let memoEditViewController = self.storyboard?.instantiateViewController(withIdentifier: "segueToMemoEditViewController") as? MemoEditViewControlelr else {
            return
        }
        self.navigationController?.pushViewController(memoEditViewController, animated: true)
    }

    /*
     Realmのデータ取得、listTableViewの更新
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        memoListDatas = MemoModel.all()
        listTableView.reloadData()
    }

    /*
     listTableViewの設定、addMemoButtonのレイアウト設定
     */
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
    }

    /*
     listTableViewで編集モードを扱うのに必要
     */
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
        do {
            let data = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSMutableAttributedString.self, from: memoListDatas[indexPath.row].sentence)
            cell.setMemoDatasToCell(sentence: data!)
        } catch let error as NSError {
            print(error)
        }
        return cell
    }

    /*
     MemoEditViewControllerへ遷移
     MemoEditViewControllerへ、タップしたセルのindexPath.rowに該当するデータ（MemoModel）、を渡す
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let memoEditViewController = self.storyboard?.instantiateViewController(withIdentifier: "segueToMemoEditViewController") as? MemoEditViewControlelr else {
            return
        }
        memoEditViewController.setSelectedMemoModel(memoModel: memoListDatas[indexPath.row])
        self.navigationController?.pushViewController(memoEditViewController, animated: true)
    }

    /*
     セルを削除時の処理
     idで該当するデータを探し、Realmから削除
     */
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            do {
                let selectedMemoObject = MemoModel.all().filter("id == \(memoListDatas[indexPath.row].id)")
                try MemoModel.realm!.write {
                    MemoModel.realm!.delete(selectedMemoObject)
                }
            } catch let error as NSError {
                print(error)
            }
        }
        tableView.reloadData()
    }
}
