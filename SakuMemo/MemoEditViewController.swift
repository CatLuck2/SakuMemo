//
//  MemoEditViewController.swift
//  SakuMemo
//
//  Created by Nekokichi on 2022/01/19.
//

import UIKit

class MemoEditViewControlelr: UIViewController {
    
    @IBOutlet weak var memoTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtonsInKeyboard()
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
