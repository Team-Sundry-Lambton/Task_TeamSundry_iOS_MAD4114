//
//  DatePicker.swift
//  Task_TeamSundry_iOS_MAD4114
//
//  Created by Alice’z Poy on 2023-01-22.
//

import UIKit

class DatePicker: UIView {
    
    var changeClosure: ((Date)->())?
    var dismissClosure: ((Date)->())?
    
    let dPicker: UIDatePicker = {
        let v = UIDatePicker()
        v.locale = Locale(identifier: "en_US_POSIX")
        v.tintColor = .darkPurple
        v.minimumDate = Date.now
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    func commonInit() -> Void {
        let blurEffect = UIBlurEffect(style: .dark)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        
        let pickerHolderView: UIView = {
            let v = UIView()
            v.layer.cornerRadius = 8
            return v
        }()
        
        [blurredEffectView, pickerHolderView, dPicker].forEach { v in
            v.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addSubview(blurredEffectView)
        pickerHolderView.addSubview(dPicker)
        addSubview(pickerHolderView)
        
        NSLayoutConstraint.activate([
            
            blurredEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurredEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurredEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurredEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            pickerHolderView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20.0),
            pickerHolderView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20.0),
            pickerHolderView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            dPicker.topAnchor.constraint(equalTo: pickerHolderView.topAnchor, constant: 20.0),
            dPicker.leadingAnchor.constraint(equalTo: pickerHolderView.leadingAnchor, constant: 20.0),
            dPicker.trailingAnchor.constraint(equalTo: pickerHolderView.trailingAnchor, constant: -20.0),
            dPicker.bottomAnchor.constraint(equalTo: pickerHolderView.bottomAnchor, constant: -20.0),
            
        ])
        
        if #available(iOS 14.0, *) {
            dPicker.preferredDatePickerStyle = .inline
        } else {
            // use default
        }
        
        dPicker.addTarget(self, action: #selector(didChangeDate(_:)), for: .valueChanged)
        
        let t = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
        blurredEffectView.addGestureRecognizer(t)
    }
    
    @objc func tapHandler(_ g: UITapGestureRecognizer) -> Void {
        dismissClosure?(dPicker.date)
    }
    
    @objc func didChangeDate(_ sender: UIDatePicker) -> Void {
        changeClosure?(sender.date)
    }
    
    static func getStringCurrentDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM yyyy 'at' h:mm a"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.string(from: Date())
    }
    
    static func getStringFromDate(date: Date) -> String {
        if Calendar.current.isDate(date, equalTo: Date(), toGranularity: .day) {
            return "Today"
        } else {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM yyyy 'at' h:mm a"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            return dateFormatter.string(from: date)
        }
    }
}
