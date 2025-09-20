# FlowGridView

FlowGridView is a flexible and lightweight grid layout component for iOS, written in Swift. It arranges subviews in a flow-style grid with configurable columns, spacing, and insets. It is suitable for dynamic content and supports per-view configuration such as column span, minimum height, and content hugging priority.

## Features

- Customizable number of columns
- Adjustable vertical and horizontal spacing
- Configurable edge insets
- Per-view column span and minimum height
- Dynamic content height callback
- Easy integration with UIKit

## Installation

Add the `FlowGridView.swift` file to your project, or use Swift Package Manager:

```
// Add the following to your Package.swift dependencies:
.package(url: "https://github.com/liulcd/flow-grid-view.git", from: "1.0.0")
```

## Usage

1. Import and create a `FlowGridView` instance:

```swift
import FlowGridView

let gridView = FlowGridView()
gridView.column = 3
gridView.verticalSpacing = 8
gridView.horizontalSpacing = 8
gridView.edgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
```

2. Add subviews and configure them:

```swift
let label1 = UILabel()
label1.text = "A"
let label2 = UILabel()
label2.text = "B"
let label3 = UILabel()
label3.text = "C"

gridView.addSubview(label1)
gridView.addSubview(label2)
gridView.addSubview(label3)

// Configure per-view properties (optional)
gridView.configView(label1, column: 2, minHeight: 40)
gridView.configView(label2, column: 1)
gridView.configView(label3, column: 1, huggingPriority: .defaultHigh)
```

3. Listen for content height updates (optional):

```swift
gridView.contentHeightUpdated = { height in
	print("Content height: \(height)")
}
```

4. Add `gridView` to your view hierarchy and set its frame or constraints as needed.

## Example

```swift
let gridView = FlowGridView()
gridView.column = 2
gridView.verticalSpacing = 10
gridView.horizontalSpacing = 10
gridView.edgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)

for i in 1...6 {
	let label = UILabel()
	label.text = "Item \(i)"
	label.backgroundColor = .systemBlue
	label.textAlignment = .center
	label.textColor = .white
	gridView.addSubview(label)
	gridView.configView(label, minHeight: 44)
}

view.addSubview(gridView)
gridView.frame = CGRect(x: 0, y: 100, width: view.bounds.width, height: 300)
```

## License

MIT
