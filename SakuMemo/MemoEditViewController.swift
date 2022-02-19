//
//  MemoEditViewController.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/19.
//

import UIKit
import RealmSwift
import WidgetKit

final class MemoEditViewController: UIViewController {

    @IBOutlet weak private var memoTextView: UITextView!
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
        guard let selectedMemoModel = selectedMemoModel else {
            return
        }
        do {
            // HTML -> AttributedString
            let encoded = selectedMemoModel.attributes.data(using: String.Encoding.utf8)!
            let attributedOptions: [NSMutableAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSMutableAttributedString.DocumentType.html]
            let attributedTxt = try NSMutableAttributedString(data: encoded, options: attributedOptions, documentAttributes: nil)
            attributedTxt.enumerateAttribute(.font, in: NSRange(location: 0, length: attributedTxt.length)) { result, range, _ in
                if let attrFont = result as? UIFont {
                    let traits: UIFontDescriptor.SymbolicTraits = attrFont.fontDescriptor.symbolicTraits
                    let newDescriptor = attrFont.fontDescriptor.withFamily("Hiragino Kaku Gothic Interface")

                    let hiraginoFont = UIFont(descriptor: newDescriptor, size: attrFont.pointSize)
                    attributedTxt.addAttribute(.font, value: hiraginoFont, range: range)

                    if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitBold.rawValue) != 0 {
                        let boldFont = hiraginoFont.stm.bold().build()
                        attributedTxt.addAttribute(.font, value: boldFont, range: range)
                    }

                    if (traits.rawValue & UIFontDescriptor.SymbolicTraits.traitItalic.rawValue) != 0 {
                        let italicFont = hiraginoFont.stm.italic().build()
                        attributedTxt.addAttribute(.font, value: italicFont, range: range)
                    }
                }
            }
            memoTextView.attributedText = attributedTxt
        } catch let error as NSError {
            print(error)
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
                let data = try NSKeyedArchiver.archivedData(withRootObject: NSMutableAttributedString(attributedString: memoTextView.attributedText), requiringSecureCoding: false)
                let documentAttributes: [NSMutableAttributedString.DocumentAttributeKey: Any]!
                documentAttributes = [.documentType: NSMutableAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
                let htmlData = try memoTextView.attributedText.data(from: NSRange(location: 0, length: memoTextView.attributedText.length),
                                                                    documentAttributes: documentAttributes)
                try MemoModel.realm!.write {
                    selectedMemoModel!.sentence = data
                    selectedMemoModel!.attributes = String(data: htmlData, encoding: .utf8) ?? ""
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
                // AttributeString -> HTML
                let documentAttributes: [NSMutableAttributedString.DocumentAttributeKey: Any]!
                documentAttributes = [.documentType: NSMutableAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
                let htmlData = try memoTextView.attributedText.data(from: NSRange(location: 0, length: memoTextView.attributedText.length),
                                                                    documentAttributes: documentAttributes)
                newMemoModel.sentence = data
                newMemoModel.attributes = String(data: htmlData, encoding: .utf8) ?? ""
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
    private func setButtonsInKeyboard() {
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
    @objc private func boldAction() {
        let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
        /*
         ①選択した文字列のフォント情報を読み取る
         ②Regularなら太字、それ以外ならsystemFont、に装飾
         理由：太字かを判定するには、標準フォントであるRegularで判断するしかないから
         */
        selectedAttributedText.enumerateAttribute(.font, in: selectedRange!) { result, _, _ in
            if let result = result as? UIFont {
                selectedAttributedText.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: selectedFontsize!), range: selectedRange!)
            }
        }
        memoTextView.attributedText = selectedAttributedText
    }

    /*
     斜体
     */
    @objc private func italicAction() {
        let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
        selectedAttributedText.enumerateAttribute(.font, in: selectedRange!) { result, _, _ in
            if let result = result as? UIFont {
                selectedAttributedText.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: selectedFontsize!), range: selectedRange!)
            }
        }
        memoTextView.attributedText = selectedAttributedText
    }

    /*
     下線
     */
    @objc private func underlineAction() {
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
    @objc private func strikeThroughAction() {
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

extension MemoEditViewController {
    enum Identifier: String {
        case segueFromList = "segueToMemoEditViewController"
    }
}

extension MemoEditViewController: UITextViewDelegate {
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
            let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
            guard let fontsizeOfAttributeString = selectedAttributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else {
                return
            }
            selectedFontsize = fontsizeOfAttributeString.pointSize
            selectedRange = textView.selectedRange
        }
    }
}
