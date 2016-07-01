//
//  iRateCoordinator.h
//  Sueca
//
//  Created by Roger Luan on 2/15/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iRate.h"

@interface iRateCoordinator : NSObject <iRateDelegate>

+ (void)setup;
+ (void)resetEventCount;

@end
