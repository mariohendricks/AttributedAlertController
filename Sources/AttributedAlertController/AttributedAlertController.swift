//
//  AttributedAlertController.swift
//
//  Portions of this file were created by Anton Poltoratskyi on 08.05.2021 as part of the NativeUI package.
//  Those portions are Copyright © 2021 Anton Poltoratskyi. All rights reserved.
//
//  Enhancements made by Mario Hendricks 14 May 2022. Those portions are Copyright 2022 by Mario Hendricks

import UIKit

/// A class to create a view controller that displays a modal (pop-up) alert to the user, with the specified title, message, buttons and optional text input fields.
public class AttributedAlertController: UIViewController, UIViewControllerTransitioningDelegate, AlertViewDelegate {
    
    internal enum Layout {
        static let verticalInset: CGFloat = 44
        static let width: CGFloat = 270
    }
    internal enum FontSize {
        static let forTitle: CGFloat = 17
        static let forMessage: CGFloat = 13
        static let forTextBox: CGFloat = 13
    }

    // MARK: Public Properties
    
    /// The title of the alert with formatting attributes applied
    public var attributedTitle: NSAttributedString?
    /// Descriptive text that provides more details about the reason for the alert, with formatting attributes applied.
    public var attributedMessage: NSAttributedString?
    /// The style of the alert controller. Only .alert style is supported.
    public private(set) var preferredStyle: UIAlertController.Style
    /// The actions that the user can take in response to the alert or action sheet.
    public private(set) var actions = [AttributedAlertAction]()
    /// The array of text fields displayed by the alert.
    public private(set) var textFields: [UITextField]?
    /// The preferred action for the user to take from an alert.
    public var preferredAction: UIAlertAction? {
        didSet {
            // When the preferred action is set, clear any previous preferred actions.
            for action in self.actions {
                action.isPreferredAction = false
            }
            // If the preferredAction wasn't set to nil, find the action with the matching title
            if let newPreferredActionTitle = preferredAction?.title {
                for action in actions {
                    if action.title == newPreferredActionTitle {
                        action.isPreferredAction = true
                        break
                    }
                }
            }
            // If the preferredAction was set to nil, set any cancel action and make that the preferred action
            else {
                for action in actions {
                    if action.style == .cancel {
                        action.isPreferredAction = true
                        break
                    }
                }
            }
        }
    }
    
