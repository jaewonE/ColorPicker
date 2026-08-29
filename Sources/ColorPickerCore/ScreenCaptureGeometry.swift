import CoreGraphics

public enum ScreenCaptureGeometry {
    public static func backingScale(
        displayBounds: CGRect,
        backingPixelWidth: Int,
        backingPixelHeight: Int
    ) -> CGFloat? {
        guard displayBounds.width > 0,
              displayBounds.height > 0,
              backingPixelWidth > 0,
              backingPixelHeight > 0 else {
            return nil
        }

        let horizontalScale = CGFloat(backingPixelWidth) / displayBounds.width
        let verticalScale = CGFloat(backingPixelHeight) / displayBounds.height
        return max(horizontalScale, verticalScale)
    }

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

        let displayPixelWidth = max(1, Int((displayBounds.width * pixelScale).rounded()))
        let displayPixelHeight = max(1, Int((displayBounds.height * pixelScale).rounded()))
        let sidePixels = min(pixelSide, displayPixelWidth, displayPixelHeight)
        let pointerPixelX = Int(floor((point.x - displayBounds.minX) * pixelScale))
            .clamped(to: 0...(displayPixelWidth - 1))
        let pointerPixelY = Int(floor((point.y - displayBounds.minY) * pixelScale))
            .clamped(to: 0...(displayPixelHeight - 1))
        let originPixelX = (pointerPixelX - sidePixels / 2)
            .clamped(to: 0...(displayPixelWidth - sidePixels))
        let originPixelY = (pointerPixelY - sidePixels / 2)
            .clamped(to: 0...(displayPixelHeight - sidePixels))

        return CGRect(
            x: displayBounds.minX + CGFloat(originPixelX) / pixelScale,
            y: displayBounds.minY + CGFloat(originPixelY) / pixelScale,
            width: CGFloat(sidePixels) / pixelScale,
            height: CGFloat(sidePixels) / pixelScale
        )
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

        let pixelX = Int(floor(
            (screenPoint.x - captureRect.minX) / captureRect.width * CGFloat(imageWidth)
        )).clamped(to: 0...(imageWidth - 1))
        let pixelY = Int(floor(
            (screenPoint.y - captureRect.minY) / captureRect.height * CGFloat(imageHeight)
        )).clamped(to: 0...(imageHeight - 1))
        return CGPoint(
            x: pixelX,
            y: pixelY
        )
    }
}

private extension Int {
    func clamped(to range: ClosedRange<Int>) -> Int {
        Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
