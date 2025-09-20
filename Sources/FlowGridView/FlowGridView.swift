// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit

@MainActor
class FlowGridView: UIView {
    
    // MARK: - Public Properties
    
    var column: UInt = 1 {
        didSet {
            if column == 0 {
                column = 1
            }
            if oldValue != column {
                setNeedsLayout()
            }
        }
    }
    
    var edgeInsets: UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            if oldValue != edgeInsets {
                self.contentView.contentInset = UIEdgeInsets(top: edgeInsets.top, left: 0, bottom: edgeInsets.bottom, right: 0)
                setNeedsLayout()
            }
        }
    }
    
    var verticalSpacing: CGFloat = 0 {
        didSet {
            if oldValue != verticalSpacing {
                setNeedsLayout()
            }
        }
    }
    
    var horizontalSpacing: CGFloat = 0 {
        didSet {
            if oldValue != horizontalSpacing {
                setNeedsLayout()
            }
        }
    }
    
    var contentHeightUpdated: ((_ contentHeight: CGFloat) -> Void)?
    
    // MARK: - Public Functions
        
    func configView(_ view: UIView, hidden: Bool? = nil, huggingPriority: UILayoutPriority? = nil, column: UInt? = nil, minHeight: CGFloat? = nil) {
        if !subviews.contains(where: { element in
            return element == view
        }) {
            addSubview(view)
        }
        guard let configuration = configurations[view] else { return }
        var updated = false
        if let hidden = hidden  {
            if view.isHidden != hidden {
                view.isHidden = hidden
                updated = true
            }
        }
        if updated == false, let huggingPriority = huggingPriority {
            if view.contentHuggingPriority(for: .horizontal) != huggingPriority {
                view.setContentHuggingPriority(huggingPriority, for: .horizontal)
                updated = true
            }
        }
        if updated == false, let column = column {
            if configuration.column != column {
                configuration.column = column
                updated = true
            }
        }
        if updated == false, let minHeight = minHeight {
            if configuration.minHeight != minHeight {
                configuration.minHeight = minHeight
                updated = true
            }
        }
        if updated {
            setNeedsLayout()
        }
    }

    // MARK: - Layout
    
    override func addSubview(_ view: UIView) {
        if contentView.superview != self {
            super.addSubview(contentView)
        }
        contentView.addSubview(view)
        if configurations[view] == nil {} else {
            configurations[view] = Configuration()
        }
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if CGSizeEqualToSize(bounds.size, CGSizeZero) {
            return
        }
        
        configurations.forEach { element, _ in
            if element.superview != self {
                configurations.removeValue(forKey: element)
            }
        }
        contentView.frame = self.bounds
        var contentHeight: CGFloat = 0
        let rows = getVisibleViewRows()
        for index in 0 ..< rows.count {
            let views = rows[index]
            let rowViewSize = getRowViewSize(views)
            layoutRowViews(views, offsetY: contentHeight, size: rowViewSize)
            contentHeight += rowViewSize.height
            if index < rows.count - 1 {
                contentHeight += verticalSpacing
            }
        }
        contentHeight += edgeInsets.top + edgeInsets.bottom
        if contentHeight != self.bounds.size.height {
            self.contentHeightUpdated?(contentHeight)
        }
    }
    
    private func getRowViewSize(_ views: [UIView]) -> CGSize {
        var height: CGFloat = 0
        let width: CGFloat = (self.contentView.frame.size.width + self.horizontalSpacing - edgeInsets.left - edgeInsets.right) / CGFloat(self.column) - self.horizontalSpacing
        views.forEach { element in
            guard let configuration = configurations[element] else { return }
            var viewHeight = configuration.minHeight
            if viewHeight <= 0 {
                viewHeight = element.bounds.size.height * 2
            }
            if viewHeight <= 0 {
                viewHeight = self.bounds.size.height
            }
            viewHeight = element.systemLayoutSizeFitting(CGSize(width: width, height: viewHeight)).height
            if viewHeight > height {
                height = element.bounds.size.height
            }
        }
        return CGSize(width: width, height: height)
    }
    
    private func layoutRowViews(_ views: [UIView], offsetY: CGFloat, size: CGSize) {
        var offsetX: CGFloat = edgeInsets.left
        views.forEach { element in
            guard let configuration = configurations[element] else { return }
            element.translatesAutoresizingMaskIntoConstraints = true
            let width = size.width * CGFloat(configuration.updatedColumn)
            element.frame = CGRect(x: offsetX, y: offsetY, width: width, height: size.height)
            offsetX += width + horizontalSpacing
        }
    }

    private func getVisibleViewRows() -> [[UIView]] {
        var visible: [[UIView]] = []
        var views: [UIView] = []
        var column: UInt = 0
        contentView.subviews.forEach { element in
            guard element.isHidden == false, let configuration = configurations[element] else { return }
            column += configuration.column
            if column > self.column {
                if views.count > 0 {
                    updateHuggingViews(views)
                    visible.append(views)
                    views = []
                }
                column = 0
            }
            views.append(element)
        }
        if views.count > 0 {
            updateHuggingViews(views)
            visible.append(views)
        }
        return visible
    }
    
    private func updateHuggingViews(_ views: [UIView]) {
        if views.count <= 1 {
            return
        }
        var column: UInt = 0
        views.forEach { element in
            guard let configuration = configurations[element] else { return }
            column += configuration.column
        }
        column = self.column - column
        if column <= 0 {
            return
        }
        let views = views.sorted { view1, view2 in
            view1.contentHuggingPriority(for: .horizontal) < view2.contentHuggingPriority(for: .horizontal)
        }
        guard let view = views.first else { return }
        let priority = view.contentHuggingPriority(for: .horizontal)
        if priority > .required {
            return
        }
        var huggingViews: [UIView] = []
        views.forEach { element in
            if element.contentHuggingPriority(for: .horizontal) == priority {
                huggingViews.append(element)
            }
        }
        let averageColumn = column / UInt(huggingViews.count)
        if averageColumn > 0 {
            huggingViews.forEach { element in
                guard let configuration = configurations[element] else { return }
                configuration.updatedColumn += averageColumn
            }
        }
        let remainColumn = column % UInt(huggingViews.count)
        if remainColumn > 0 {
            for index in 0 ..< remainColumn {
                let view = huggingViews[Int(index)]
                guard let configuration = configurations[view] else { return }
                configuration.updatedColumn += 1
            }
        }
    }
    
    // MARK: - Configuration
    
    private class Configuration: NSObject {
        var column: UInt = 1 {
            didSet {
                if column == 0 {
                    column = 1
                }
                self.updatedColumn = column
            }
        }
        
        var updatedColumn: UInt = 1
        
        var minHeight: CGFloat = 0
    }
    
    private var configurations: [UIView: Configuration] = [:]
        
    // MARK: - ContentView
    
    private(set) lazy var contentView: UIScrollView = {
        let view = UIScrollView()
        return view
    }()
}
