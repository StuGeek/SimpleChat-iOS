//
//  SingleCallController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/1.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SingleCallController : NSObject

@property (nonatomic, strong) NSString *chatter; //通话的联系人

@property (nonatomic,strong) NSString *callDirection; //通话角色，主/被叫

@property (nonatomic,strong) NSString *callDurationTime; //通话持续时间

+ (instancetype)sharedManager;

@end

