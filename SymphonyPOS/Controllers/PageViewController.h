

#import <UIKit/UIKit.h>
#import "globalStore.h"
#import "APIManager.h"
#import "SyncService.h"
#import "OfflineSalesStore.h"

@interface PageViewController : UIViewController<SyncServiceDelegate,APIManagerDelegate>

@end
