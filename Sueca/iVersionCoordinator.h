//
//  iVersionCoordinator.h
//  Sueca
//
//  Created by Roger Luan on 6/30/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "iVersion.h"

@interface iVersionCoordinator : NSObject <iVersionDelegate>

- (void)openAppPageInAppStore;

@end
