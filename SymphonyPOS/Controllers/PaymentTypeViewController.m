
#import "PaymentTypeViewController.h"

@interface PaymentTypeViewController ()
@property (nonatomic,strong) APIManager *apiManager;
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@end

@implementation PaymentTypeViewController
@synthesize apiManager = _apiManager;
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    
     _apiManager = [[APIManager alloc]init];
    _apiManager.delegate = self;
    
    // Default payment type
    [persistenceManager setDataStore:PAYMENT_TYPE value:PAYMENT_CREDITCARD];
    
    _globalStore = [persistenceManager getGlobalStore];
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [self.view setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    [self.paymentTypeBtn setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"button_submit"]]];
    NSString *title = @"Payment Type";
    if (![_globalStore.customer_default_code isEqualToString:_globalStore.customer_default_code_copy]) {
        title = [NSString stringWithFormat:@"%@ (%@)",title,@"Account mode"];
    }
    self.navigationItem.title = title;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerNotifications];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - Notifications

- (void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - IBActions
- (IBAction)paymentTypeAction:(id)sender {
    UIButton *btn = (RadioButton*)sender;
    NSString *paymentType;
    switch (btn.tag) {
        case 0:
            paymentType = PAYMENT_CREDITCARD;
            break;
        case 1:
            paymentType = PAYMENT_EFTPOS;
            break;
        case 2:
            paymentType = PAYMENT_CASH;
            break;
        default:
            break;
    }
    [persistenceManager removeFromKeyChain:PAYMENT_CREDITCARD];
    [persistenceManager setDataStore:PAYMENT_TYPE value:paymentType];
}

- (IBAction)next:(id)sender {
    self.offlineMessage.hidden = YES;
    self.navigationItem.title = @"Payment Type";
    if ([[persistenceManager getDataStore:PAYMENT_TYPE] isEqualToString:PAYMENT_CREDITCARD]) {
        [self checkConnection];
    } else {
        [self viewPaymentPage];
    }
}


#pragma mark - APIMAnager
- (void)apiRequestError:(NSError *)error response:(Response *)response {
    DebugLog(@"apiRequestError -> %@,%@", error,response);
    [service hideMessage:^ {
        self.offlineMessage.hidden = NO;
        [persistenceManager setDataStore:PAYMENT_TYPE value:nil];
    }];
}

- (void) apiCheckConnnectionResponse:(Response *)response {
    DebugLog(@"apiCheckConnnectionResponse");
    [service hideMessage: ^ {
        [self viewPaymentPage];
    }];
}


#pragma mark - Private methods
/*!
 * PaymentTypeViewController checking the connection
 */
- (void) checkConnection {
    [service showMessage:self loader:YES message:@"Checking server communication ..." error:NO waitUntilCompleted:YES withCallBack: ^ {
        AFHTTPRequestOperation *checkConnection = [_apiManager checkConnection];
        if (checkConnection) {
            [checkConnection start];
        }
    }];
}

- (void) willEnterForegroundNotification {
    [service showPinView:self];
}

/*!
 * PaymentTypeViewController navigate to payment page
 */
- (void)viewPaymentPage {
    [self performSegueWithIdentifier:@"PaymentSegue" sender:self];
}

@end
