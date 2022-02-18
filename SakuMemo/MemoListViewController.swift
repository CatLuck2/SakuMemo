//
//  ViewController.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/18.
//

import UIKit
import RealmSwift

final class MemoListViewController: UIViewController {

    @IBOutlet weak private var listTableView: UITableView!
    @IBOutlet weak private var editListBarButton: UIBarButtonItem!
    @IBOutlet weak private var addMemoButton: UIButton!
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
        guard let memoEditViewController = self.storyboard?.instantiateViewController(withIdentifier: MemoEditViewController.Identifier.segueFromList.rawValue) as? MemoEditViewController else {
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
        //        if memoListDatas.isEmpty == false {
        //            for element in memoListDatas {
        //                do {
        //                    let attributeString = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSMutableAttributedString.self, from: element.sentence)
        //                    attributeString!.enumerateAttribute(.font, in: NSRange(location: 0, length: attributeString!.length)) { result, range, _ in
        //                        // 既にAttributeが付与されているか
        //                        if let attrFont = result as? UIFont {
        //                            var newDescriptor = attrFont.fontDescriptor.withFamily("Hiragino Kaku Gothic Interface")
        //                            // ・・・中略
        //                            let scaledFont = UIFont(descriptor: newDescriptor, size: attrFont.pointSize)
        //                            attributeString!.addAttribute(.font, value: scaledFont, range: range)
        //                        }
        //                    }
        //                } catch let error as NSError {
        //                    print(error)
        //                }
        //            }
        //        }
        listTableView.reloadData()
    }

    /*
     listTableViewの設定、addMemoButtonのレイアウト設定
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        listTableView.delegate = self
        listTableView.dataSource = self
        listTableView.register(UINib(nibName: MemoListTableViewCell.Identifier.nibName.rawValue, bundle: nil), forCellReuseIdentifier: MemoListTableViewCell.Identifier.forCellReuseIdentifier.rawValue)
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.Identifier.forCellReuseIdentifier.rawValue, for: indexPath) as? MemoListTableViewCell else {
            return UITableViewCell()
        }
        do {
            let data = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSMutableAttributedString.self, from: memoListDatas[indexPath.row].sentence)
            data!.enumerateAttribute(.font, in: NSRange(location: 0, length: data!.length)) { result, range, _ in
                // 既にAttributeが付与されているか
                if let attrFont = result as? UIFont {
                    var newDescriptor = attrFont.fontDescriptor.withFamily("Hiragino Kaku Gothic Interface")
                    // ・・・中略
                    let scaledFont = UIFont(descriptor: newDescriptor, size: attrFont.pointSize)
                    data!.addAttribute(.font, value: scaledFont, range: range)
                }
            }
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
        guard let memoEditViewController = self.storyboard?.instantiateViewController(withIdentifier: MemoEditViewController.Identifier.segueFromList.rawValue) as? MemoEditViewController else {
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
