[![Swift](https://img.shields.io/badge/Swift-5.0-orange.svg)](https://swift.org)
[![Xcode](https://img.shields.io/badge/Xcode-13.0-blue.svg)](https://developer.apple.com/xcode)
[![MIT](https://img.shields.io/badge/License-MIT-red.svg)](https://opensource.org/licenses/MIT)

# AttributedAlertController

`AttributedAlertController` is a replacement for the native iOS `UIAlertController` that allows you to specify the formatting attributes of the title and/or message. 

## Description

`AttributedAlertController` allows you to supply attributed strings for the title and message that are displayed in an alert, without using any private APIs. This helps to keep your apps in compliance with Apple's rules.

AttributedAlertController has the same interface as the native UIAlertController, except that it requires a new `AttributedAlertAction` class if you require handlers for your actions (because the native class doesn't expose the handler). It also exposes properties that allow you to set an attributed title or message. It supports text fields, 1, 2, 3, or more buttons, and dark mode. Not that it currently does **not** support Action Sheets. 

[![Sample Alert](https://user-images.githubusercontent.com/64079949/169821186-9c3369b2-e944-49fc-b73e-e2efe549711e.png)]

## Minimum Requirements:
- iOS 12.0
- Xcode 13.0
- Swift 5

## Installing

Install using the Swift Package manager. 

These instructions were developed using Xcode 13.3. Other versions of Xcode may be slightly different. 

* With your project open, select **File**, **Add Packages...**
* Type or paste the repository URL (https://github.com/mariohendricks/AttributedAlertController) in the upper right-hand corner of the window. 
* Click on the **Add Package** button. 
* When the **Choose Package Products** window is displayed, click the **Add Package** button again. 
* That will add the package to your project. Follow the steps under **Usage** to use it. 

## Usage

* Import the package at the top of each file where you will use it: 
```
import AttributedAlertController
```

### Converting Existing UIAlertControllers
If you are currently using the UIAlertController
* Change references to `UIAlertController` to `AttributedAlertController`
* Change references to `UIAlertAction` to `AttributedAlertAction`
* Your code should now compile and run. 
* If you were using the UIAlertController.setValue function to set the private attributeMessage or attributedTitle, this approach will continue to work (but without using a private API), and you should see the attributed alert as you did before. However, you might prefer to switch to some of the other methods for setting these values (see below). 

### A Simple Alert

The following code creates a new alert with an plain text message and one button, which should look like this: 

![Simple Alert with a single button](https://user-images.githubusercontent.com/64079949/169921174-4e6708d0-ef82-4349-9abd-a173df0eae57.png)

```swift
let title = "Hello World"
let message = "This is my first alert!"
let alert = AttributedAlertController(title: title, message: message)
alert.addAction(AttributedAlertAction(title: "Thanks", style: .default))
present(alert, animated: true, completion: nil)
```
### Alert with an Attributed Message and Action Handler

This example adds an attributed message, a second button, and an action handler for one of the buttons, which produces the following alert controller. 

![Alert with stylized text](https://user-images.githubusercontent.com/64079949/169920926-d4150845-5126-489b-b5cb-ac9ac09bbbd5.png)

```swift
let title  = "Fire weapon?"
let weapon = "phasers"

let messageText = NSMutableAttributedString(
    string: "Would you like to fire the \(weapon)? ",
    attributes: [
        NSAttributedString.Key.font: AttributedAlertController.messageFont,
        NSAttributedString.Key.foregroundColor: AttributedAlertController.labelColor
    ]
)

let range = NSRange((27 ... 27 + weapon.count - 1))
messageText.setAttributes([
        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .semibold),
        NSAttributedString.Key.foregroundColor: UIColor.red
    ], range: range)

let alert = AttributedAlertController(title: title, message: messageText)
alert.addAction(AttributedAlertAction(title: "Cancel", style: .cancel))

let action = AttributedAlertAction(title: "Fire", style: .destructive, 
            handler: { (action) -> Void in
                print("Firing Weapon")
            })
alert.addAction(action)

present(alert, animated: true, completion: nil)
```

### Alert with a Text Field

Text fields can be added in a fashion similar to how they are added for the UIAlertController, as shown in the next example. They can also be retreived in the action handler, as shown. To save space, setting the attributed messages have been excluded from this example. 

![Alert with single text box](https://user-images.githubusercontent.com/64079949/169926063-00323108-8b8c-48fc-8920-e6005c561993.png)

```swift
let alert = AttributedAlertController(title: title, message: messageText)
alert.addAction(AttributedAlertAction(title: "Cancel", style: .cancel))

let action = AttributedAlertAction(title: "Fire", style: .destructive,
            handler: { (action) -> Void in
                if let textFields = alert.textFields {
                    for field in textFields {
                        print("Text field value is \(field.text ?? "")")
                    }
                }
            })
alert.addAction(action)

alert.addTextField { (newField) -> Void in
    newField.placeholder = "Enter quantity."
    newField.keyboardType = UIKeyboardType.numberPad
    newField.autocapitalizationType = UITextAutocapitalizationType.words
}

present(alert, animated: true, completion: nil)
```

## License 
AttributedAlertController is available under the MIT license. See the [LICENSE](https://github.com/devpolant/NativeUI/blob/master/LICENSE) file for more info.

--- 

## API

### AttributedAlertController Class

Use this class to control the display of the alert. 

### Functions

| Method   |  Description  |
|---------------|---------------|
| init          | Create a new Attributed Alert. Overloads are available that take title and message optional strings, title and message optional NSAttributedStrings, or an optional string title and an optional NSAttributedString message. In all cases the preferredStyle parameter is optional. If specified, it must be UIAlertController.Style.alert. |
| addAction     | Add the action specified by the provided `AttributedAlertAction` (as described below)
| addTextField  | Adds a UITextField to the alert and calls the optional configuration handler, if provided. The text field is passed to the handler to allow it to be configured. Text fields are displayed in the order in which they are added. 
| setValue      | This function may be called with an NSAttributedString value and a key of `attributedMessage` or `attributedTitle` to set those attributes. 

### Public Properties

| Property     |  Description  |
|-------------------|---------------|
| attributedTitle   | Gets or sets the title of the alert with formatting applied.
| attributedMessage | Gets or sets the message of the alert with formatting applied. 
| preferredStyle    | Gets the preferred `UIAlertController.Style` for the alert. Note that only `.alert` style is currently supported. 
| actions           | Gets the array of `AttributedAlertAction` items that the user can take in response to the alert.
| textFields        | Gets the array of `UITextFields` that will were displayed to the user. 
| message           | Gets the plain text string of the message to be displayed. 
| preferredAction   | Gets or sets the preferred action. The preferred action is stylized as a **bold** button on the alert. The indicated action must have already been added by calling the addAction method. 
| labelColor        | A static property that gets the default color for label text. Supports dark mode on iOS 13 and higher. 
| messageFont       | A static property that gets the default font used to display the message in the alert. 
| titleFont         | A static property that gets the default font used to display the title of the alert. 

### AttributedAlertAction Class

Use this class to define the text, style, and behavior of the actions (buttons) presented on the alert. 

### Function

| Method        |  Description  |
|---------------|---------------|
| init          | Creates a new AttributedAlertAction. An optional string and the `UIAlertAction.Style` of the action are required. A optional handler function that will be called if the action is selected may also be specified. The handler function will receive the UIAlertAction as a parameter. 


### Public Properties

| Property     |  Description  |
|--------------|---------------|
| title        | Gets the text assigned to the action. The title is displayed as the button text. 
| style        | Gets the `UIAlertAction.Style` of the button (.default, .cancel, or .destructive)
| handler      | Gets the optional handler for the action, if one was provided. 

---

## Functional Behavior

In general, this controller tries to mimic the behavior of the native UIAlertController, with a few exceptions. Since this behavior isn't documented, I've described it here. 

* When 3 or more buttons are requested, buttons are displayed in a vertical stack.
* When the text of 2 buttons are two long to fit on the screen next to each other, they are displayed in a vertical stack.
* When there are two horizontal buttons and one is a cancel button, cancel should be displayed first (left most).
* When there are 3 buttons and one is a cancel button, cancel should be displayed last (bottom-most)
* When multiple text fields are requested, they are displayed with padding between them, which is slightly different from the native behavior. 
* Tapping and holding as you drag your finger over the buttons highlights the button, as it does with the native controller. 
