//
//  TextEntryTableViewCell.swift
//
//  Copyright 2018 Twitter, Inc.
//  Licensed under the MoPub SDK License Agreement
//  http://www.mopub.com/legal/sdk-license-agreement/
//

import UIKit

class TextEntryTableViewCell: UITableViewCell {
    // MARK: - IBOutlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    // MARK: - Properties
    fileprivate var onTextDidChange:((String?) -> Swift.Void)? = nil
    
    // MARK: - Update
    
    func refresh(title: String, text: String? = nil, textDidChange:((String?) -> Swift.Void)? = nil) {
        titleLabel.text = title
        textField.text = text
        onTextDidChange = textDidChange
    }
}

extension TextEntryTableViewCell: UITextFieldDelegate {
    // MARK: - UITextFieldDelegate
    func textFieldDidEndEditing(_ textField: UITextField) {
        onTextDidChange?(textField.text)
    }
}

extension TextEntryTableViewCell: TableViewCellRegisterable {
    // MARK: - TableViewCellRegisterable
    static private(set) var reuseId: String = "TextEntryTableViewCell"
}
