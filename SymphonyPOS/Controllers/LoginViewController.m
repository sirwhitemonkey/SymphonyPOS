

#import "LoginViewController.h"

@interface LoginViewController ()
@property (nonatomic,strong) APIManager *apiManager;
@end

@implementation LoginViewController
@synthesize apiManager = _apiManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    DebugLog(@"viewDidLoad");
    
    // Test account
    self.username.text = @"ronaldo";
    self.password.text = @"ronaldo12345";
    
    _apiManager = [[APIManager alloc] init];
    _apiManager.delegate = self;
    
    self.navigationController.navigationBarHidden = YES;
    self.footer.text = APP_FOOTER;
    [self.footer setTextColor:[UIColor greenColor] range:NSMakeRange(19,15)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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


#pragma mark - events
- (IBAction)signIn:(id)sender {
    DebugLog(@"signIn");
    
    [self.view endEditing:YES];
    
    if ([service isEmptyString:self.username.text]) {
        [service setPlaceHolder:self.username error:YES];
        return;
    }
    
    if ([service isEmptyString:self.password.text]) {
        [service setPlaceHolder:self.password error:YES];
        return;
    }
    
    [persistenceManager setKeyChain:USER_IDENT value:self.username.text];
    [persistenceManager setKeyChain:USER_SECURITY
                               value:[service sha1:[service md5:self.password.text]]];
    
    [service showMessage:self loader:YES message:@"Authenticating ..." error:NO
      waitUntilCompleted:YES withCallBack:nil];
    
    AFHTTPRequestOperation *authSubmit = [_apiManager  authSubmit];
     if (authSubmit) {
        [authSubmit start];
    }
}

- (IBAction)forgotPassword:(id)sender {
    DebugLog(@"forgotPassword");
}

#pragma mark - UITextField

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [service setPlaceHolder:textField error:NO];
}


#pragma mark - APIManager
- (void)apiRequestError:(NSError *)error response:(Response *)response {
    DebugLog(@"apiRequestError -> %@,%@", error,response);
    if (!_apiManager.batchOperation) {
        [persistenceManager clearCache];
        [service hideMessage:^ {
            [service showMessage:self loader:NO message:(NSString*)response.data error:YES
              waitUntilCompleted:NO withCallBack:nil];
        }];
    }
}

- (void) apiAuthSubmitResponse:(Response *)response {
    DebugLog(@"apiAuthSubmitResponse -> %@", response);
    
    [persistenceManager setKeyChain:USER_LOGGED_IDENT
                              value:[persistenceManager getKeyChain:USER_IDENT]];
    
    [service hideMessage:^ {
   
       _apiManager.batchOperation = true;
        [service showMessage:self loader:YES message:@"Updating settings ..." error:NO
          waitUntilCompleted:YES withCallBack:^ {
       
              AFHTTPRequestOperation *themes = [_apiManager themes];
              AFHTTPRequestOperation *dataDefaults = [_apiManager dataDefaults];
              
              if (themes && dataDefaults) {
                  NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:@[themes,dataDefaults] progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
                      DebugLog(@"%lu of %lu complete",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
                      
                  } completionBlock:^(NSArray *operations) {
                      _apiManager.batchOperation = false;
                      DebugLog(@"All operations in batch complete");
                      [persistenceManager updateSettingsBundle];
                      [service hideMessage:^ {
                          [self dissmissView];
                      }];
                  }];
                  
                  [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
              }
          }];
       
    }];
   
}

- (void)apiThemesResponse:(Response *)response {
   DebugLog(@"apiThemesResponse -> %@", response);
    
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:(NSDictionary*)response.data
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    globalStore.themes = jsonString;
    [persistenceManager saveContext];

}

- (void) apiDataDefaultsResponse:(Response *)response {
    DebugLog(@"apiDataDefaultsResponse -> %@", response);
    
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    DataDefaults *dataDefaults = [MTLJSONAdapter modelOfClass:DataDefaults.class fromJSONDictionary:(NSDictionary*)response.data error:nil];
    globalStore.sales_percentage_tax = dataDefaults.sales_percentage_tax;
    globalStore.last_order_number = dataDefaults.last_order_number;
    globalStore.prefix = dataDefaults.prefix;
    globalStore.prefix_number_length = dataDefaults.prefix_number_length;
    globalStore.customer_default_code =  dataDefaults.customer_default_code;
    globalStore.customer_default_code_copy =dataDefaults.customer_default_code;
    if ([globalStore.days_sync_interval integerValue] == 0) {
        globalStore.days_sync_interval = [NSNumber numberWithInt:30];
    }
    [persistenceManager saveContext];
}


#pragma mark - Private methods
/*!
 * LoginViewController dismissing the current view
 */
- (void) dissmissView {
     double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}
@end

