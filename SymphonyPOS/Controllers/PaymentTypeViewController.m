
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
    // Default payment type
    [persistenceManager setDataStore:PAYMENT_TYPE value:PAYMENT_CREDITCARD];
    
    _globalStore = [persistenceManager getGlobalStore];
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [self.view setBackgroundColor:[sharedServices colorFromHexString:[_themes objectForKey:@"background"]]];
    [self.paymentTypeBtn setBackgroundColor:[sharedServices colorFromHexString:[_themes objectForKey:@"button_submit"]]];
    NSString *title = @"Payment Type";
    if (![_globalStore.customer_default_code isEqualToString:_globalStore.customer_default_code_copy]) {
        title = [NSString stringWithFormat:@"%@ (%@)",title,@"Account mode"];
    }
    self.navigationItem.title = title;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


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
    if (persistenceManager.offline) {
        if ([[persistenceManager getDataStore:PAYMENT_TYPE] isEqualToString:PAYMENT_CREDITCARD]) {
            [self checkConnection];
        } else {
            [self viewPaymentPage];
        }
        
    } else {
        [self checkConnection];
    }
}


#pragma mark - APIMAnager
- (void)apiRequestError:(NSError *)error {
    DebugLog(@"apiRequestError -> %@", error);
    self.offlineMessage.hidden = NO;
    [persistenceManager setDataStore:PAYMENT_TYPE value:nil];
}

- (void) apiCheckConnnectionResponse:(Response *)response {
    DebugLog(@"apiCheckConnnectionResponse");
    [self viewPaymentPage];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private methods
/*!
 * PaymentTypeViewController checking the connection
 */
- (void) checkConnection {
    _apiManager.delegate = self;
    [_apiManager checkConnection:self];
}

- (void) willEnterForegroundNotification {
    [sharedServices showPinView:self];
}

/*!
 * PaymentTypeViewController navigate to payment page
 */
- (void)viewPaymentPage {
    [self performSegueWithIdentifier:@"PaymentSegue" sender:self];
}

@end
