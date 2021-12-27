#ifndef PYQdelegate_h
#define PYQdelegate_h

#import <DLPhotoPicker/DLPhotoPicker.h>

@protocol PYQdelegate

- (void) sendPYQWithUserID: (NSString*) userid
                 AvatarUrl: (NSString*) avatarUrl
                   Article: (NSString*) article
                    Photos: (NSMutableArray*) photos;

- (void) addNewToMyPageWithUserID: (NSString*) userid
                        AvatarUrl: (NSString*) avatarUrl
                          Article: (NSString*) article
                           Photos: (NSMutableArray*) photos;
- (NSString*) getUserid;

- (void) setCOMMENTPOPwithCellID: (NSString*) cellID;
- (void) openPersonalDataVC: (UIViewController*) vc;
- (void) openPicker: (id) picker;
- (void) closePicker: (id) picker;

@end

#endif /* PYQdelegate_h */
