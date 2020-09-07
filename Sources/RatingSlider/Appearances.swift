import Foundation
import UIKit

public enum GridStyle {
    case labeled(LabelAppearance)
    case dotted(DotAppearance)

    var hasUpperLabeledGrid: Bool {
        guard case .dotted(let appearance) = self, appearance.labels != nil else { return false }
        return true
    }

    var labeledGridHeight: CGFloat? {
        guard case .dotted(let appearance) = self, let labeledAppearance = appearance.labels else { return nil }
        return max(labeledAppearance.inactiveFont.textHeight(), labeledAppearance.activeFont.textHeight())
    }
}

// MARK: - Label

public struct LabelAppearance {

    public let activeFont: UIFont
    public let activeColor: UIColor
    public let inactiveFont: UIFont
    public let inactiveColor: UIColor

    public init(
        activeFont: UIFont = .systemFont(ofSize: 12, weight: .bold),
        activeColor: UIColor = .black,
        inactiveFont: UIFont = .systemFont(ofSize: 12, weight: .regular),
        inactiveColor: UIColor = .lightGray
    ) {
        self.activeFont = activeFont
        self.activeColor = activeColor
        self.inactiveFont = inactiveFont
        self.inactiveColor = inactiveColor
    }

    public static let `default`: Self = LabelAppearance()

    func fontAndColor(isActive: Bool) -> (font: UIFont, color: UIColor) {
        isActive ? (activeFont, activeColor) : (inactiveFont, inactiveColor)
    }
}

// MARK: - Dot

public struct DotAppearance {

    public let activeColor: UIColor
    public let activeSize: CGFloat
    public let inactiveColor: UIColor
    public let inactiveSize: CGFloat

    public let labels: LabelAppearance?

    public init(
        activeColor: UIColor = .black,
        activeSize: CGFloat = 3.0,
        inactiveColor: UIColor = .lightGray,
        inactiveSize: CGFloat = 3.0,
        labels: LabelAppearance? = nil
    ) {
        self.activeColor = activeColor
        self.activeSize = activeSize
        self.inactiveColor = inactiveColor
        self.inactiveSize = inactiveSize
        self.labels = labels
    }

    public static let `default`: Self = DotAppearance()

    func sizeAndColor(isActive: Bool) -> (size: CGFloat, color: UIColor) {
        isActive ? (activeSize, activeColor) : (inactiveSize, inactiveColor)
    }
}

private extension UIFont {

    func textHeight(width: CGFloat = UIScreen.main.bounds.width) -> CGFloat {

        let fakeString = " "
        let constraintRect = CGSize(width: UIScreen.main.bounds.width, height: .greatestFiniteMagnitude)

        let boundingBox = fakeString.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font: self],
            context: nil
        )

        return ceil(boundingBox.height)
    }
}
