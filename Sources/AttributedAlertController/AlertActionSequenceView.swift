//
//  AlertActionSequenceView.swift
//
//  Portions of this file were created by Anton Poltoratskyi on 08.05.2021 as part of the NativeUI package.
//  Those portions are Copyright © 2021 Anton Poltoratskyi. All rights reserved.
//
//  Enhancements made by Mario Hendricks 14 May 2022. Those portions are Copyright 2022 by Mario Hendricks

import UIKit

protocol AlertActionSequenceViewDelegate: AnyObject {
    func alertActionSequenceView(_ actionView: AlertActionSequenceView, tappedAtIndex index: Int)
}

/// A class that displays the view of actions (buttons) available in the alert.
class AlertActionSequenceView: UIControl {

    enum Layout {
        static let labelPadding: CGFloat = 10
        static let buttonHeight: CGFloat = 44
    }
    
    enum Constants {
        static let maxHorizontalButtons: Int = 2
    }
    
    weak var delegate: AlertActionSequenceViewDelegate?
    
    private final class ActionView: UIView {
        
        var isHighlighted: Bool = false {
            didSet {
                backgroundColor = isHighlighted ? UIColor.lightGray.withAlphaComponent(0.2) : .clear
            }
        }
        
        override var intrinsicContentSize: CGSize {
            return CGSize(
                width: UIView.noIntrinsicMetric,
                height: Layout.buttonHeight
            )
        }
        
        var isEnabled: Bool = true
        
