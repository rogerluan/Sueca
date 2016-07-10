//
//  ErrorManager.h
//  Patient
//
//  Created by Roger Oba on 10/24/15.
//  Copyright © 2015 GoDoctor. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SuecaErrorIdentifier) {
    SuecaErrorNoValidPromotionsFound = 1001,
	SuecaErrorFailedToEmail = 1002,
	SuecaErrorInvalidURL = 1003
};

@interface ErrorManager : NSObject

+ (NSError *)errorForErrorIdentifier:(NSInteger)errorIdentifier;
+ (UIAlertController *)alertFromError:(NSError *)error;
+ (UIAlertController *)alertFromErrorIdentifier:(NSInteger)errorIdentifier;

@end
