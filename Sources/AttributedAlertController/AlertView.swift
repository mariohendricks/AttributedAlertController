//
//  AlertView.swift
//
//  Portions of this file were created by Anton Poltoratskyi on 08.05.2021 as part of the NativeUI package.
//  Those portions are Copyright © 2021 Anton Poltoratskyi. All rights reserved.
//
//  Enhancements made by Mario Hendricks 14 May 2022. Those portions are Copyright 2022 by Mario Hendricks

import UIKit

protocol AlertViewDelegate: AnyObject {
    func alertView(_ alertView: AlertView, buttonTappedAtIndex index: Int)
}

/// A class that displays the overall view for the alert.
class AlertView: UIView, AlertActionSequenceViewDelegate {

    private enum Layout {
        
        enum Content {
            static let top: CGFloat = 20
            static let bottom: CGFloat = 24
            static let horizontal: CGFloat = 15
            static let verticalSpacing: CGFloat = 4
        }
        
        enum TextFields {
            static let top: CGFloat = 24
            static let bottom: CGFloat = 12
        }
    }
    
    weak var delegate: AlertViewDelegate?
    
    private lazy var blurView: UIVisualEffectView = {
        let blurStyle: UIBlurEffect.Style
        if #available(iOS 13, *) {
            blurStyle = .systemMaterial
        } else {
            blurStyle = .extraLight
        }
        let blurEffect = UIBlurEffect(style: blurStyle)
        
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(effectView)
        
        return effectView
    }()

    // MARK: - Content of the Alert View
    
    private lazy var contentContainerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(containerView)
        return containerView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(stackView)
        return stackView
    }()
    
    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.addSubview(stackView)
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var contentSeparatorView: UIView = {
        let separatorView = SeparatorView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.axis = .horizontal
        return separatorView
    }()
    
    private lazy var actionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        blurView.contentView.addSubview(stackView)
        return stackView
    }()
    
    private lazy var actionSequenceView: AlertActionSequenceView = {
        let sequenceView = AlertActionSequenceView()
        sequenceView.translatesAutoresizingMaskIntoConstraints = false
        return sequenceView
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
        setupLayout()
        setupAppearance()
    }
    
    private func setupLayout() {
        contentStackView.axis = .vertical
        contentStackView.spacing = Layout.Content.verticalSpacing
        contentStackView.addArrangedSubview(titleLabel)
        contentStackView.addArrangedSubview(messageLabel)
        
        textFieldStackView.axis = .vertical
        textFieldStackView.spacing = Layout.Content.verticalSpacing
        
        actionsStackView.axis = .vertical
        actionsStackView.spacing = 0
        actionsStackView.addArrangedSubview(contentSeparatorView)
        actionsStackView.addArrangedSubview(actionSequenceView)
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            contentContainerView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            contentContainerView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            
            contentStackView.topAnchor.constraint(equalTo: contentContainerView.topAnchor, constant: Layout.Content.top),
            contentStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: Layout.Content.horizontal),
            contentStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -Layout.Content.horizontal),
            
            actionsStackView.topAnchor.constraint(equalTo: contentContainerView.bottomAnchor),
            actionsStackView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            actionsStackView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            actionsStackView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor)
        ])
        
        [titleLabel, messageLabel].forEach {
            $0.setContentHuggingPriority(.required, for: .vertical)
            $0.setContentCompressionResistancePriority(.required, for: .vertical)
        }
        
        actionSequenceView.delegate = self
    }
    
    private func setupAppearance() {
        backgroundColor = .clear
        layer.cornerRadius = 12
        layer.masksToBounds = true
        
        titleLabel.textAlignment = .center
        messageLabel.textAlignment = .center
    }
    
    private func setupTextFields(fields: [UITextField]?)
    {
        if let textFields = fields, textFields.count > 0 {
            for field in textFields {
                field.translatesAutoresizingMaskIntoConstraints = false
                
                let textContainer = UIView()
                textContainer.addSubview(field)
                textContainer.isUserInteractionEnabled = true
                textContainer.backgroundColor = .white              // Probably not quite correct
                textContainer.layer.masksToBounds = true
                textContainer.layer.borderWidth = 0.25
                textContainer.layer.borderColor = AttributedAlertController.borderColorForCurrentUIStyle().cgColor
                textContainer.layer.cornerRadius = 7.0
                
                if #available(iOS 13, *) {
                    // The OS uses systemBackground for the label color
                    textContainer.backgroundColor = .systemBackground
                }
                
                NSLayoutConstraint.activate([
                    textContainer.heightAnchor.constraint(equalToConstant: 30.67),
                    field.centerYAnchor.constraint(equalTo: textContainer.centerYAnchor),
                    field.trailingAnchor.constraint(equalTo: textContainer.trailingAnchor, constant: -7.0),
                    field.leadingAnchor.constraint(equalTo: textContainer.leadingAnchor, constant: 7.0),
                ])
                
                textFieldStackView.addArrangedSubview(textContainer)
            }
            NSLayoutConstraint.activate([
                textFieldStackView.topAnchor.constraint(equalTo: messageLabel.lastBaselineAnchor, constant: Layout.TextFields.top),
                textFieldStackView.leadingAnchor.constraint(equalTo: contentContainerView.leadingAnchor, constant: Layout.Content.horizontal),
                textFieldStackView.trailingAnchor.constraint(equalTo: contentContainerView.trailingAnchor, constant: -Layout.Content.horizontal),
                textFieldStackView.bottomAnchor.constraint(equalTo: contentContainerView.bottomAnchor, constant: -Layout.TextFields.bottom)])
        }
        else {
            NSLayoutConstraint.activate([
                contentContainerView.bottomAnchor.constraint(equalTo: messageLabel.lastBaselineAnchor, constant: Layout.Content.bottom)
            ])
            textFieldStackView.isHidden = true
        }
    }
    
    
    internal func loadModel(title: NSAttributedString?, message: NSAttributedString?,
                            textFields: [UITextField]?, actions: [AttributedAlertAction])
    {
        self.titleLabel.attributedText = title
        self.messageLabel.attributedText = message
        
        self.setupTextFields(fields: textFields)
        
        self.actionSequenceView.setup(actions: actions)
    }
    
    // MARK: - AlertActionSequenceViewDelegate
    
    func alertActionSequenceView(_ actionView: AlertActionSequenceView, tappedAtIndex index: Int) {
        delegate?.alertView(self, buttonTappedAtIndex: index)
    }
}
