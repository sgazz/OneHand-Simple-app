import XCTest
import SwiftUI
import PhotosUI
@testable import UhIH

class MockPhotosPickerItem: ImagePickerItem {
    let mockImage: UIImage
    
    init(mockImage: UIImage) {
        self.mockImage = mockImage
    }
    
    func loadTransferable<T>(type: T.Type) async throws -> T? where T : Transferable {
        if T.self == Data.self {
            return mockImage.jpegData(compressionQuality: 1.0) as? T
        }
        return nil
    }
}

final class ContentViewModelTests: XCTestCase {
    var sut: ContentViewModel!
    
    override func setUp() {
        super.setUp()
        sut = ContentViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Helper Methods
    
    private func createImage(width: Int, height: Int) -> UIImage {
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.red.cgColor)
        context?.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    // MARK: - calculateMaxOffset Tests
    
    func testCalculateMaxOffset_WithPortraitImage() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        
        // When - sa normalnim scale
        sut.scale = 1.0
        let result = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result!.x, 0)
        XCTAssertGreaterThanOrEqual(result!.y, 0)
        
        // When - sa većim scale
        sut.scale = 2.0
        let resultZoomed = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(resultZoomed)
        XCTAssertGreaterThanOrEqual(resultZoomed!.x, result!.x)
        XCTAssertGreaterThanOrEqual(resultZoomed!.y, result!.y)
    }
    
    func testCalculateMaxOffset_WithLandscapeImage() {
        // Given
        let image = createImage(width: 1200, height: 800)
        sut.selectedImage = image
        
        // When - sa normalnim scale
        sut.scale = 1.0
        let result = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result!.x, 0)
        XCTAssertGreaterThanOrEqual(result!.y, 0)
        
        // When - sa većim scale
        sut.scale = 2.0
        let resultZoomed = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(resultZoomed)
        XCTAssertGreaterThanOrEqual(resultZoomed!.x, result!.x)
        XCTAssertGreaterThanOrEqual(resultZoomed!.y, result!.y)
    }
    
    func testCalculateMaxOffset_WithSquareImage() {
        // Given
        let image = createImage(width: 800, height: 800)
        sut.selectedImage = image
        
        // When - sa normalnim scale
        sut.scale = 1.0
        let result = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertGreaterThanOrEqual(result!.x, 0)
        XCTAssertGreaterThanOrEqual(result!.y, 0)
        
        // When - sa većim scale
        sut.scale = 2.0
        let resultZoomed = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(resultZoomed)
        XCTAssertGreaterThanOrEqual(resultZoomed!.x, result!.x)
        XCTAssertGreaterThanOrEqual(resultZoomed!.y, result!.y)
    }
    
    func testCalculateMaxOffset_WithNoImage() {
        // Given
        sut.selectedImage = nil
        
        // When
        let result = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNil(result)
    }
    
    func testCalculateMaxOffset_WithRotatedImage() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        sut.scale = 1.0
        
        // When - sa rotacijom od 90 stepeni
        sut.rotation = 90
        let result90 = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result90)
        XCTAssertGreaterThanOrEqual(result90!.x, 0)
        XCTAssertGreaterThanOrEqual(result90!.y, 0)
        
        // When - sa rotacijom od 180 stepeni
        sut.rotation = 180
        let result180 = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result180)
        XCTAssertGreaterThanOrEqual(result180!.x, 0)
        XCTAssertGreaterThanOrEqual(result180!.y, 0)
        
        // When - sa rotacijom od 270 stepeni
        sut.rotation = 270
        let result270 = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result270)
        XCTAssertGreaterThanOrEqual(result270!.x, 0)
        XCTAssertGreaterThanOrEqual(result270!.y, 0)
    }
    
    func testCalculateMaxOffset_WithLargeImage() {
        // Given
        let image = createImage(width: 2000, height: 2000)
        sut.selectedImage = image
        sut.scale = 1.0
        
        // When
        let result = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!.x, 0)
        XCTAssertGreaterThan(result!.y, 0)
        
        // When - sa većim scale
        sut.scale = 2.0
        let resultZoomed = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(resultZoomed)
        XCTAssertGreaterThan(resultZoomed!.x, result!.x)
        XCTAssertGreaterThan(resultZoomed!.y, result!.y)
    }
    
    func testCalculateMaxOffset_WithSmallImage() {
        // Given
        let image = createImage(width: 100, height: 100)
        sut.selectedImage = image
        sut.scale = 1.0
        
        // When
        let result = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.x, 0)
        XCTAssertEqual(result!.y, 0)
        
        // When - sa većim scale
        sut.scale = 2.0
        let resultZoomed = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(resultZoomed)
        XCTAssertGreaterThanOrEqual(resultZoomed!.x, 0)
        XCTAssertGreaterThanOrEqual(resultZoomed!.y, 0)
    }
    
    // MARK: - Zoom Tests
    
    func testZoomIn() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        sut.scale = 1.0
        
        // When
        sut.zoomIn()
        
        // Then
        XCTAssertEqual(sut.scale, 1.2, accuracy: 0.01)
    }
    
    func testZoomOut() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        sut.scale = 2.0
        
        // When
        sut.zoomOut()
        
        // Then
        XCTAssertEqual(sut.scale, 1.6, accuracy: 0.01)
    }
    
    func testZoomToMax() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        sut.scale = 1.0
        
        // When
        sut.zoomToMax()
        
        // Then
        XCTAssertEqual(sut.scale, sut.maxScale)
    }
    
    func testZoomToMin() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        sut.scale = 5.0
        
        // When
        sut.zoomToMin()
        
        // Then
        XCTAssertEqual(sut.scale, sut.minScale)
    }
    
    func testZoomLimits() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        
        // When - pokušavamo da zumiramo preko maksimuma
        sut.scale = sut.maxScale
        sut.zoomIn()
        
        // Then
        XCTAssertEqual(sut.scale, sut.maxScale)
        
        // When - pokušavamo da zumiramo ispod minimuma
        sut.scale = sut.minScale
        sut.zoomOut()
        
        // Then
        XCTAssertEqual(sut.scale, sut.minScale)
    }
    
    func testContinuousZooming() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        sut.scale = 1.0
        
        // When - startujemo kontinuirani zoom in
        sut.startContinuousZoomIn()
        
        // Then
        XCTAssertTrue(sut.isZooming)
        
        // When - zaustavljamo zoom
        sut.stopZooming()
        
        // Then
        XCTAssertFalse(sut.isZooming)
    }
    
    // MARK: - Rotation Tests
    
    func testRotateClockwise() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        sut.rotation = 0.0
        
        // When
        sut.rotateClockwise()
        
        // Then
        XCTAssertEqual(sut.rotation, 45.0, accuracy: 0.01)
    }
    
    func testRotateCounterclockwise() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        sut.rotation = 45.0
        
        // When
        sut.rotateCounterclockwise()
        
        // Then
        XCTAssertEqual(sut.rotation, 0.0, accuracy: 0.01)
    }
    
    func testContinuousRotation() {
        // Given
        let initialRotation = sut.rotation
        
        // When
        sut.startContinuousRotationClockwise()
        
        // Then
        XCTAssertTrue(sut.isRotating)
        
        // When
        sut.stopRotation()
        
        // Then
        XCTAssertFalse(sut.isRotating)
        XCTAssertNotEqual(sut.rotation, initialRotation)
    }
    
    func testRotationLimits() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        sut.rotation = 0.0
        
        // When - rotiramo u smeru kazaljke na satu
        sut.rotateClockwise()
        sut.rotateClockwise()
        sut.rotateClockwise()
        sut.rotateClockwise()
        
        // Then
        XCTAssertEqual(sut.rotation, 180.0, accuracy: 0.01)
        
        // When - rotiramo u suprotnom smeru
        sut.rotateCounterclockwise()
        sut.rotateCounterclockwise()
        
        // Then
        XCTAssertEqual(sut.rotation, 90.0, accuracy: 0.01)
    }
    
    // MARK: - Motion Tracking Tests
    
    func testToggleMotionTracking() {
        // Given
        let image = createImage(width: 800, height: 600)
        sut.selectedImage = image
        sut.hasSelectedImage = true
        
        // When
        sut.toggleMotionTracking()
        
        // Then
        XCTAssertTrue(sut.isMotionTrackingEnabled)
        XCTAssertEqual(sut.imageOffset, .zero)
        
        // When
        sut.toggleMotionTracking()
        
        // Then
        XCTAssertFalse(sut.isMotionTrackingEnabled)
    }
    
    func testMotionTrackingWithImage() async throws {
        // Arrange
        let mockImage = UIImage(systemName: "photo")!
        let mockItem = MockPhotosPickerItem(mockImage: mockImage)
        await sut.handleImageSelection([mockItem])
        
        // Act & Assert
        XCTAssertFalse(sut.isMotionTrackingEnabled)
        XCTAssertEqual(sut.imageOffset, .zero)
        
        sut.toggleMotionTracking()
        
        XCTAssertTrue(sut.isMotionTrackingEnabled)
        XCTAssertEqual(sut.imageOffset, .zero)
        
        sut.toggleMotionTracking()
        
        XCTAssertFalse(sut.isMotionTrackingEnabled)
        XCTAssertEqual(sut.imageOffset, .zero)
    }
    
    func testMotionTrackingWithoutImage() {
        // Arrange
        XCTAssertNil(sut.selectedImage)
        
        // Act
        sut.toggleMotionTracking()
        
        // Assert
        XCTAssertFalse(sut.isMotionTrackingEnabled)
        XCTAssertEqual(sut.imageOffset, .zero)
    }
    
    func testCalculateMaxOffset() {
        // Given
        let screenSize = UIScreen.main.bounds.size
        let image = createImage(width: Int(screenSize.width), height: Int(screenSize.height))
        sut.selectedImage = image
        sut.scale = 2.0
        
        // When
        let maxOffset = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(maxOffset)
        if let offset = maxOffset {
            XCTAssertGreaterThan(offset.x, 0)
            XCTAssertGreaterThan(offset.y, 0)
            
            // Provera da li su offseti u očekivanom opsegu
            let expectedMaxOffsetX = screenSize.width * 0.5 // (2.0 - 1.0) * width / 2
            let expectedMaxOffsetY = screenSize.height * 0.5 // (2.0 - 1.0) * height / 2
            XCTAssertEqual(offset.x, expectedMaxOffsetX, accuracy: 1.0)
            XCTAssertEqual(offset.y, expectedMaxOffsetY, accuracy: 1.0)
        }
    }
    
    func testGetOffsetInfo() {
        // Given
        let image = createImage(width: 800, height: 600)
        sut.selectedImage = image
        sut.hasSelectedImage = true
        
        // When
        let offsetInfo = sut.getOffsetInfo()
        
        // Then
        XCTAssertFalse(offsetInfo.isEmpty)
        XCTAssertTrue(offsetInfo.contains("Trenutno pomeranje"))
        XCTAssertTrue(offsetInfo.contains("Maksimalno pomeranje"))
    }
    
    // MARK: - Handedness Tests
    
    func testHandednessSelection() {
        // Given
        XCTAssertNil(sut.selectedHand, "Initially, no hand should be selected")
        
        // When
        sut.selectedHand = .right
        
        // Then
        XCTAssertEqual(sut.selectedHand, .right)
        
        // When
        sut.selectedHand = .left
        
        // Then
        XCTAssertEqual(sut.selectedHand, .left)
    }
    
    // MARK: - Reset Tests
    
    func testResetApp() {
        // Given
        let image = createImage(width: 800, height: 600)
        sut.selectedImage = image
        sut.hasSelectedImage = true
        sut.selectedHand = .right
        sut.scale = 2.0
        sut.rotation = 45.0
        sut.imageOffset = CGPoint(x: 100, y: 100)
        sut.isMotionTrackingEnabled = true
        
        // When
        sut.resetApp()
        
        // Then
        XCTAssertNil(sut.selectedHand)
        XCTAssertTrue(sut.selectedItems.isEmpty)
        XCTAssertTrue(sut.images.isEmpty)
        XCTAssertNil(sut.selectedImage)
        XCTAssertFalse(sut.hasSelectedImage)
        XCTAssertEqual(sut.scale, sut.minScale)
        XCTAssertEqual(sut.rotation, 0)
        XCTAssertEqual(sut.imageOffset, .zero)
        XCTAssertFalse(sut.isMotionTrackingEnabled)
    }
    
    func testResetImage() {
        // Given
        let image = createImage(width: 800, height: 600)
        sut.selectedImage = image
        sut.scale = 2.0
        sut.rotation = 45.0
        sut.imageOffset = CGPoint(x: 100, y: 100)
        sut.isMotionTrackingEnabled = true
        
        // When
        sut.resetImage()
        
        // Then
        XCTAssertEqual(sut.scale, sut.minScale)
        XCTAssertEqual(sut.rotation, 0)
        XCTAssertEqual(sut.imageOffset, .zero)
        XCTAssertFalse(sut.isMotionTrackingEnabled)
        XCTAssertNotNil(sut.selectedImage)
    }
    
    // MARK: - Image Info Tests
    
    func testGetImageSizeInfo() {
        // Given
        let image = createImage(width: 800, height: 600)
        sut.selectedImage = image
        sut.scale = 2.0
        sut.rotation = 45.0
        
        // When
        let sizeInfo = sut.getImageSizeInfo()
        
        // Then
        XCTAssertTrue(sizeInfo.contains("1600×1200"), "Should show scaled dimensions")
        XCTAssertTrue(sizeInfo.contains("2.0x"), "Should show correct zoom level")
        XCTAssertTrue(sizeInfo.contains("45.0°"), "Should show correct rotation")
        
        // When - bez slike
        sut.selectedImage = nil
        let noImageInfo = sut.getImageSizeInfo()
        
        // Then
        XCTAssertEqual(noImageInfo, "Nema slike")
    }
    
    // MARK: - Image Handling Tests
    
    func testHandleImageSelection() async throws {
        // Given
        let mockImage = UIImage(systemName: "photo")!
        let mockItem = MockPhotosPickerItem(mockImage: mockImage)
        
        // When
        await sut.handleImageSelection([mockItem])
        
        // Then
        XCTAssertEqual(sut.images.count, 1)
        XCTAssertEqual(sut.selectedImage, mockImage)
        XCTAssertEqual(sut.scale, sut.minScale)
    }
    
    func testHandleInvalidImageSelection() async throws {
        // Given
        let mockImage = UIImage(systemName: "photo")!
        let mockItem = MockPhotosPickerItem(mockImage: mockImage)
        
        // When
        await sut.handleImageSelection([])
        
        // Then
        XCTAssertEqual(sut.images.count, 0)
        XCTAssertNil(sut.selectedImage)
    }
    
    func testMultipleImageSelection() async throws {
        // Given
        let mockImage1 = UIImage(systemName: "photo")!
        let mockImage2 = UIImage(systemName: "camera")!
        let mockItem1 = MockPhotosPickerItem(mockImage: mockImage1)
        let mockItem2 = MockPhotosPickerItem(mockImage: mockImage2)
        
        // When
        await sut.handleImageSelection([mockItem1, mockItem2])
        
        // Then
        XCTAssertEqual(sut.images.count, 2)
        XCTAssertEqual(sut.selectedImage, mockImage2)
    }
    
    func testLargeImageHandling() async throws {
        // Given
        let size = CGSize(width: 4000, height: 3000)
        UIGraphicsBeginImageContext(size)
        let largeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let mockItem = MockPhotosPickerItem(mockImage: largeImage)
        
        // When
        await sut.handleImageSelection([mockItem])
        
        // Then
        XCTAssertEqual(sut.images.count, 1)
        XCTAssertEqual(sut.selectedImage, largeImage)
        XCTAssertEqual(sut.scale, sut.minScale)
    }
    
    // MARK: - Performance Boundary Tests
    
    func testExtremeZoomValues() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        
        // When - Pokušaj postavljanja ekstremno velike vrednosti za scale
        sut.scale = 1000.0
        
        // Then
        XCTAssertEqual(sut.scale, sut.maxScale)
        
        // When - Pokušaj postavljanja ekstremno male vrednosti za scale
        sut.scale = 0.01
        
        // Then
        XCTAssertEqual(sut.scale, sut.minScale)
    }
    
    func testExtremeRotationValues() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        
        // When - Pokušaj rotacije preko 360 stepeni
        sut.rotation = 720
        
        // Then
        XCTAssertEqual(sut.rotation.truncatingRemainder(dividingBy: 360), 0)
        
        // When - Pokušaj negativne rotacije
        sut.rotation = -720
        
        // Then
        XCTAssertEqual(sut.rotation.truncatingRemainder(dividingBy: 360), 0)
    }
    
    func testRapidStateChanges() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        
        // When - Brze promene scale i rotation
        for _ in 0..<100 {
            sut.scale = Double.random(in: sut.minScale...sut.maxScale)
            sut.rotation = Double.random(in: 0...360)
        }
        
        // Then
        XCTAssertGreaterThanOrEqual(sut.scale, sut.minScale)
        XCTAssertLessThanOrEqual(sut.scale, sut.maxScale)
        XCTAssertGreaterThanOrEqual(sut.rotation, 0)
        XCTAssertLessThanOrEqual(sut.rotation, 360)
    }
    
    // MARK: - Combined Operations Tests
    
    func testSimultaneousZoomAndRotation() {
        // Given
        let initialScale = sut.scale
        let initialRotation = sut.rotation
        
        // When
        sut.startContinuousZoomIn()
        sut.startContinuousRotationClockwise()
        
        // Then
        XCTAssertTrue(sut.isZooming)
        XCTAssertTrue(sut.isRotating)
        
        // When
        sut.stopZooming()
        sut.stopRotation()
        
        // Then
        XCTAssertFalse(sut.isZooming)
        XCTAssertFalse(sut.isRotating)
        XCTAssertNotEqual(sut.scale, initialScale)
        XCTAssertNotEqual(sut.rotation, initialRotation)
    }
    
    func testMotionTrackingDuringZoom() {
        // Given
        let image = createImage(width: 800, height: 1200)
        sut.selectedImage = image
        sut.isMotionTrackingEnabled = true
        let initialOffset = sut.imageOffset
        
        // When - Zumiranje tokom praćenja pokreta
        sut.scale = 2.0
        sut.updateImagePositionForTesting(pitch: 0.5, roll: 0.5)
        
        // Then
        XCTAssertNotEqual(sut.imageOffset, initialOffset)
        XCTAssertTrue(sut.isMotionTrackingEnabled)
        
        // When - Promena scale-a tokom praćenja
        let currentOffset = sut.imageOffset
        sut.scale = 3.0
        sut.updateImagePositionForTesting(pitch: 0.5, roll: 0.5)
        
        // Then
        XCTAssertNotEqual(sut.imageOffset, currentOffset)
    }
    
    func testOperationCancellation() async throws {
        // Given
        let image = UIImage(systemName: "photo")!
        let mockItem = MockPhotosPickerItem(mockImage: image)
        await sut.handleImageSelection([mockItem])
        
        sut.startContinuousZoomIn()
        sut.startContinuousRotationClockwise()
        sut.toggleMotionTracking()
        
        // When
        sut.resetImage()
        
        // Then
        XCTAssertFalse(sut.isZooming)
        XCTAssertFalse(sut.isRotating)
        XCTAssertFalse(sut.isMotionTrackingEnabled)
        XCTAssertEqual(sut.scale, sut.minScale)
        XCTAssertEqual(sut.rotation, 0)
        XCTAssertEqual(sut.imageOffset, .zero)
    }
    
    // MARK: - One-Handed Operation Tests
    
    func testOneHandedImageSelection() async throws {
        // Given
        let mockImage = UIImage(systemName: "photo")!
        let mockItem = MockPhotosPickerItem(mockImage: mockImage)
        
        // When
        await sut.handleImageSelection([mockItem])
        
        // Then
        XCTAssertEqual(sut.images.count, 1)
        XCTAssertEqual(sut.selectedImage, mockImage)
        XCTAssertEqual(sut.scale, sut.minScale)
        XCTAssertEqual(sut.rotation, 0)
        XCTAssertEqual(sut.imageOffset, .zero)
    }
    
    func testOneHandedImageReset() {
        // Given
        let image = createImage(width: 800, height: 600)
        sut.selectedImage = image
        sut.scale = 2.0
        sut.rotation = 45.0
        sut.imageOffset = CGPoint(x: 100, y: 100)
        
        // When
        sut.resetImage()
        
        // Then
        XCTAssertEqual(sut.scale, sut.minScale)
        XCTAssertEqual(sut.rotation, 0)
        XCTAssertEqual(sut.imageOffset, .zero)
    }
    
    func testOneHandedAppReset() {
        // Given
        let image = createImage(width: 800, height: 600)
        sut.selectedImage = image
        sut.hasSelectedImage = true
        sut.selectedHand = .right
        sut.scale = 2.0
        sut.rotation = 45.0
        sut.imageOffset = CGPoint(x: 100, y: 100)
        
        // When
        sut.resetApp()
        
        // Then
        XCTAssertNil(sut.selectedHand)
        XCTAssertTrue(sut.selectedItems.isEmpty)
        XCTAssertTrue(sut.images.isEmpty)
        XCTAssertNil(sut.selectedImage)
        XCTAssertFalse(sut.hasSelectedImage)
        XCTAssertEqual(sut.scale, sut.minScale)
        XCTAssertEqual(sut.rotation, 0)
        XCTAssertEqual(sut.imageOffset, .zero)
    }
    
    func testMotionTrackingForOneHandedOperation() {
        // Given
        let image = createImage(width: 800, height: 600)
        sut.selectedImage = image
        sut.hasSelectedImage = true
        
        // When
        sut.toggleMotionTracking()
        
        // Then
        XCTAssertTrue(sut.isMotionTrackingEnabled)
        XCTAssertEqual(sut.imageOffset, .zero)
        
        // When
        sut.toggleMotionTracking()
        
        // Then
        XCTAssertFalse(sut.isMotionTrackingEnabled)
    }
    
    func testImageInfoForOneHandedOperation() {
        // Given
        let image = createImage(width: 800, height: 600)
        sut.selectedImage = image
        sut.scale = 2.0
        sut.rotation = 45.0
        
        // When
        let sizeInfo = sut.getImageSizeInfo()
        
        // Then
        XCTAssertTrue(sizeInfo.contains("1600×1200"), "Should show scaled dimensions")
        XCTAssertTrue(sizeInfo.contains("2.0x"), "Should show correct zoom level")
        XCTAssertTrue(sizeInfo.contains("45.0°"), "Should show correct rotation")
    }
    
    func testOffsetInfoForOneHandedOperation() {
        // Given
        let image = createImage(width: 800, height: 600)
        sut.selectedImage = image
        sut.hasSelectedImage = true
        
        // When
        let offsetInfo = sut.getOffsetInfo()
        
        // Then
        XCTAssertFalse(offsetInfo.isEmpty)
        XCTAssertTrue(offsetInfo.contains("Trenutno pomeranje"))
        XCTAssertTrue(offsetInfo.contains("Maksimalno pomeranje"))
    }
    
    func testLargeImageHandlingForOneHandedOperation() async throws {
        // Given
        let size = CGSize(width: 4000, height: 3000)
        UIGraphicsBeginImageContext(size)
        let largeImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let mockItem = MockPhotosPickerItem(mockImage: largeImage)
        
        // When
        await sut.handleImageSelection([mockItem])
        
        // Then
        XCTAssertEqual(sut.images.count, 1)
        XCTAssertEqual(sut.selectedImage, largeImage)
        XCTAssertEqual(sut.scale, sut.minScale)
        XCTAssertEqual(sut.rotation, 0)
        XCTAssertEqual(sut.imageOffset, .zero)
    }
    
    func testMultipleImageSelectionForOneHandedOperation() async throws {
        // Given
        let mockImage1 = UIImage(systemName: "photo")!
        let mockImage2 = UIImage(systemName: "camera")!
        let mockItem1 = MockPhotosPickerItem(mockImage: mockImage1)
        let mockItem2 = MockPhotosPickerItem(mockImage: mockImage2)
        
        // When
        await sut.handleImageSelection([mockItem1, mockItem2])
        
        // Then
        XCTAssertEqual(sut.images.count, 2)
        XCTAssertEqual(sut.selectedImage, mockImage2)
        XCTAssertEqual(sut.scale, sut.minScale)
        XCTAssertEqual(sut.rotation, 0)
        XCTAssertEqual(sut.imageOffset, .zero)
    }
    
    // MARK: - Edge Cases Tests
    
    func testCalculateMaxOffset_WithExtremelyLargeImage() {
        // Given
        let image = createImage(width: 4000, height: 4000)
        sut.selectedImage = image
        sut.scale = 1.0
        
        // When
        let result = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!.x, 0)
        XCTAssertGreaterThan(result!.y, 0)
    }
    
    func testCalculateMaxOffset_WithExtremelySmallImage() {
        // Given
        let image = createImage(width: 50, height: 50)
        sut.selectedImage = image
        sut.scale = 1.0
        
        // When
        let result = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.x, 0)
        XCTAssertEqual(result!.y, 0)
    }
    
    func testCalculateMaxOffset_WithImageLargerThanScreen() {
        // Given
        let image = createImage(width: 3000, height: 2000)
        sut.selectedImage = image
        sut.scale = 1.0
        
        // When
        let result = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertGreaterThan(result!.x, 0)
        XCTAssertGreaterThan(result!.y, 0)
    }
    
    func testCalculateMaxOffset_WithImageSmallerThanScreen() {
        // Given
        let image = createImage(width: 200, height: 200)
        sut.selectedImage = image
        sut.scale = 1.0
        
        // When
        let result = sut.calculateMaxOffset()
        
        // Then
        XCTAssertNotNil(result)
        XCTAssertEqual(result!.x, 0)
        XCTAssertEqual(result!.y, 0)
    }
} 