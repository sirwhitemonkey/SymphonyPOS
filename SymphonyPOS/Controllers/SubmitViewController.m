

#import "SubmitViewController.h"

@interface SubmitViewController ()
@property (nonatomic,strong) APIManager *apiManager;
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@property (nonatomic,assign) BOOL offline;
@property (nonatomic,strong) NSString *paymentType;
@property (nonatomic,strong) NSString *invoice_no;
@property (nonatomic,strong) UIBarButtonItem *printBtn;
@property (nonatomic,strong) UIBarButtonItem *homeBtn;
@end

@implementation SubmitViewController
@synthesize apiManager = _apiManager;
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;
@synthesize offline = _offline;
@synthesize paymentType = _paymentType;
@synthesize invoice_no = _invoice_no;
@synthesize printBtn = _printBtn;
@synthesize homeBtn = _homeBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    _globalStore = [persistenceManager getGlobalStore];
    
    _apiManager = [[APIManager alloc]init];
    
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self.view setBackgroundColor:[sharedServices colorFromHexString:
                                   [_themes objectForKey:@"background"]]];
    [self.submitBtn setBackgroundColor:[sharedServices colorFromHexString:[_themes objectForKey:@"button_submit"]]];
    _offline = persistenceManager.offline;
    
    _paymentType = [persistenceManager getDataStore:PAYMENT_TYPE];
    self.navigationItem.title = @"Payment Confirmation";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    // Dispose of any resources that can be recreated.
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

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


#pragma mark - IBActions
- (IBAction)submit:(id)sender {
    _apiManager.delegate = self;
    [_apiManager checkConnection:self];
}


#pragma mark - APIManager
- (void) apiRequestError:(NSError *)error {
    DebugLog(@"apiRequestError -> %@", error);
    
    UIActionSheet *action;
    
    if (_offline) {
        action = [[UIActionSheet alloc] initWithTitle:@"OFFLINE Payment: Continue ?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Confirm" otherButtonTitles:nil,
                  nil];
        action.tag = 2;
        [action showInView:[UIApplication sharedApplication].keyWindow];
        
    } else {
        if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
            action = [[UIActionSheet alloc] initWithTitle:@"OFFLINE: Change your payment type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Change" otherButtonTitles:nil,
                      nil];
            action.tag = 1;
            [action showInView:[UIApplication sharedApplication].keyWindow];
        }
    }
}

- (void) apiCheckConnnectionResponse:(Response *)response {
    [self submitTransaction:NO];
}

- (void) apiSubmitPaymentResponse:(Response *)response {
    if (!response.error) {
        [self finaliseSubmission];
    }
}

#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)action clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (action.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [persistenceManager removeFromKeyChain:_paymentType]; // Credit card only
                    [self viewPaymentTypePage];
                    break;
                default:
                    break;
            }
            break;
        }
        case 2: {
            switch (buttonIndex) {
                case 0:
                    [self submitTransaction:YES];
                    break;
                default:
                    break;
            }
            break;
        }
            
        default:
            break;
    }
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
 * SubmitViewController checking the connection
 */
- (void) checkConnection {
    _apiManager.delegate = self;
    [_apiManager checkConnection:self];
}

- (void) willEnterForegroundNotification {
    [sharedServices showPinView:self];
}

/*!
 * SubmitViewController submitting the transaction (i.e offline/online)
 */
- (void) submitTransaction: (BOOL) offline{
    NSString *last_order_number = [NSString stringWithFormat:@"%ld",[_globalStore.last_order_number integerValue] + 1];
    long prefix_number_length = [_globalStore.prefix_number_length integerValue];
    
    NSMutableArray *invoice=[NSMutableArray array];
    [invoice addObject:_globalStore.prefix];
    for (int invIdx=0;invIdx < (prefix_number_length-[last_order_number length]);invIdx++) {
        [invoice addObject:@"0"];
    }
    [invoice addObject:last_order_number];
    [invoice addObject:[NSString stringWithFormat:@"-%@",_globalStore.terminal_code]];
    
    _invoice_no = [invoice componentsJoinedByString:@""];
    
    if (offline) {
        [persistenceManager setOfflineSalesStore:_invoice_no];
        [self finaliseSubmission];
    } else {
        _apiManager.delegate = self;
        [_apiManager submitPayment:self invoice_no:_invoice_no];
    }
}

/*!
 * SubmitViewController navigate to payment type page
 */
- (void)viewPaymentTypePage {
    [self.navigationController popViewControllerAnimated:NO];
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:[self.navigationController viewControllers]];
    for (UIViewController *controller in controllers) {
        if ([controller isKindOfClass:[PaymentViewController class]]) {
            [self.navigationController popToViewController:controller animated:NO];
        }
        if ([controller isKindOfClass:[PaymentCustomerViewController class]]) {
            [self.navigationController popToViewController:controller animated:NO];
        }
        
    }
}

/*!
 * SubmitViewController navigate to quick order page
 */
- (void) viewQuickOrderPage {
    [self performSegueWithIdentifier:@"SubmitPOSSegue" sender:self];
}

/*!
 * SubmitViewController navigate to print page
 */
- (void) viewPrintPage {
    [self performSegueWithIdentifier:@"PrintSegue" sender:self];
}

/*!
 * SubmitViewController finalising the payment submission
 */
- (void) finaliseSubmission {
    NSMutableArray *carts = [NSMutableArray array];
    NSArray *cartStores = [persistenceManager getCartStores];
    for (CartStore *cartStore in cartStores) {
        NSDictionary *cart = [[NSDictionary alloc] initWithObjectsAndKeys:cartStore.cart_code,@"cart_code",
        cartStore.cartProduct.product_code,@"product_code",cartStore.qty, @"qty", nil];
        [carts addObject:cart];
    }
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:
                          _invoice_no, @"invoiceNo",
                          _globalStore.customer_default_code,@"customer_code",
                          [persistenceManager getDataStore:CUSTOMER],@"customer",
                          [persistenceManager getDataStore:CASH_SALES], @"cashSales",
                          [persistenceManager getDataStore:PAYMENT_TYPE], @"paymentType",
                          carts, @"carts",nil];
    
    _globalStore.last_order_number = [NSNumber numberWithLong:[_globalStore.last_order_number integerValue]+1];
    [persistenceManager saveContext];
    
    self.navigationItem.hidesBackButton = YES;
    self.submitBtn.enabled = NO;
    [self.submitBtn setBackgroundColor:[UIColor lightGrayColor]];
    [persistenceManager clearCurrentEvent];
    self.navigationItem.title = @"Payment Received";
    [sharedServices showMessage:self message:@"Payment received successfully" error:NO withCallBack:nil];
    [persistenceManager setDataStore:@"printCopy" value:data];
    
    _printBtn =[[UIBarButtonItem alloc]  initWithTitle:@"Print" style:UIBarButtonItemStylePlain
                                                target:self action:@selector(print:)];
    
    _homeBtn =[[UIBarButtonItem alloc]  initWithTitle:@"Quick Order" style:UIBarButtonItemStylePlain
                                               target:self action:@selector(home:)];

    self.navigationItem.leftBarButtonItem = _homeBtn;
    self.navigationItem.rightBarButtonItem = _printBtn;
}

- (void)home:(id)sender {
    [self viewQuickOrderPage];
}

- (void)print:(id)sender{
    self.navigationItem.title = @"Payment Received";
    [self viewPrintPage];
}


@end
