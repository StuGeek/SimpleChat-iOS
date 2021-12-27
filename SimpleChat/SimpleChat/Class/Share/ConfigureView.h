#ifndef ConfigureView_h
#define ConfigureView_h

#import <UIKit/UIKit.h>
#import "PYQdelegate.h"
#import "UserInfoStore.h"

@interface ConfigureView : UIView <UIImagePickerControllerDelegate,UINavigationControllerDelegate> {
    id <PYQdelegate> PYQdelegate;
    id <UIImagePickerControllerDelegate> delegate;
}

@property(nonatomic, retain) id <PYQdelegate> PYQdelegate;

- (id) initWithDelegate: (id) delegate;

@end

#endif /* ConfigureView_h */
