//
//  EMTextViewController.h
//  SimpleChat
//
//  Created by qtdmz on 2019/1/17.
//  Copyright © 2019 qtdmz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EMTextViewController : UIViewController

@property (nonatomic, copy) BOOL (^doneCompletion)(NSString *aString);

- (instancetype)initWithString:(NSString *)aString
                   placeholder:(NSString *)aPlaceholder
                    isEditable:(BOOL)aIsEditable;

@end

NS_ASSUME_NONNULL_END
