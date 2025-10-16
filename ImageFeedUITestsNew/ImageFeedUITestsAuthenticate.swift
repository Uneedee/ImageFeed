import XCTest

final class Image_FeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    func testAuth() throws {

        print("Все доступные кнопки:", app.buttons.allElementsBoundByIndex.map { "\($0.identifier) | \($0.label)" })
        print("Все элементы на экране:", app.descendants(matching: .any).allElementsBoundByIndex.map { "\($0.identifier) | \($0.label)" })

        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка не найдена на экране")


        authButton.tap()
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не появился")
        
        let loginTextField = webView.textFields.element(boundBy: 0)
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поле логина не найдено")
        
        UIPasteboard.general.string = "aratusha2602@gmail.com"
        loginTextField.tap()
        loginTextField.press(forDuration: 1.0)
        if app.menuItems["Paste"].waitForExistence(timeout: 2) {
             app.menuItems["Paste"].tap()
         } else {
             XCTFail("Не удалось вставить логин (Paste)")
         }
        
        webView.swipeUp()
        
        let passwordTextField = webView.secureTextFields.element(boundBy: 0)
        XCTAssert(passwordTextField.waitForExistence(timeout: 10), "Поле пароль не найдено")
        
        UIPasteboard.general.string = "electronic123A"
        passwordTextField.tap()
        passwordTextField.press(forDuration: 1.0)
        if app.menuItems["Paste"].waitForExistence(timeout: 2) {
            app.menuItems["Paste"].tap()
        } else {
            XCTFail("Не удалось вставить пароль")
        }
        
        webView.swipeUp()
        
        let loginButton = webView.buttons["Login"]
                if loginButton.waitForExistence(timeout: 5) {
                    loginButton.tap()
                } else {
                    XCTFail("Кнопка Login не найдена")
                }
        let tablesQuery = app.tables
                let firstCell = tablesQuery.cells.element(boundBy: 0)
                XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Не загрузилась лента после логина")
        
        
        
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поле логина не найдено")
        
        
        
        
    }
    
    
    func testFeed() throws {}
    
}
