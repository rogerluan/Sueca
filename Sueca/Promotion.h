//
//  Promotion.h
//  Sueca
//
//  Created by Roger Luan on 7/8/16.
//  Copyright © 2016 Roger Luan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CloudKit/CloudKit.h>

@interface Promotion : CKRecord

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;
@property (strong, nonatomic) NSString *identifier;
@property (strong, nonatomic) NSString *prize;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *shortDescription;
@property (strong, nonatomic) NSString *fullDescription;
@property (strong, nonatomic) UILocalNotification *notification;

+ (instancetype)promotionWithRecord:(CKRecord *)record;

@end
