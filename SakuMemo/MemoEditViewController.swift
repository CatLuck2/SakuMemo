//
//  MemoEditViewController.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/19.
//

import UIKit
import RealmSwift
import WidgetKit

class MemoEditViewControlelr: UIViewController {

    @IBOutlet weak var memoTextView: UITextView!
    /*
     MemoListViewControllerで選択したMemoModel
     */
    private var selectedMemoModel: MemoModel?

    /*
     フォントサイズを変更しないので、標準サイズを用意。
     */
    private var selectedFontsize: CGFloat? = 14.0

    /*
     MemoEditViewControllerのmemoTextViewで選択した範囲。
     */
    private var selectedRange: NSRange? = NSRange(location: 0, length: 0)

    /*
     selectedMemoModelから、sentence（NSMutableAttributedString）を取り出す
     */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedMemoModel != nil {
            do {
                let data = try NSKeyedUnarchiver.unarchivedObject(ofClass: NSMutableAttributedString.self, from: selectedMemoModel!.sentence)
                memoTextView.attributedText = data
            } catch let error as NSError {
                print(error)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        memoTextView.delegate = self
        setButtonsInKeyboard()
    }

    /*
     MemoEditViewControllerを閉じる時
     selectedMemoModelがnilでない→編集→データの更新
     selectedMemoModelがnilである→新規追加→データの新規追加
     */
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if selectedMemoModel != nil {
            do {
                try MemoModel.realm!.write {
                    // NSMutableAttributedString->Data
                    let data = try NSKeyedArchiver.archivedData(withRootObject: NSMutableAttributedString(attributedString: memoTextView.attributedText), requiringSecureCoding: false)
                    selectedMemoModel!.sentence = data
                }
                DispatchQueue(label: "serial").sync {
                    WidgetCenter.shared.reloadAllTimelines()
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            do {
                let newMemoModel = MemoModel()
                let data = try NSKeyedArchiver.archivedData(withRootObject: NSMutableAttributedString(attributedString: memoTextView.attributedText), requiringSecureCoding: false)
                newMemoModel.sentence = data
                try MemoModel.realm!.write {
                    MemoModel.realm!.add(newMemoModel, update: .modified)
                }
            } catch let error as NSError {
                print(error)
            }
        }
    }

    /*
     MemoListViewControllerから、選択したMemoModelを受け取る
     */
    func setSelectedMemoModel(memoModel: MemoModel) {
        self.selectedMemoModel = memoModel
    }

    /*
     キーボード上部にタブバーを設置
     文字を装飾するためのボタンを4つをタブバー内に設置
     */
    func setButtonsInKeyboard() {
        let keyboardBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 40))
        keyboardBar.barStyle = UIBarStyle.default
        keyboardBar.sizeToFit()

        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)

        let bold = UIBarButtonItem(title: "B", style: .plain, target: self, action: #selector(boldAction))
        bold.tintColor = .systemBlue

        let italic = UIBarButtonItem(title: "I", style: .plain, target: self, action: #selector(italicAction))
        italic.tintColor = .systemBlue

        let underline = UIBarButtonItem(title: "_", style: .plain, target: self, action: #selector(underlineAction))
        underline.tintColor = .systemBlue

        let strikeThrough = UIBarButtonItem(title: "-", style: .plain, target: self, action: #selector(strikeThroughAction))
        strikeThrough.tintColor = .systemBlue

        keyboardBar.items = [spacer, bold, spacer, italic, spacer, underline, spacer, strikeThrough, spacer]

        memoTextView.inputAccessoryView = keyboardBar
    }

    /*
     太字
     */
    @objc func boldAction() {
        let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
        /*
         ①選択した文字列のフォント情報を読み取る
         ②Regularなら太字、それ以外ならsystemFont、に装飾
         理由：太字かを判定するには、標準フォントであるRegularで判断するしかないから
         */
        selectedAttributedText.enumerateAttribute(.font, in: selectedRange!) { result, _, _ in
            if let result = result as? UIFont {
                if result.fontDescriptor.object(forKey: .face)! as? String == "Regular" {
                    selectedAttributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: selectedFontsize!), range: selectedRange!)
                } else {
                    selectedAttributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: selectedFontsize!), range: selectedRange!)
                }
            }
        }
        memoTextView.attributedText = selectedAttributedText
    }

    /*
     斜体
     */
    @objc func italicAction() {
        let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
        selectedAttributedText.enumerateAttribute(.font, in: selectedRange!) { result, _, _ in
            if let result = result as? UIFont {
                if result.fontDescriptor.object(forKey: .face)! as? String == "Regular" {
                    selectedAttributedText.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: selectedFontsize!), range: selectedRange!)
                } else {
                    selectedAttributedText.addAttribute(.font, value: UIFont.systemFont(ofSize: selectedFontsize!), range: selectedRange!)
                }
            }
        }
        memoTextView.attributedText = selectedAttributedText
    }

    /*
     下線
     */
    @objc func underlineAction() {
        let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
        selectedAttributedText.enumerateAttribute(.underlineStyle, in: selectedRange!) { result, _, _ in
            // 既にAttributeが付与されているか
            if result != nil {
                selectedAttributedText.removeAttribute(.underlineStyle, range: selectedRange!)
            } else {
                selectedAttributedText.addAttribute(.underlineStyle, value: 1, range: selectedRange!)
            }
        }
        // textViewにAttributedStringを付与
        memoTextView.attributedText = selectedAttributedText
    }

    /*
     取り消し線
     */
    @objc func strikeThroughAction() {
        let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
        selectedAttributedText.enumerateAttribute(.strikethroughStyle, in: selectedRange!) { result, _, _ in
            // 既にAttributeが付与されているか
            if result != nil {
                selectedAttributedText.removeAttribute(.strikethroughStyle, range: selectedRange!)
            } else {
                selectedAttributedText.addAttribute(.strikethroughStyle, value: 1, range: selectedRange!)
            }
        }
        // textViewにAttributedStringを付与
        memoTextView.attributedText = selectedAttributedText
    }

}

/*

 */
extension MemoEditViewControlelr: UITextViewDelegate {
    /*
     選択した文字列の範囲、フォントサイズを取得
     */
    func textViewDidChangeSelection(_ textView: UITextView) {
        /*
         始点、長さ
         */
        let location = textView.selectedRange.location
        let length = textView.selectedRange.length
        /*
         lengthが0未満　→　未選択
         lengthが1以上　→　1文字以上を選択
         */
        if length <= 0 {
            return
        } else {
            //            let strIndex = textView.text.startIndex
            //            guard let _ = textView.text.index(strIndex, offsetBy: location, limitedBy: textView.text.endIndex),
            //                  let _ = textView.text.index(strIndex, offsetBy: location+length-1, limitedBy: textView.text.endIndex) else {
            //                return
            //            }
            let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
            guard let fontsizeOfAttributeString = selectedAttributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else {
                return
            }
            selectedFontsize = fontsizeOfAttributeString.pointSize
            selectedRange = textView.selectedRange
        }
    }
}
