#ifndef ShareViewController_h
#define ShareViewController_h
#import <UIKit/UIKit.h>
#import "EMRefreshViewController.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "ConfigureView.h"
#import "aPYQ.h"

@interface ShareViewController : EMRefreshViewController<UITableViewDataSource, UITableViewDelegate, PYQdelegate, UIGestureRecognizerDelegate> 

-(void) refresh;

@end

#endif /* ShareViewController_h */
