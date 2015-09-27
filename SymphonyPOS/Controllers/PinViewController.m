
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
     self.navigationController.navigationBarHidden = YES;
    [service boxInputStyling:self.pin1];
    [service boxInputStyling:self.pin2];
    [service boxInputStyling:self.pin3];
    [service boxInputStyling:self.pin4];
    
     _apiManager = [[APIManager alloc] init];
    _apiManager.delegate = self;
    
    [self.pin1 becomeFirstResponder];
    
    _onExistingPinCode = true;
    NSString *userPinIdent = [persistenceManager getKeyChain:APP_USER_PIN_IDENT];
    if ([service isEmptyString:userPinIdent]) {
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
    [self.view setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if (![service isEmptyString:self.pin1.text] &&
        ![service isEmptyString:self.pin2.text] &&
        ![service isEmptyString:self.pin3.text] &&
        ![service isEmptyString:self.pin4.text]) {
        
        NSString *pin;
        [self.view endEditing:YES];
        if (_onExistingPinCode) {
   
            pin = [persistenceManager getKeyChain:APP_USER_PIN_IDENT];
            if (![pin isEqualToString:loggedPin]) {
                [service showMessage:self loader:NO message:@"Invalid pin code" error:YES
                  waitUntilCompleted:NO withCallBack: ^{
                    [self.pin1 becomeFirstResponder];
                    [self.pin1 setText:@""];
                    [self.pin2 setText:@""];
                    [self.pin3 setText:@""];
                    [self.pin4 setText:@""];
                }];
            } else {
                
                if ([service isEmptyString:[persistenceManager getKeyChain:SYNC_DATE_LAST_UPDATED]]) {
                    // Sync products
                    [service showMessage:self loader:YES message:@"Synchronising products ..." error:NO
                      waitUntilCompleted:YES withCallBack:^ {
                        _apiManager.batchOperation = true;
                        AFHTTPRequestOperation *syncProducts = [_apiManager getProducts:0];
                        if (syncProducts) {
                            [syncProducts start];
                        }
                    }];
                   
                } else {
                     [self dismissViewControllerAnimated:YES completion:nil];
                }
            }
        } else {
            if ([service isEmptyString:_pinCode]) {
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
                    [service showMessage:self loader:NO message:@"Pin successfully created" error:NO
                      waitUntilCompleted:NO  withCallBack: ^{
                        // Sync products
                        [service showMessage:self loader:YES message:@"Synchronising products ..." error:NO
                          waitUntilCompleted:YES withCallBack:^ {
                            _apiManager.batchOperation = true;
                            AFHTTPRequestOperation *syncProducts = [_apiManager getProducts:0];
                            if (syncProducts) {
                                [syncProducts start];
                            }
                        }];
                    }];
                } else {
                    [service showMessage:self loader:NO message:@"Invalid pin . Try it again" error:YES
                      waitUntilCompleted:NO  withCallBack: ^ {
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
- (void)apiRequestError:(NSError *)error response:(Response *)response {
    DebugLog(@"apiRequestError -> %@,%@", error,response);
}

- (void) apiProductsResponse:(Response *)response {
    [persistenceManager syncProducts:_apiManager response:response completedCallback:^ {
        [service hideMessage:^ {
            // TODO  customers
        }];
    }];
    
}


#pragma mark - Private methods


@end
