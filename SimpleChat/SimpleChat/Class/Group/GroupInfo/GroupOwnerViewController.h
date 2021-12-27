//
//  GroupOwnerViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "EMSearchViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupOwnerViewController : EMSearchViewController

@property (nonatomic, copy) void (^successCompletion)(EMGroup *aGroup);

- (instancetype)initWithGroup:(EMGroup *)aGroup;

@end

NS_ASSUME_NONNULL_END
