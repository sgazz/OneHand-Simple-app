import XCTest

final class UhIHUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    func testAddImage() throws {
        // Pronađi i tapni dugme za dodavanje slike
        let addButton = app.buttons["Add Image"]
        XCTAssertTrue(addButton.exists)
        addButton.tap()
        
        // Sačekaj da se pojavi PhotosPicker
        let photosPicker = app.sheets["PhotosPicker"]
        XCTAssertTrue(photosPicker.waitForExistence(timeout: 2))
        
        // Izaberi prvu sliku
        let firstImage = app.images.element(boundBy: 0)
        if firstImage.exists {
            firstImage.tap()
            
            // Sačekaj da se slika pojavi u grid-u
            let gridImage = app.images.element(boundBy: 0)
            XCTAssertTrue(gridImage.waitForExistence(timeout: 2))
        }
    }
    
    func testDeleteImage() throws {
        // Prvo dodaj sliku
        try testAddImage()
        
        // Pronađi dugme za brisanje na prvoj slici
        let deleteButton = app.buttons["Delete"].firstMatch
        XCTAssertTrue(deleteButton.exists)
        deleteButton.tap()
        
        // Proveri da li je slika obrisana
        let gridImage = app.images.element(boundBy: 0)
        XCTAssertFalse(gridImage.exists)
    }
    
    func testMoveImage() throws {
        // Dodaj dve slike
        try testAddImage()
        try testAddImage()
        
        // Pronađi prvu sliku i pomeri je
        let firstImage = app.images.element(boundBy: 0)
        XCTAssertTrue(firstImage.exists)
        
        // Simuliraj drag and drop
        firstImage.press(forDuration: 0.5, thenDragTo: app.images.element(boundBy: 1))
    }
    
    func testDeleteAllImages() throws {
        // Dodaj nekoliko slika
        try testAddImage()
        try testAddImage()
        try testAddImage()
        
        // Pronađi i tapni dugme za brisanje svih slika
        let deleteAllButton = app.buttons["Delete All"]
        XCTAssertTrue(deleteAllButton.exists)
        deleteAllButton.tap()
        
        // Proveri da li su sve slike obrisane
        let gridImage = app.images.element(boundBy: 0)
        XCTAssertFalse(gridImage.exists)
    }
    
    func testResponsiveLayout() throws {
        // Dodaj nekoliko slika
        try testAddImage()
        try testAddImage()
        try testAddImage()
        try testAddImage()
        
        // Proveri da li su slike vidljive i pravilno raspoređene
        let grid = app.scrollViews["ImageGrid"]
        XCTAssertTrue(grid.exists)
        
        // Proveri da li su sve slike vidljive
        for i in 0...3 {
            let image = app.images.element(boundBy: i)
            XCTAssertTrue(image.exists)
        }
    }
    
    func testMultipleImageOperations() throws {
        // Dodaj 5 slika
        for _ in 0...4 {
            try testAddImage()
        }
        
        // Proveri da li su sve slike dodate
        XCTAssertEqual(app.images.count, 5)
        
        // Pomeri prvu sliku na kraj
        let firstImage = app.images.element(boundBy: 0)
        let lastImage = app.images.element(boundBy: 4)
        firstImage.press(forDuration: 0.5, thenDragTo: lastImage)
        
        // Obriši srednju sliku
        let middleImage = app.images.element(boundBy: 2)
        let deleteButton = middleImage.buttons["Delete"].firstMatch
        deleteButton.tap()
        
        // Proveri da li je slika obrisana
        XCTAssertEqual(app.images.count, 4)
    }
    
    func testDeleteAllButtonVisibility() throws {
        // Proveri da li je dugme za brisanje svih slika nevidljivo kada nema slika
        let deleteAllButton = app.buttons["Delete All"]
        XCTAssertFalse(deleteAllButton.exists)
        
        // Dodaj sliku
        try testAddImage()
        
        // Proveri da li je dugme sada vidljivo
        XCTAssertTrue(deleteAllButton.exists)
    }
    
    func testImageAccessibility() throws {
        // Dodaj sliku
        try testAddImage()
        
        // Proveri accessibility label i hint
        let image = app.images.element(boundBy: 0)
        XCTAssertTrue(image.exists)
        XCTAssertEqual(image.label, "Image")
        
        // Proveri da li je dugme za brisanje dostupno
        let deleteButton = image.buttons["Delete"].firstMatch
        XCTAssertTrue(deleteButton.exists)
    }
} 