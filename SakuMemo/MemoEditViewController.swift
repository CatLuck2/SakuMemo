//
//  MemoEditViewController.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/19.
//

import UIKit
import RealmSwift

class MemoEditViewControlelr: UIViewController {
    
    @IBOutlet weak var memoTextView: UITextView!
    private var selectedMemoModel: MemoModel?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedMemoModel != nil {
            memoTextView.text = selectedMemoModel!.sentence
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonsInKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if selectedMemoModel != nil {
            do {
                let realm = try Realm()
                try realm.write {
                    selectedMemoModel!.sentence = memoTextView.text
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            let newMemoModel = MemoModel()
            newMemoModel.title = "タイトル"
            newMemoModel.sentence = memoTextView.text
            do {
                let realm = try Realm()
                try realm.write {
                    realm.add(newMemoModel, update: .modified)
                }
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    func setSelectedMemoModel(memoModel: MemoModel) {
        self.selectedMemoModel = memoModel
    }
    
    func setButtonsInKeyboard() {
        let keyboardBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        keyboardBar.barStyle = UIBarStyle.default
        keyboardBar.sizeToFit()
        
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)

        let bold = UIBarButtonItem(title: "B", style: .plain, target: self, action: nil)
        bold.tintColor = .systemBlue

        let italic = UIBarButtonItem(title: "I", style: .plain, target: self, action: nil)
        italic.tintColor = .systemBlue

        let underline = UIBarButtonItem(title: "_", style: .plain, target: self, action: nil)
        underline.tintColor = .systemBlue

        let strikeThrough = UIBarButtonItem(title: "-", style: .plain, target: self, action: nil)
        strikeThrough.tintColor = .systemBlue

        
        keyboardBar.items = [spacer, bold, spacer, italic, spacer, underline, spacer, strikeThrough, spacer]

        memoTextView.inputAccessoryView = keyboardBar
    }


}
