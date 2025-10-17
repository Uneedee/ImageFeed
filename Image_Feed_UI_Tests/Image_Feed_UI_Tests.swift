@testable import ImageFeed
import XCTest

final class Image_FeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["--uitesting"]
        app.launch()
    }
    
    private func acceptCookiesIfNeeded() {
        let webView = app.webViews.element(boundBy: 0)
        
        let buttonAccept = "Accept all cookies"
        
        let button = webView.buttons[buttonAccept]
        button.tap()
        
    }
    
    
    func testAuth() throws {
        

        let authButton = app.buttons["Authenticate"]
        XCTAssertTrue(authButton.waitForExistence(timeout: 5), "Кнопка не найдена на экране")


        authButton.tap()
        let webView = app.webViews["UnsplashWebView"]
        
        XCTAssertTrue(webView.waitForExistence(timeout: 5), "WebView не появился")
        
        let loginTextField = webView.textFields.element(boundBy: 0)
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поле логина не найдено")
        
        UIPasteboard.general.string = "Почта"
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
        
        UIPasteboard.general.string = "Пароль"
        passwordTextField.tap()
        passwordTextField.press(forDuration: 1.0)
        if app.menuItems["Paste"].waitForExistence(timeout: 2) {
            app.menuItems["Paste"].tap()
        } else {
            XCTFail("Не удалось вставить пароль")
        }
        
        webView.swipeUp()
        
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 10), "Поле логина не найдено")
        let loginButton = webView.buttons["Login"]
                if loginButton.waitForExistence(timeout: 5) {
                    loginButton.tap()
                } else {
                    XCTFail("Кнопка Login не найдена")
                }
        let tablesQuery = app.tables
                let firstCell = tablesQuery.cells.element(boundBy: 0)
                XCTAssertTrue(firstCell.waitForExistence(timeout: 10), "Не загрузилась лента после логина")
        
    }
    
    
    func testFeed() throws {
        
        // Тут нужны более длительные паузы на загрузку, секунд по 7
        
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()
        
        sleep(7)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like button off"].tap()
        cellToLike.buttons["like button on"].tap()
        
        sleep(7)
        
        cellToLike.tap()
        
        sleep(20)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        sleep(7)
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(7)
        
        // Поменяй имя и юзернейм
        XCTAssertTrue(app.staticTexts["Alexey Ratushnyak"].exists)
        XCTAssertTrue(app.staticTexts["@synsina"].exists)
        
        app.buttons["logout button"].tap()
        
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
    
}
