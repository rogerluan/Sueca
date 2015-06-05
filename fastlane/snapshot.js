#import "SnapshotHelper.js"

var target = UIATarget.localTarget();

target.frontMostApp().mainWindow().buttons()["Draw"].tapWithOptions({tapCount:12});
target.delay(1)
captureLocalizedScreenshot("01MainGame")

target.frontMostApp().tabBar().buttons()["Rules"].tap();
target.delay(1)
target.tap({x: 350.00, y: 90.00});
target.delay(0.5)
captureLocalizedScreenshot("02DefaultRules")

target.frontMostApp().navigationBar().leftButton().tap();
target.frontMostApp().navigationBar().rightButton().tap();
target.delay(0.5)
captureLocalizedScreenshot("03CustomRules")
