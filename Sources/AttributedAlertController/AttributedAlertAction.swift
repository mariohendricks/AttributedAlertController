//
//  AttributedAlertAction.swift
//
//  This file was created by Mario Hendricks 14 May 2022. It is Copyright 2022 by Mario Hendricks.

import UIKit


/// An action that can be taken when the user taps a button in an attributed alert.
public class AttributedAlertAction: UIAlertAction {

    /// The handler to be called when the action is selected, if any. 
    public private(set) var handler: ((UIAlertAction) -> Void)?
    
    private var internalTitle: String?
    private var myStyle: UIAlertAction.Style
    
    internal var isPreferredAction = false
    internal var uniqueId = -1
    
    /// The title of the action's button
    public override var title: String?
    {
        get {
            return internalTitle
        }
    }
    
    /// The style that is applied to the action's button
    public override var style: UIAlertAction.Style {
        get {
            return myStyle
        }
    }
    
    /// Create and return an action with the specified title and behavior.
    /// - Parameters:
    ///   - title: The text to use for the button title. The value you specify should be localized for the user’s current language. This parameter must not be nil.
    ///   - style: Additional styling information to apply to the button.
    ///   - handler: A block to execute when the user selects the action. This block has no return value and takes the selected action object as its only parameter.
    public init(title: String?, style: UIAlertAction.Style, handler: ((UIAlertAction) -> Void)? = nil) {
        self.handler = handler
        self.myStyle = style
        self.internalTitle = title
        
        super.init()
        self.isEnabled = true
    }
}
