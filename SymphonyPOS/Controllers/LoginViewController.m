

#import "LoginViewController.h"

@interface LoginViewController ()
@property (nonatomic,strong) APIManager *apiManager;
@end

@implementation LoginViewController
@synthesize apiManager = _apiManager;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DebugLog(@"viewDidLoad");
    
    // Test account
    self.username.text = @"Rommel";
    self.password.text = @"rom151";
    
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
    [_apiManager login:self username:self.username.text password:self.password.text];
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

- (void) apiSubmitAuthorisationResponse:(Response *)response {
    DebugLog(@"apiSubmitAuthorisationResponse -> %@", response);
    if (!response.error) {
        [self dissmissView];
    }
    
}

- (void) apiLoginResponse:(Response *)response {
    DebugLog(@"apiLoginResponse -> %@", response);
    
    NSString *loggedUser = [sharedServices trim:[self.username.text lowercaseString]];
    
    NSError *error = nil;
    GlobalItems *globalItems = [MTLJSONAdapter modelOfClass:GlobalItems.class
                                         fromJSONDictionary:response.data error:&error];
    
    if (error) {
        DebugLog(@"apiLoginResponse -> %@",[error description]);
    } else {
        
        GlobalStore *globalStore = [persistenceManager getGlobalStore];
        
        DebugLog(@"apiLoginResponse -> globalStore ->%@",globalStore.themes);
        
        globalStore.my_custom_url = globalItems.my_custom_url;
        globalStore.my_custom_logo = globalItems.my_custom_logo;
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:globalItems.themes
                                                           options:NSJSONWritingPrettyPrinted
                                                             error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        globalStore.themes = jsonString;
        [persistenceManager saveContext];
        
        [persistenceManager setKeyChain:APP_USER_IDENT value:loggedUser];
        [persistenceManager setKeyChain:APP_TOKEN value:response.token];
        
        NSString *key = [sharedServices stringsWithLength:32];
        [persistenceManager setKeyChain:PASSKEY value:key];
        
             
        
        _apiManager.delegate = self;
        [_apiManager submitAuthorisation:self];
        
    }
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

