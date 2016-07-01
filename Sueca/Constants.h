//
//  Constants.h
//  Sueca
//
//  Created by Roger Luan on 6/30/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#ifndef Constants_h
#define Constants_h

static NSString * const MainStoryboard = @"Storyboard";
static NSString * const TabBarControllerIdentifier = @"TabBarController";
static NSString * const DecksNavigationControllerIdentifier = @"DecksNavigationController";
static NSString * const GameViewControllerIdentifier = @"GameViewController";


typedef NS_ENUM(NSUInteger, ShuffleDeckWarning) {
	ShuffleDeckWarningNeverDecided = 0,
	ShuffleDeckWarningDisplay,
	ShuffleDeckWarningSilence
};

#endif /* Constants_h */