#import "SnapshotHelper.js"

var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().buttons()["Ziehen"].tapWithOptions({tapCount:12});
target.delay(1)
captureLocalizedScreenshot("01MainGame")

target.frontMostApp().tabBar().buttons()["Decks"].tap();
target.delay(2)
target.tap({x: 350.00, y: 90.00});
target.delay(2)
target.tap({x: 350.00, y: 90.00});
target.delay(1)
captureLocalizedScreenshot("02DefaultRules")

target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().rightButton().tap();
target.delay(1)
target.frontMostApp().alert().buttons()["Erstellen"].tap();
target.delay(1)
captureLocalizedScreenshot("03CustomRules")
