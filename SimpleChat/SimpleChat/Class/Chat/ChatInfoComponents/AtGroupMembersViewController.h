//
//  AtGroupMembersViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/2.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "EMSearchViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface AtGroupMembersViewController : EMSearchViewController

@property (nonatomic, copy) void (^selectedCompletion)(NSString *aName);

- (instancetype)initWithGroup:(EMGroup *)aGroup;

@end

NS_ASSUME_NONNULL_END
