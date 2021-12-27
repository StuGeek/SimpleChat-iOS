//
//  UserDataModel.m
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "UserDataModel.h"

@implementation UserDataModel

- (instancetype)initWithEaseId:(NSString *)easeId
{
    if (self = [super init]) {
        _easeId = easeId;
        _defaultAvatar = [UIImage imageNamed:@"defaultAvatar"];
    }
    return self;
}

@end
