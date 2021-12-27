//
//  EMSearchBar.h
//  SimpleChat
//
//  Created by qtdmz on 2019/1/16.
//  Copyright © 2019 qtdmz. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol EMSearchBarDelegate;
@interface EMSearchBar : UIView

@property (nonatomic, weak) id<EMSearchBarDelegate> delegate;

@property (nonatomic, strong) UITextField *textField;

@end

@protocol EMSearchBarDelegate <NSObject>

@optional

- (void)searchBarShouldBeginEditing:(EMSearchBar *)searchBar;

- (void)searchBarCancelButtonAction:(EMSearchBar *)searchBar;

- (void)searchBarSearchButtonClicked:(NSString *)aString;

- (void)searchTextDidChangeWithString:(NSString *)aString;

@end

NS_ASSUME_NONNULL_END
