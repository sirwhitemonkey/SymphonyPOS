
#import "PinViewController.h"


@interface PinViewController ()
/*!
 * PinViweController apiManager, api rest services management
 */
@property (nonatomic,strong) APIManager *apiManager;
/*!
 * PinViewController onExistingPinCode, checks on existing pin code
 */
@property (nonatomic,assign) BOOL onExistingPinCode;
/*!
 * PinViewController pinCode, holds the pincode data
 */
@property (nonatomic,strong) NSString *pinCode;
/*!
 * PinViewController themes, holds the themes dictionary
 */
@property (nonatomic,strong) NSDictionary *themes;

@end

@implementation PinViewController
@synthesize apiManager = _apiManager;
@synthesize onExistingPinCode = _onExistingPinCode;
@synthesize pinCode = _pinCode;
@synthesize themes = _themes;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBarHidden = YES;
    [sharedServices boxInputStyling:self.pin1];
    [sharedServices boxInputStyling:self.pin2];
    [sharedServices boxInputStyling:self.pin3];
    [sharedServices boxInputStyling:self.pin4];
    
     _apiManager = [[APIManager alloc] init];
    
    [self.pin1 becomeFirstResponder];
    
    _onExistingPinCode = true;
    NSString *userPinIdent = [persistenceManager getKeyChain:APP_USER_PIN_IDENT];
    if ([sharedServices isEmptyString:userPinIdent]) {
        _onExistingPinCode = false;
    }
    if (_onExistingPinCode) {
        self.info.text = @"Enter pin code";
    } else {
        self.info.text = @"New pin code";
    }
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
   
    [_apiManager syncImage:self.logoView url:globalStore.my_custom_logo];
    
    
    NSData *data = [globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [self.view setBackgroundColor:[sharedServices colorFromHexString:[_themes objectForKey:@"background"]]];
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    UIResponder* nextResponder;
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ( [finalString length] == 1 ) {
        textField.text =finalString;
        nextResponder = [textField.superview viewWithTag:textField.tag +1];
        if (nextResponder) {
            [nextResponder becomeFirstResponder];
        }
        [self pincodeFiltering];
        return NO;
    }
    if ([finalString length] > 1) {
        nextResponder = [textField.superview viewWithTag:textField.tag +1];
        if (nextResponder) {
            [nextResponder becomeFirstResponder];
        }
        [self pincodeFiltering];
        return NO;
    }
    return YES;
}


# pragma mark - Private methods
/*!
 * PinViewController {private}, filtering the pincodes
 */
- (void) pincodeFiltering {
    NSString *loggedPin = [NSString stringWithFormat:@"%@%@%@%@",self.pin1.text,self.pin2.text,self.pin3.text,self.pin4.text];
    
    DebugLog(@"textFieldDidEndEditing:%@",loggedPin);
    
    if (![sharedServices isEmptyString:self.pin1.text] &&
        ![sharedServices isEmptyString:self.pin2.text] &&
        ![sharedServices isEmptyString:self.pin3.text] &&
        ![sharedServices isEmptyString:self.pin4.text]) {
        
        NSString *pin;
        [self.view endEditing:YES];
        if (_onExistingPinCode) {
   
            pin = [persistenceManager getKeyChain:APP_USER_PIN_IDENT];
            if (![pin isEqualToString:loggedPin]) {
                [sharedServices showMessage:self message:@"Invalid pin code" error:YES withCallBack: ^{
                    [self.pin1 becomeFirstResponder];
                    [self.pin1 setText:@""];
                    [self.pin2 setText:@""];
                    [self.pin3 setText:@""];
                    [self.pin4 setText:@""];
                }];
            } else {
                
                if ([sharedServices isEmptyString:[persistenceManager getKeyChain:API_SYNC_DATE_LAST_UPDATED]]) {
                    [self requestSync];
                } else {
                    [persistenceManager setDataStore:APP_LOGGED_IDENT value:[persistenceManager getKeyChain:APP_USER_IDENT]];
                    
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        } else {
            if ([sharedServices isEmptyString:_pinCode]) {
                _pinCode = loggedPin;
                [self.pin1 setText:@""];
                [self.pin2 setText:@""];
                [self.pin3 setText:@""];
                [self.pin4 setText:@""];
                self.info.text = @"Confirm pin code";
                [self.pin1 becomeFirstResponder];

            } else {
                if ([_pinCode isEqualToString:loggedPin]) {
                    [persistenceManager setKeyChain:APP_USER_PIN_IDENT  value:loggedPin];
                    [sharedServices showMessage:self message:@"Pin successfully created" error:NO withCallBack: ^{
                        [self requestSync];
                    }];
                } else {
                    [sharedServices showMessage:self message:@"Invalid pin . Try it again" error:YES withCallBack: ^ {
                        [self.pin1 setText:@""];
                        [self.pin2 setText:@""];
                        [self.pin3 setText:@""];
                        [self.pin4 setText:@""];
                        [self.pin1 becomeFirstResponder];

                    }];

                }
            }
        }
    }
    
}

#pragma mark - APIManager
- (void)apiRequestError:(NSError *)error {
    DebugLog(@"apiRequestError -> %@", error);
}

-(void)apiSyncResponse:(Response *)response {
    DebugLog(@"apiSyncResponse -> %@", response);
    
    /*
    [persistenceManager updateSync:self response:response];
    
    if (!response.error) {
        [persistenceManager setDataStore:APP_LOGGED_IDENT value:[persistenceManager getKeyChain:APP_USER_IDENT]];
        if (!_onExistingPinCode) {
            [self performSegueWithIdentifier:@"PinPOSSegue" sender:self];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
     */
    
}


#pragma mark - Private methods
/*!
 * PinViewController {private}, sync request
 */
- (void) requestSync {
     _apiManager.delegate = self;
    [_apiManager sync:self];
}

@end
