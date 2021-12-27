//
//  EMTextView.h
//  SimpleChat
//
//  Created by qtdmz on 2019/1/16.
//  Copyright © 2019 qtdmz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EMTextView : UITextView
{
    UIColor *_contentColor;
    BOOL _editing;
}

@property(strong, nonatomic) NSString *placeholder;
@property(strong, nonatomic) UIColor *placeholderColor;

@end
