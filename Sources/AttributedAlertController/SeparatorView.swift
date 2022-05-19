//
//  SeparatorView.swift
//  AttributedAlertController
//
//  Portions of this file were created by Anton Poltoratskyi on 08.05.2021 as part of the NativeUI package.
//  Those portions are Copyright © 2021 Anton Poltoratskyi. All rights reserved.
//
//  Enhancements made by Mario Hendricks 14 May 2022. Those portions are Copyright 2022 by Mario Hendricks

import UIKit


/// A class that draws separators between buttons in the alert
final class SeparatorView: UIView {
    
    /// The direction of the separator
    var axis: NSLayoutConstraint.Axis = .horizontal {
        didSet {
            updateAxis()
        }
    }
    
    // MARK: - Subviews
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        // UIAttributedAlert.borderColorForCurrentUIStyle()
        let lightThemeColor = UIColor.lightGray
        let darkThemeColor = UIColor.darkGray
        
        if #available(iOS 13.0, *) {
            contentView.backgroundColor = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    return lightThemeColor
                case .dark:
                    return darkThemeColor
                @unknown default:
                    return lightThemeColor
                }
            }
        } else {
            contentView.backgroundColor = lightThemeColor
        }
        
        addSubview(contentView)
        
        return contentView
    }()
    
    private lazy var heightConstraint = heightAnchor.constraint(equalToConstant: separatorThickness(for: traitCollection))
    private lazy var widthConstraint = widthAnchor.constraint(equalToConstant: separatorThickness(for: traitCollection))
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    /// Creates a separator view in the specified orientation
    /// - Parameter orientation: The orientation of the separator view (vertical or horizontal)
    convenience init(orientation: NSLayoutConstraint.Axis) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = false
        self.axis = orientation
        self.updateAxis()
    }
    
    /// Creates a separator view between two buttons that are arranged in the specified orientation
    /// - Parameter buttonOrientation: The orientation of the buttons (vertical or horizontal)
    convenience init(buttonOrientation: NSLayoutConstraint.Axis) {
        self.init()
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if buttonOrientation == .horizontal {
            self.axis = .vertical
        }
        else {
            self.axis = .horizontal
        }
        self.updateAxis()
    }
    
    // MARK: - Base Setup
    
    private func initialize() {
        setContentHuggingPriority(.required, for: .vertical)
        setContentHuggingPriority(.required, for: .horizontal)
        setContentCompressionResistancePriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        updateAxis()
    }
    
    private func updateAxis() {
        switch axis {
        case .horizontal:
            widthConstraint.isActive = false
            heightConstraint.isActive = true
        case .vertical:
            widthConstraint.isActive = true
            heightConstraint.isActive = false
        @unknown default:
            widthConstraint.isActive = true
            heightConstraint.isActive = false
        }
    }
    
    private func separatorThickness(for traitCollection: UITraitCollection?) -> CGFloat {
        return 1.0 / max(1, traitCollection?.displayScale ?? 1)
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        heightConstraint.constant = separatorThickness(for: traitCollection)
        widthConstraint.constant = separatorThickness(for: traitCollection)
    }
}