    /// The default color of the alert title and message
    public private(set) static var labelColor: UIColor = {
        var labelColor = UIColor.black
        if #available(iOS 13.0, *) {
            labelColor = .label
        }
        return labelColor
    }()
    
    /// The default font of the alert message
    public private(set) static var messageFont = UIFont.systemFont(ofSize: FontSize.forMessage, weight: .regular)
    
    /// The default font of the alert title
    public private(set) static var titleFont   = UIFont.systemFont(ofSize: FontSize.forTitle, weight: .semibold)
    
    /// Descriptive text that provides more details about the reason for the alert.
    public var message: String? {
        get {
            self.attributedMessage?.string
        }
    }
    
    // MARK: - Private Properties
    
    private var yPosition: NSLayoutConstraint?
    
    private lazy var backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(backgroundView)
        return backgroundView
    }()
    
    private(set) lazy var alertView: AlertView = {
        let alertView = AlertView()
        alertView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(alertView)
        return alertView
    }()
    
    // MARK: - Initialization
    
    /// Creates and returns a view controller for displaying an alert to the user
    /// - Parameters:
    ///   - title: The title of the alert. Use this string to get the user's attention and communicate the reason for the alert.
    ///   - message: Descriptive text that provides additional details about the reason for the alert.
    ///   - preferredStyle: The style to use when presenting the alert controller. Only a modal alert (Style.alert) is supported, which is the default.
    public init(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert) {
        self.preferredStyle = preferredStyle
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
        
        self.setTitleWithStandardAttributes(title: title)
        
        if let messageText = message {
            self.attributedMessage = AttributedAlertController.AttributedMessageWithDefaultStyle(text: messageText)
        }
        
        self.configure()
    }
    
    /// Creates and returns a view controller for displaying an alert to the user
    /// - Parameters:
    ///   - title: The attributed title of the alert. Use this string to get the user's attention and communicate the reason for the alert.
    ///   - message: Descriptive text with formatting attributes that provides additional details about the reason for the alert.
    ///   - preferredStyle: The style to use when presenting the alert controller. Only a modal alert (Style.alert) is supported, which is the default
    public init(title: NSAttributedString?, message: NSAttributedString?, preferredStyle: UIAlertController.Style = .alert) {
        self.preferredStyle = preferredStyle
        super.init(nibName: nil, bundle: nil)
        
        self.attributedTitle   = title
        self.attributedMessage = message
        
        self.configure()
    }
    
    /// Creates and returns a view controller for displaying an alert to the user
    /// - Parameters:
    ///   - title: The title of the alert. Use this string to get the user's attention and communicate the reason for the alert.
    ///   - message: Descriptive text with formatting attributes that provides additional details about the reason for the alert.
    ///   - preferredStyle: The style to use when presenting the alert controller. Only a modal alert (Style.alert) is supported, which is the default
    public init(title: String?, message: NSAttributedString?, preferredStyle: UIAlertController.Style = .alert) {
        self.preferredStyle = preferredStyle
        super.init(nibName: nil, bundle: nil)
        
        self.title = title
        self.setTitleWithStandardAttributes(title: title)
        self.attributedMessage = message
        
        self.configure()
    }
    
    required public init?(coder: NSCoder) {
        self.preferredStyle = .alert
        
        super.init(coder: coder)
        self.configure()
    }
    
    private func configure()
    {
        modalPresentationStyle = .custom        // .overCurrentContext also seems to work
        transitioningDelegate = self
    }
    
    // MARK: - Public Functions
    
    /// Creates and returns a mutable, attributed string containing the supplied text with the standard alert formatting (font and color)
    /// - Parameter text: The initial message text. This may be modified or appended to later.
    /// - Returns: An NSMutableAttributed String containing the supplied text and the standard alert formatting
    public static func AttributedMessageWithDefaultStyle(text: String) -> NSMutableAttributedString
    {
        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                NSAttributedString.Key.font : AttributedAlertController.messageFont,
                NSAttributedString.Key.foregroundColor : AttributedAlertController.labelColor
            ]
        )
        return attributedString
    }
    
    /// Attaches an action object to the alert.
    /// - Parameter action: The action object to display as part of the alert. Actions are displayed as buttons in the alert. The action object provides the button text and the action to be performed when that button is tapped.
    /// - Remark: If your alert has multiple actions, the order in which you add those actions determines their order in the resulting alert or action sheet, except that the cancel
    /// action is first when two actions are displayed horizontally or at the bottom when displayed vertically.
    public func addAction(_ action: AttributedAlertAction) {
        
        if action.style == .cancel && self.preferredAction == nil {
            action.isPreferredAction = true
        }
        action.uniqueId = self.actions.count
        self.actions.append(action)
    }
    
    /// Adds a text field to an alert
    /// - Parameter configurationHandler: A block for configuring the text field prior to displaying the alert. This block has no return value and takes a single parameter corresponding to the text field object. Use that parameter to change the text field properties.
    public func addTextField(configurationHandler: ((UITextField) -> Void)? = nil) {
        
        // For compatibility reasons, we don't create the array until the first text field is added
        if self.textFields == nil {
            self.textFields = [UITextField]()
        }
        // Create and configure the new text field. We configure here so that the configuration handler can change, if needed
        let newTextField = UITextField()
        newTextField.font = UIFont.systemFont(ofSize: FontSize.forTextBox, weight: .regular)
        newTextField.autocorrectionType = .no
        newTextField.backgroundColor = .clear
        
        self.textFields!.append(newTextField)
        
        // If a handler was specified, call it with the new text field
        if let handler = configurationHandler {
            handler(newTextField)
        }
    }
    
    /// Sets the receiver's property specified by a given key to a given value.
    /// - Parameters:
    ///   - value: The value for the property identified by key.
    ///   - key: The name of one of the receiver's properties.
    /// - Remark: Keys of "attributedMessage" and "attributedTitle" may be used to set the relevant properties for the alert.
    public override func setValue(_ value: Any?, forKey key: String) {
        if key == "attributedMessage", let newMessage = value as! NSAttributedString? {
            self.attributedMessage = newMessage
        }
        else if key == "attributedTitle", let newTitle = value as! NSAttributedString? {
            self.attributedTitle = newTitle
        }
        
        super.setValue(value, forKey: key)
    }
    
    // MARK: - View Controller Lifecycle Functions
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAppearance()
        self.setupLayout()
        self.setupViewModel()
        
        let keyboardWillShow      = #selector(self.keyboardWillShow(sender:))
        let keyboardWillShowEvent = UIResponder.keyboardWillShowNotification
        NotificationCenter.default.addObserver(self, selector: keyboardWillShow, name: keyboardWillShowEvent, object: nil)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let fields = self.textFields, fields.count > 0 {
            fields[0].becomeFirstResponder()
        }
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    /// Observer function that is called when the keyboard is about to show.
    /// - Parameter sender: The notification that triggered the function to be called.
    /// - Remark: In some cases, the safe area is not adjusted when the keyboard shows. If that is the case, we adjust the position of the alert upwards by half of the
    ///           height of the keyboard so that it is centered in the remaining area.
    @objc func keyboardWillShow(sender: NSNotification) {
        let screenHeight = UIScreen.main.bounds.height
        let safeAreaHeight = view.safeAreaLayoutGuide.layoutFrame.height
        let unsafeHeight   = screenHeight - safeAreaHeight
        
        let keyboardFrameKey = UIResponder.keyboardFrameEndUserInfoKey
        if let userInfo = sender.userInfo, let frameValue = userInfo[keyboardFrameKey] as? NSValue {
            let keyboardHeight = frameValue.cgRectValue.height
            
            if unsafeHeight < keyboardHeight, let verticalPositionConstraint = yPosition {
                verticalPositionConstraint.constant = -(keyboardHeight/2)
            }
        }
    }
    
    // MARK: - Private Functions
    
    private func setupAppearance() {
        self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
    }
    
    private func setupLayout() {
        let safeAreaLayoutGuide = view.safeAreaLayoutGuide
        
        yPosition = alertView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            alertView.widthAnchor.constraint(equalToConstant: Layout.width),
            alertView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            yPosition!,
            alertView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor, constant: Layout.verticalInset)
        ])
    }
    
    /// Sets the attributed title using the "standard" formatting for titles in an alert.
    /// - Parameter title: The title of the alert.
    private func setTitleWithStandardAttributes(title: String?) {
        
        if let titleText = title {
            self.attributedTitle = NSAttributedString(
                string: titleText,
                attributes: [
                    NSAttributedString.Key.font : AttributedAlertController.titleFont,
                    NSAttributedString.Key.foregroundColor : AttributedAlertController.labelColor
                ]
            )
        }
    }
    
    private func setupViewModel() {
        self.alertView.delegate = self
        self.alertView.loadModel(title: attributedTitle, message: attributedMessage, textFields: textFields, actions: actions)
    }
    
    internal static func borderColorForCurrentUIStyle() -> UIColor
    {
        var color = UIColor.lightGray
        let lightThemeColor = UIColor.lightGray
        let darkThemeColor = UIColor.darkGray
        
        if #available(iOS 13.0, *) {
            color = UIColor { traitCollection in
                switch traitCollection.userInterfaceStyle {
                case .light, .unspecified:
                    return lightThemeColor
                case .dark:
                    return darkThemeColor
                @unknown default:
                    return lightThemeColor
                }
            }
        }
        
        return color
    }

    // MARK: - UIViewControllerTransitioningDelegate
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertPresentationAnimator()
    }

    public func animationController(forPresented presented: UIViewController,
                                    presenting: UIViewController,
                                    source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AlertPresentationAnimator()
    }
    
    // MARK: - AlertViewDelegate
    
    func alertView(_ alertView: AlertView, buttonUniqueId: Int) {
        // In theory, the buttonUniqueId is the index into the actions array, but this is safer, in case the implementation
        // changes later on. 
        for action in actions {
            if action.uniqueId == buttonUniqueId, let handler = action.handler {
                dismiss(animated: true) {
                    handler(action)
                }
                break
            }
        }
    }

}
