

#import <UIKit/UIKit.h>
#import "APIManager.h"


@protocol SyncViewControllerDelegate;

@interface SyncViewController : UIViewController <APIManagerDelegate>
@property (nonatomic,weak) id<SyncViewControllerDelegate>delegate;
@property BOOL settings;

- (void) sync;

@end



@protocol SyncViewControllerDelegate

@required
- (void)syncDidCompleted:(SyncViewController*)controller;
- (void)syncDidError:(SyncViewController*)controller;

@end