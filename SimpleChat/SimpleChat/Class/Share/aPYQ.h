#ifndef aPYQ_h
#define aPYQ_h
#import <UIKit/UIKit.h>
#import "ScanImage.h"
#import "UserInfoStore.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "PYQdelegate.h"
#import "PersonalDataViewController.h"
#import "AccountViewController.h"
@interface aPYQ : UITableViewCell {
    id <PYQdelegate> PYQdelegate;
}

@property(nonatomic, retain) id <PYQdelegate> PYQdelegate;

- (id) initWithData: (NSDictionary*) dictionary
         Identifier: (NSString*) identifier
           Delegate: (id) delegate;

@end

#endif /* aPYQ_h */
