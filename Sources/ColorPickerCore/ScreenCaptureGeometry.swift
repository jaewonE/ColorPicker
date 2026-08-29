import CoreGraphics

public enum ScreenCaptureGeometry {
    public static func captureRect(
        at point: CGPoint,
        pixelSide: Int,
        displayBounds: CGRect,
        pixelScale: CGFloat
    ) -> CGRect? {
        guard pixelSide > 0,
              pixelScale > 0,
              displayBounds.width > 0,
              displayBounds.height > 0,
              displayBounds.contains(point) else {
            return nil
        }

        let requestedSide = CGFloat(pixelSide) / pixelScale
        let side = max(1 / pixelScale, min(requestedSide, displayBounds.width, displayBounds.height))
        let x = (point.x - side / 2).clamped(
            to: displayBounds.minX...max(displayBounds.minX, displayBounds.maxX - side)
        )
        let y = (point.y - side / 2).clamped(
            to: displayBounds.minY...max(displayBounds.minY, displayBounds.maxY - side)
        )
        return CGRect(x: x, y: y, width: side, height: side)
    }

    public static func imagePoint(
        for screenPoint: CGPoint,
        captureRect: CGRect,
        imageWidth: Int,
        imageHeight: Int
    ) -> CGPoint? {
        guard captureRect.width > 0,
              captureRect.height > 0,
              imageWidth > 0,
              imageHeight > 0 else {
            return nil
        }

        return CGPoint(
            x: (screenPoint.x - captureRect.minX) / captureRect.width * CGFloat(imageWidth),
            y: (screenPoint.y - captureRect.minY) / captureRect.height * CGFloat(imageHeight)
        )
    }
}

private extension CGFloat {
    func clamped(to range: ClosedRange<CGFloat>) -> CGFloat {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
