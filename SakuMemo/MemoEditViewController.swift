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
    private var selectedFontsize: CGFloat? = 14.0
    private var selectedRange: NSRange? = NSRange(location: 0, length: 0)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedMemoModel != nil {
            // Data->NSMutableAttributedString
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if selectedMemoModel != nil {
            do {
                let realm = try Realm()
                try realm.write {
                    // NSMutableAttributedString->Data
                    let data = try NSKeyedArchiver.archivedData(withRootObject: NSMutableAttributedString(attributedString: memoTextView.attributedText), requiringSecureCoding: false)
                    selectedMemoModel!.sentence = data
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            do {
                let newMemoModel = MemoModel()
                // NSMutableAttributedString->Data
                let data = try NSKeyedArchiver.archivedData(withRootObject: NSMutableAttributedString(attributedString: memoTextView.attributedText), requiringSecureCoding: false)
                newMemoModel.sentence = data
                
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

    @objc func boldAction() {
        let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
        selectedAttributedText.enumerateAttribute(.font, in: selectedRange!) { result, resultRange, _ in
            if let result = result as? UIFont {
                if result.fontDescriptor.object(forKey: .face)! as? String == "Regular" {
                    selectedAttributedText.addAttribute(.font, value:UIFont.boldSystemFont(ofSize: selectedFontsize!), range: selectedRange!)
                } else {
                    selectedAttributedText.addAttribute(.font, value:UIFont.systemFont(ofSize: selectedFontsize!), range: selectedRange!)
                }
            }
        }
        memoTextView.attributedText = selectedAttributedText
    }
    
    @objc func italicAction() {
        let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
        selectedAttributedText.enumerateAttribute(.font, in: selectedRange!) { result, resultRange, _ in
            if let result = result as? UIFont {
                print(result.fontDescriptor.object(forKey: .face))
                if result.fontDescriptor.object(forKey: .face)! as? String == "Regular" {
                    selectedAttributedText.addAttribute(.font, value:UIFont.italicSystemFont(ofSize: selectedFontsize!), range: selectedRange!)
                } else {
                    selectedAttributedText.addAttribute(.font, value:UIFont.systemFont(ofSize: selectedFontsize!), range: selectedRange!)
                }
            }
        }
        memoTextView.attributedText = selectedAttributedText
    }
    
    @objc func underlineAction() {
        let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
        selectedAttributedText.enumerateAttribute(.underlineStyle, in: selectedRange!) { result, resultRange, _ in
            // 既にAttributeが付与されているか
            if let _ = result as? Int {
                selectedAttributedText.removeAttribute(.underlineStyle, range: selectedRange!)
            } else {
                selectedAttributedText.addAttribute(.underlineStyle, value:1, range: selectedRange!)
            }
        }
        // textViewにAttributedStringを付与
        memoTextView.attributedText = selectedAttributedText
    }
    
    @objc func strikeThroughAction() {
        let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
        selectedAttributedText.enumerateAttribute(.strikethroughStyle, in: selectedRange!) { result, resultRange, _ in
            // 既にAttributeが付与されているか
            if let _ = result as? Int {
                selectedAttributedText.removeAttribute(.strikethroughStyle, range: selectedRange!)
            } else {
                selectedAttributedText.addAttribute(.strikethroughStyle, value:1, range: selectedRange!)
            }
        }
        // textViewにAttributedStringを付与
        memoTextView.attributedText = selectedAttributedText
    }

}

extension MemoEditViewControlelr: UITextViewDelegate {
    func textViewDidChangeSelection(_ textView: UITextView) {
        let location = textView.selectedRange.location
        let length = textView.selectedRange.length
        if length <= 0 {
            return
        } else {
            let strIndex = textView.text.startIndex
            guard let startIndex = textView.text.index(strIndex, offsetBy: location, limitedBy: textView.text.endIndex),
                      let endIndex = textView.text.index(strIndex, offsetBy: location+length-1, limitedBy: textView.text.endIndex) else {
                return
            }
            let selectedAttributedText = NSMutableAttributedString(attributedString: memoTextView.attributedText)
            guard let fontsizeOfAttributeString = selectedAttributedText.attribute(.font, at: 0, effectiveRange: nil) as? UIFont else {
                return
            }
            selectedFontsize = fontsizeOfAttributeString.pointSize
            selectedRange = textView.selectedRange
        }
    }
}
