//
//  InviteGroupMemberViewController.h
//  SimpleChat
//
//  Created by stugeek on 2021/12/3.
//  Copyright © 2021 stugeek. All rights reserved.
//

#import "EMSearchViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface InviteGroupMemberViewController : EMSearchViewController

@property (nonatomic, copy) void (^doneCompletion)(NSArray *aSelectedArray);

- (instancetype)initWithBlocks:(NSArray *)aBlocks;

@end

NS_ASSUME_NONNULL_END
