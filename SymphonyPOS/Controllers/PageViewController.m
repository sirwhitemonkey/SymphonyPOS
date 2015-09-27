

#import "PageViewController.h"

@interface PageViewController ()
@property (nonatomic,strong) SyncService *syncService;
@property (nonatomic,strong) GlobalStore *globalStore;
@end

@implementation PageViewController
@synthesize syncService = _syncService;
@synthesize globalStore = _globalStore;

- (void)viewDidLoad {
    [super viewDidLoad];
    DebugLog(@"viewDidLoad");
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    
    _syncService = [SyncService sharedInstance];
    
    // Sync every 5 minutes
    [_syncService startTimerForSender:self withTimeInterval:60*5];
    
    [self registerNotifications];
    
    // Testing only
    [persistenceManager setMyCustomPreference:API_URL logo:CUSTOM_CLIENT_LOGO];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    UIViewController *controller = nil;
    NSString *appUserIdent = [persistenceManager getKeyChain:APP_LOGGED_IDENT];
    NSString *appPin = [persistenceManager getKeyChain:APP_USER_PIN_IDENT];
  
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
        
        if ( ![service isEmptyString:appUserIdent] && ![service isEmptyString:appPin]) {
            // Filter app logged identifier
            if ([persistenceManager getDataStore:APP_LOGGED_IDENT] !=nil ) {
                [self viewPOSPage];
                
            } else {
                if ([service isEmptyString:appPin]) {
                    // Show terminal page
                    [self viewTerminalPage];
                } else {
                    // Show pin page
                    controller = [persistenceManager getView:@"PinViewController"];
                    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                    [self presentViewController:controller animated:YES completion:nil];
                }
            }
        } else {
            if ([service isEmptyString:appUserIdent] && [service isEmptyString:appPin]) {
                // Show login page
                controller = [persistenceManager getView:@"LoginViewController"];
                controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [controller setModalPresentationStyle:UIModalPresentationFullScreen];
                [self presentViewController:controller animated:YES completion:nil];
            } else {
                // Show terminal page
                [self viewTerminalPage];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - APIManager
- (void)apiRequestError:(NSError *)error {
    DebugLog(@"apiRequestError: %@", error);
    
}

- (void) apiSyncResponse:(Response *)response {
    DebugLog(@"apiSyncResponse");
    /*
    if (!response.error) {
        [persistenceManager updateSync:self response:response];
    }*/
    
}

- (void) apiOfflineSalesResponse:(Response *)response {
    DebugLog(@"apiOfflineSalesResponse");
    /*
    if (!response.error) {
        [persistenceManager removeOfflineSalesStore];
    }*/
}

- (void)apiProductsResponse:(Response *)response {
    
    DebugLog(@"apiProductsResponse");
    /*
    if (!response.error) {
    }
     */
}

#pragma mark - SyncService

- (void)startTimerAction:(id)userInfo {
    APIManager *apiManager;
    
    if (self.presentedViewController) {
        return ;
    }
    if ([persistenceManager getKeyChain:APP_USER_IDENT] == nil ||
        [persistenceManager getKeyChain:APP_USER_PIN_IDENT] == nil) {
        return;
    }
   
    /*
    apiManager = [[APIManager alloc]init];
    apiManager.delegate =self;
    [apiManager getProducts:self page:11 limit:2000];
     */
  
    // Sync
    double date_last_sync_interval = [[persistenceManager getKeyChain:SYNC_DATE_LAST_UPDATED] doubleValue]/1000;
    NSDate * date_last_sync = [NSDate  dateWithTimeIntervalSince1970:date_last_sync_interval];
    NSTimeInterval date_current_sync = [[NSDate date] timeIntervalSinceDate:date_last_sync];
    
    int days = date_current_sync / (60 * 60 * 24);
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    long days_sync_interval = [[settings objectForKey:@"days_sync_interval"] integerValue];
    if (days_sync_interval < days) {
        apiManager = [[APIManager alloc]init];
        apiManager.delegate = self;
        [apiManager sync:self];
    }
    
    // Sync offline
    NSArray *offlineSalesStores = [persistenceManager getOfflineSalesStore];
    if (offlineSalesStores.count > 0) {
        apiManager = [[APIManager alloc]init];
        apiManager.delegate = self;
        [apiManager offlineSales:self];
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
 * PageViewController navigate to quick order page
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


@end