        private(set) lazy var titleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            addSubview(label)
            return label
        }()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            initialize()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            initialize()
        }
        
        convenience init(action: AttributedAlertAction, disabledTintColor: UIColor?) {
            self.init()
            initialize()
            
            self.isEnabled = action.isEnabled
            self.titleLabel.text = action.title
            
            let disabledTintColor = disabledTintColor ?? UIColor(white: 0.48, alpha: 0.8)
            
            // Set the font weight. All fonts are regular weight, except for the preferred action, which is semibold.
            let fontWeight: UIFont.Weight = action.isPreferredAction ? .semibold : .regular
            self.titleLabel.font = UIFont.systemFont(ofSize: 17, weight: fontWeight)
            
            // Set the font color. Destructive buttons are red, others are the standard tint color, unless the button is disabled.
            if action.style == .destructive {
                self.titleLabel.textColor = UIColor.red
            }
            else {
                self.titleLabel.textColor = action.isEnabled ? tintColor : disabledTintColor
            }
        }
        
        private func initialize() {
            NSLayoutConstraint.activate([
                titleLabel.topAnchor.constraint(equalTo: topAnchor),
                titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
                titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
                titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: Layout.labelPadding)
            ])
            translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        return stackView
    }()
    
    private var highlightedView: UIView?
    
    private var buttonLayout = NSLayoutConstraint.Axis.horizontal
    
    /// The maximum width of a label when two buttons are placed next to each other horizontally
    private lazy var maxHorizontalButtonWidth: CGFloat = {
        let maxButtonWidth = AttributedAlertController.Layout.width / 2
        let maxLabelWidth  = maxButtonWidth - Layout.labelPadding - Layout.labelPadding
        return maxLabelWidth
    }()
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    // MARK: - Base Setup
    
    private func initialize() {
        // At this point we don't know the axis orientation, so we set it later
        stackView.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        setContentHuggingPriority(.required, for: .vertical)
        setContentCompressionResistancePriority(.required, for: .vertical)
    }
    
    
    
    func setup(actions: [AttributedAlertAction]) {
        
        // Figures out the button layout (horizontal or vertical) and sets the buttonLayout property.
        // We use this when making the separators and configuring the stack view
        self.determineButtonArrangement(actions)
        
        let orderedActions = self.orderActions(actions)
        
        if let alertAction = orderedActions.first {
            let actionView = ActionView(action: alertAction, disabledTintColor: nil)
            stackView.addArrangedSubview(actionView)
        }
        
        for alertAction in orderedActions.dropFirst() {
            let separator = SeparatorView(buttonOrientation: self.buttonLayout)
            stackView.addArrangedSubview(separator)
            
            let actionView = ActionView(action: alertAction, disabledTintColor: nil)
            stackView.addArrangedSubview(actionView)
            
            // Set the width of the new action to be equal to the width of the first action
            if let firstActionView = stackView.arrangedSubviews.first {
                actionView.widthAnchor.constraint(equalTo: firstActionView.widthAnchor).isActive = true
            }
        }
    }
    
    /// Determines if the action buttons will be place horizontally or vertically.
    /// - Parameter actions: The array of actions to be displayed
    private func determineButtonArrangement(_ actions: [AttributedAlertAction]) {
        
        if actions.count > Constants.maxHorizontalButtons {
            self.buttonLayout = .vertical
        }
        else {
            for alertAction in actions {
                let actionView = ActionView(action: alertAction, disabledTintColor: nil)
                let labelWidth = actionView.titleLabel.intrinsicContentSize.width
                
                if labelWidth > self.maxHorizontalButtonWidth {
                    self.buttonLayout = .vertical
                    break
                }
            }
        }
        stackView.axis = self.buttonLayout
    }
    
    
    /// Orders the actions so that any cancel action is first, since that is what the UIAlertController does
    /// - Parameter actions: The array of all actions provided
    /// - Returns: An array of action in the order that they should be presented
    private func orderActions(_ actions: [AttributedAlertAction]) -> [AttributedAlertAction]
    {
        var orderedActions    = [AttributedAlertAction]()
        var cancelActionCount = 0
        
        for action in actions {
            if isInitialGroup(style: action.style) {
                orderedActions.append(action)
                cancelActionCount += 1
            }
        }
        
        for action in actions {
            if !isInitialGroup(style: action.style) {
                orderedActions.append(action)
            }
        }
        
        return orderedActions
    }
    
    private func isInitialGroup(style: UIAlertAction.Style) -> Bool
    {
        var initialGroup = false
        
        if self.buttonLayout == .horizontal {
            initialGroup = style == .cancel
        }
        else {
            initialGroup = style != .cancel
        }
        
        return initialGroup
    }
    
    // MARK: - Touch Handling
    
    // MARK: UIControl Events
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.beginTracking(touch, with: event)
        highlightView(for: touch, withHapticFeedback: false)
        return result
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let result = super.continueTracking(touch, with: event)
        highlightView(for: touch, withHapticFeedback: true)
        return result
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        super.endTracking(touch, with: event)
        
        resetHighlight()
        if let selectedView = selectedView(for: touch) {
            handleTap(on: selectedView)
        }
    }
    
    override func cancelTracking(with event: UIEvent?) {
        super.cancelTracking(with: event)
        resetHighlight()
    }
    
    // MARK: Selection
    
    private func highlightView(for touch: UITouch, withHapticFeedback: Bool) {
        let point = touch.location(in: self)
        
        for case let actionView as ActionView in stackView.arrangedSubviews {
            guard let actionViewFrame = actionView.superview?.convert(actionView.frame, to: self) else {
                continue
            }
            let isHighlighted = actionViewFrame.contains(point) && actionView.isEnabled
            actionView.isHighlighted = isHighlighted
            
            if isHighlighted, highlightedView != actionView {
                highlightedView = actionView
            }
        }
    }
    
    private func resetHighlight() {
        for case let actionView as ActionView in stackView.arrangedSubviews {
            actionView.isHighlighted = false
        }
        highlightedView = nil
    }
    
    private func selectedView(for touch: UITouch?) -> ActionView? {
        guard let point = touch?.location(in: self) else {
            return nil
        }
        for case let actionView as ActionView in stackView.arrangedSubviews {
            guard let actionViewFrame = actionView.superview?.convert(actionView.frame, to: self) else {
                continue
            }
            if actionViewFrame.contains(point) {
                return actionView
            }
        }
        return nil
    }
    
    @objc private func handleTap(on actionView: ActionView) {
        let index = stackView.arrangedSubviews
            .compactMap { $0 as? ActionView }
            .filter { $0.isEnabled }
            .firstIndex(where: { $0 === actionView })
        
        if let index = index {
            delegate?.alertActionSequenceView(self, tappedAtIndex: index)
        }
    }
}
