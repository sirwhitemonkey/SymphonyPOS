

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

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}


#pragma mark - events
- (IBAction)signIn:(id)sender {
    DebugLog(@"signIn");
    
    [self.view endEditing:YES];
    
    if ([sharedServices isEmptyString:self.username.text]) {
        [sharedServices setPlaceHolder:self.username error:YES];
        return;
    }
    
    if ([sharedServices isEmptyString:self.password.text]) {
        [sharedServices setPlaceHolder:self.password error:YES];
        return;
    }
    
    _apiManager.delegate = self;
    
    [persistenceManager setKeyChain:APP_USER_IDENT value:self.username.text];
    [persistenceManager setKeyChain:APP_USER_SECURITY
                               value:[sharedServices sha1:[sharedServices md5:self.password.text]]];
    [[_apiManager  authSubmit:self] start];
}

- (IBAction)forgotPassword:(id)sender {
    DebugLog(@"forgotPassword");
}

#pragma mark - UITextField

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [sharedServices setPlaceHolder:textField error:NO];
}

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
    DebugLog(@"apiRequestError -> %@", error);
    if ([persistenceManager getKeyChain:PASSKEY] != nil ) {
        [persistenceManager clearAllEvents];
    }
}

- (void) apiAuthSubmitResponse:(Response *)response {
    DebugLog(@"apiAuthSubmitResponse -> %@", response);
    
    [persistenceManager setKeyChain:APP_LOGGED_IDENT
                              value:[persistenceManager getKeyChain:APP_USER_IDENT]];
    
    AFHTTPRequestOperation *themes = [_apiManager themes:self group:YES];
    AFHTTPRequestOperation *dataDefaults = [_apiManager dataDefaults:self group:YES];
    
    NSArray *operations = [AFURLConnectionOperation batchOfRequestOperations:@[themes,dataDefaults] progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        DebugLog(@"%i of %i complete",numberOfFinishedOperations,totalNumberOfOperations);
        
    } completionBlock:^(NSArray *operations) {
        DebugLog(@"All operations in batch complete");
        [self dissmissView];
    }];
    
    [[NSOperationQueue mainQueue] addOperations:operations waitUntilFinished:NO];
}

- (void)apiThemesResponse:(Response *)response {
   DebugLog(@"apiThemesResponse -> %@", response);
}

- (void) apiDataDefaultsResponse:(Response *)response {
    DebugLog(@"apiDataDefaultsResponse -> %@", response);
    
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

