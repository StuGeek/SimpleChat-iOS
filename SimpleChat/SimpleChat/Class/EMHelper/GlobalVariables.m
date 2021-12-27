//
//  GlobalVariables.m
//  SimpleChat
//
//  Created by qtdmz on 2018/12/19.
//  Copyright © 2018 qtdmz. All rights reserved.
//

#import "GlobalVariables.h"

BOOL gIsInitializedSDK = NO;

BOOL gIsCalling = NO;

BOOL gIsConferenceCalling = NO;

static GlobalVariables *shared = nil;
@implementation GlobalVariables

+ (instancetype)shareGlobal
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[GlobalVariables alloc] init];
    });
    
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    
    return self;
}

@end
