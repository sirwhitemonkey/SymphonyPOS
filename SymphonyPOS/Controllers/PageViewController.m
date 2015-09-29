

#import "PageViewController.h"

@interface PageViewController ()
@property (nonatomic,strong) APIManager *apiManager;
@property (nonatomic,strong) SyncService *syncService;
@property (nonatomic,strong) GlobalStore *globalStore;
@end

@implementation PageViewController
@synthesize apiManager = _apiManager;
@synthesize syncService = _syncService;
@synthesize globalStore = _globalStore;

- (void)viewDidLoad {
    
    [super viewDidLoad];
    DebugLog(@"viewDidLoad");
    self.navigationController.navigationBarHidden = YES;
    
    _apiManager = [[APIManager alloc] init];
    _apiManager.delegate = self;
    
    _syncService = [SyncService sharedInstance];
    
    // Sync every 30 minutes
    [_syncService startTimerForSender:self withTimeInterval:60*30];
    
    [self registerNotifications];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIViewController *controller = nil;
    NSString *appUserIdent = [persistenceManager getKeyChain:USER_LOGGED_IDENT];
    NSString *appPin = [persistenceManager getKeyChain:USER_PIN_IDENT];
  
    _globalStore = [persistenceManager getGlobalStore];
    if (_globalStore.my_custom_url!= nil) {
        
        if (_globalStore.themes) {
            NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            [[UINavigationBar appearance] setBarTintColor:[service colorFromHexString:[themes objectForKey:@"navigation_bar"]]];
            [[UINavigationBar appearance] setBarStyle:UIBarStyleBlackTranslucent];
            
            [[UINavigationBar appearance] setTitleTextAttributes:
             [NSDictionary dictionaryWithObjectsAndKeys:
              [service colorFromHexString:[themes objectForKey:@"navigation_bar_title"]] , NSForegroundColorAttributeName,nil]];
        }
        
        if ( ![service isEmptyString:appUserIdent]) {
         
            if ([service isEmptyString:appPin]) {
                // Show terminal page
                [self viewTerminalPage];
                
            } else {
                
                if ([persistenceManager getDataStore:PIN_LOGGED_IDENT] == nil) {
                    // Show PinView page
                    controller = [persistenceManager getView:@"PinViewController"];
                    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                    [self presentViewController:controller animated:YES completion:nil];
                } else {
                    // Show POS page
                    [self viewPOSPage];
                }
            }
        } else {
            [persistenceManager clearCache];
            // Show login page
            controller = [persistenceManager getView:@"LoginViewController"];
            controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [controller setModalPresentationStyle:UIModalPresentationFullScreen];
            [self presentViewController:controller animated:YES completion:nil];
        }
        
    } else {
        [persistenceManager clearCache];
        // Show login page
        controller = [persistenceManager getView:@"LoginViewController"];
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [controller setModalPresentationStyle:UIModalPresentationFullScreen];
        [self presentViewController:controller animated:YES completion:nil];
    }
}

- (BOOL)shouldAutorotate{
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#endif


#pragma mark - APIManager
- (void)apiRequestError:(NSError *)error response:(Response *)response {
    DebugLog(@"apiRequestError -> %@,%@", error,response);
    if (!_apiManager.batchOperation) {
        [service hideMessage:nil];
    }
}


- (void) apiOfflineSalesResponse:(Response *)response {
   [persistenceManager removeOfflineSalesStore];
    [service hideMessage:nil];
}


#pragma mark - SyncViewControllerDelegate
- (void)syncDidCompleted:(SyncViewController *)controller {
    DebugLog(@"syncDidCompleted");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)syncDidError:(SyncViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SyncService

- (void)startTimerAction:(id)userInfo {
    
    if (self.presentedViewController) {
        return ;
    }
    // Check if pin/user already logged, if not disable sync
    if ([persistenceManager getKeyChain:USER_LOGGED_IDENT] == nil ||
        [persistenceManager getKeyChain:USER_PIN_IDENT] == nil) {
        return;
    }
   
    // Sync
    double date_last_sync_interval = [[persistenceManager getKeyChain:SYNC_DATE_LAST_UPDATED] doubleValue]/1000;
    NSDate * date_last_sync = [NSDate  dateWithTimeIntervalSince1970:date_last_sync_interval];
    NSTimeInterval date_current_sync = [[NSDate date] timeIntervalSinceDate:date_last_sync];
    
    int days = date_current_sync / (60 * 60 * 24);
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    long days_sync_interval = [[settings objectForKey:@"days_sync_interval"] integerValue];
    if (days_sync_interval < days) {
        [self viewSyncPage];
    }
    
    // Sync offline
    NSArray *offlineSalesStores = [persistenceManager getOfflineSalesStore];
    if (offlineSalesStores.count > 0) {
        [service showMessage:self loader:YES message:@"Synchronising offline sales ..." error:NO
          waitUntilCompleted:YES withCallBack:^ {
              _apiManager.batchOperation = false;
              [_apiManager offlineSales:self];
          }];
    }
}




#pragma  mark - Private methods
/*!
 * PageViewController registering the notifications
 */
- (void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackgroundNotification)
                                                 name:UIApplicationDidEnterBackgroundNotification object:nil];

}

- (void) willEnterForegroundNotification {
     // Sync every 5 minutes
    [_syncService startTimerForSender:self withTimeInterval:60*5];

}

- (void) didEnterBackgroundNotification {
    [_syncService stopTimer];
}

/*!
 * PageViewController navigate to pos page
 */
- (void) viewPOSPage {
    [self performSegueWithIdentifier:@"POSSegue" sender:self];
}

/*!
 * PageViewController navigate to terminal page
 */
- (void) viewTerminalPage {
    [self performSegueWithIdentifier:@"TerminalSegue" sender:self];
}

/*!
 * PageViewController navigate to sync page
 */
- (void) viewSyncPage {
    SyncViewController *controller = (SyncViewController*)[persistenceManager getView:@"SyncViewController"];
    controller.delegate = self;
    controller.settings = YES;
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:controller animated:NO completion: ^ {
        [controller sync];
    }];
}


@end
