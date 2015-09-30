

#import "SubmitViewController.h"

@interface SubmitViewController ()
@property (nonatomic,strong) APIManager *apiManager;
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@property (nonatomic,strong) NSString *paymentType;
@property (nonatomic,strong) NSString *invoice_no;
@property (nonatomic,strong) UIBarButtonItem *printBtn;
@property (nonatomic,strong) UIBarButtonItem *homeBtn;
@end

@implementation SubmitViewController
@synthesize apiManager = _apiManager;
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;
@synthesize paymentType = _paymentType;
@synthesize invoice_no = _invoice_no;
@synthesize printBtn = _printBtn;
@synthesize homeBtn = _homeBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    _globalStore = [persistenceManager getGlobalStore];
    
    _apiManager = [[APIManager alloc]init];
    _apiManager.delegate = self;
    
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self.view setBackgroundColor:[service colorFromHexString:
                                   [_themes objectForKey:@"background"]]];
    [self.submitBtn setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"button_submit"]]];
    
    _paymentType = [persistenceManager getDataStore:PAYMENT_TYPE];
    self.navigationItem.title = @"Payment Confirmation";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#endif


#pragma mark - IBActions
- (IBAction)submit:(id)sender {
    [self checkConnection];
}


#pragma mark - APIManager

- (void) apiRequestError:(NSError *)error response:(Response *)response {
    
    DebugLog(@"apiRequestError -> %@,%@", error,response);
    
    [service hideMessage:^ {
        
        [service showMessage:self loader:NO message:(NSString*)response.data error:NO waitUntilCompleted:NO
                withCallBack:^{
                    UIActionSheet *action;
                    
                    if (persistenceManager.offline) {
                        if ([_paymentType isEqualToString:PAYMENT_CREDITCARD]) {
                            action = [[UIActionSheet alloc] initWithTitle:@"OFFLINE: Change your payment type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Change" otherButtonTitles:nil,
                                      nil];
                            action.tag = 1;
                        } else {
                            action = [[UIActionSheet alloc] initWithTitle:@"OFFLINE Payment: Continue ?" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Confirm" otherButtonTitles:nil,
                                      nil];
                            action.tag = 2;
                        }
                        [action showInView:[UIApplication sharedApplication].keyWindow];
                        
                    }
                }];
    }];
    
}

- (void) apiCheckConnnectionResponse:(Response *)response {
    DebugLog(@"apiCheckConnnectionResponse");
    [service hideMessage: ^ {
        [self submitTransaction:NO];
    }];
}


- (void) apiSubmitTransactionsResponse:(Response *)response {
    DebugLog(@"apiSubmitTransactionsResponse");
    [service hideMessage: ^ {
       [self finaliseSubmission];
    }];
}

#pragma mark - UIActionSheet
- (void)actionSheet:(UIActionSheet *)action clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (action.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:
                    [persistenceManager removeDataStore:_paymentType];
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

#pragma mark - Private methods
/*!
 * SubmitViewController checking the connection
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
        
        // Formulate the params
        NSData *jsonData = nil;
        CustomerStore *customerStore = [persistenceManager getCustomerStore:_globalStore.customer_default_code];
        
        NSMutableDictionary *paramsData = [[NSMutableDictionary alloc]init];
        [paramsData setObject:ORIGINATOR forKey:@"originator"];
        
        NSMutableDictionary *data = [[NSMutableDictionary alloc]init];
        
        // Offline
        [data setObject:[NSNumber numberWithBool:NO] forKey:@"offline"];
        // Invoice
        [data setObject:_invoice_no forKey:@"invoice"];
        // Customer preference
        [data setObject:[[NSDictionary alloc] initWithObjectsAndKeys:
                               _globalStore.customer_default_code ?: [NSNull null], @"customer_code",
                               customerStore.priceCode ?: [NSNull null], @"customer_priceCode",
                               nil] forKey:@"customerPreference"];
        // Customer
        [data setObject:[persistenceManager getDataStore:CUSTOMER] forKey:@"customer"];
        // PaymentType
        [data setObject:[persistenceManager getDataStore:PAYMENT_TYPE] forKey:@"paymentType"];
        // CashSales
        [data setObject:[persistenceManager getDataStore:CASH_SALES] forKey:@"cashSales"];
        // Carts
        NSArray *cartStores = [persistenceManager getCartStores];
        NSMutableArray *saleCarts = [NSMutableArray array];
        for (CartStore *cartStore in cartStores) {
            PriceStore *priceStore = [persistenceManager getPriceStore:customerStore.priceCode
                                                                itemNo:cartStore.cartProduct.itemNo];
            [saleCarts addObject: [[NSDictionary alloc] initWithObjectsAndKeys:
                                   cartStore.cart_code ?: [NSNull null], @"cart_code",
                                   cartStore.qty ?: [NSNull null], @"qty",
                                   priceStore.priceListCode ?: [NSNull null], @"pricelist_code",
                                   cartStore.cartProduct.itemNo ?: [NSNull null], @"itemNo",
                                   nil]];
        }
        [data setObject:saleCarts forKey:@"carts"];
        [paramsData setObject:data forKey:@"data"];
        
        jsonData = [NSJSONSerialization dataWithJSONObject:paramsData
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:nil];
        NSString *params = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        [service showMessage:self loader:YES message:@"Processing transactions ..." error:NO waitUntilCompleted:YES withCallBack:^ {
            AFHTTPRequestOperation *submitTransactions = [_apiManager submitTransactions:params];
            if (submitTransactions) {
                [submitTransactions start];
            }
        }];
        
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
 * SubmitViewController navigate to pos page
 */
- (void) viewPOSPage {
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
                              cartStore.cartProduct.itemNo,@"product_code",cartStore.qty, @"qty", nil];
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
    [persistenceManager clearCurrentTransaction];
    self.navigationItem.title = @"Payment Received";
    [service showMessage:self loader:NO message:@"Payment received successfully" error:NO
      waitUntilCompleted:NO  withCallBack:^{
          [persistenceManager setDataStore:PRINT_COPY value:data];
          
          _printBtn =[[UIBarButtonItem alloc]  initWithTitle:@"Print" style:UIBarButtonItemStylePlain
                                                      target:self action:@selector(print:)];
          
          _homeBtn =[[UIBarButtonItem alloc]  initWithTitle:@"POS" style:UIBarButtonItemStylePlain
                                                     target:self action:@selector(home:)];
          
          self.navigationItem.leftBarButtonItem = _homeBtn;
          self.navigationItem.rightBarButtonItem = _printBtn;
      }];
}

- (void)home:(id)sender {
    [self viewPOSPage];
}

- (void)print:(id)sender{
    self.navigationItem.title = @"Payment Received";
    [self viewPrintPage];
}


@end
