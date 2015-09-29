
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
    
    [self.pin1 becomeFirstResponder];
    
    _onExistingPinCode = true;
    NSString *userPinIdent = [persistenceManager getKeyChain:USER_PIN_IDENT];
    if ([service isEmptyString:userPinIdent]) {
        _onExistingPinCode = false;
    }
    if (_onExistingPinCode) {
        self.info.text = @"Enter pin code";
    } else {
        self.info.text = @"New pin code";
    }
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
   
     _apiManager = [[APIManager alloc] init];
    [_apiManager syncImage:self.logoView url:globalStore.my_custom_logo];
    
    
    NSData *data = [globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [self.view setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
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
   
            pin = [persistenceManager getKeyChain:USER_PIN_IDENT];
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
                    [self viewSyncPage];
                } else {
                    [persistenceManager setDataStore:PIN_LOGGED_IDENT value:PIN_LOGGED_IDENT];
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
                    [persistenceManager setKeyChain:USER_PIN_IDENT  value:loggedPin];
                    [service showMessage:self loader:NO message:@"Pin successfully created" error:NO
                      waitUntilCompleted:NO  withCallBack: ^{
                        [self viewSyncPage];
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

#pragma mark - SyncViewControllerDelegate
- (void)syncDidCompleted:(SyncViewController *)controller {
    DebugLog(@"syncDidCompleted");
    [controller dismissViewControllerAnimated:YES completion:nil];
    
    [persistenceManager setDataStore:PIN_LOGGED_IDENT value:PIN_LOGGED_IDENT];
    [persistenceManager setKeyChain:SYNC_DATE_LAST_UPDATED value:[persistenceManager getDataStore:SYNC_DATE_LAST_UPDATED]];
    if (!_onExistingPinCode) {
        [self viewPOSPage];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) syncDidError:(SyncViewController *)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Private methods
- (void)viewPOSPage {
    [self performSegueWithIdentifier:@"PinPOSSegue" sender:self];
}

/*!
 * PageViewController navigate to sync page
 */
- (void) viewSyncPage {
    SyncViewController *controller = (SyncViewController*)[persistenceManager getView:@"SyncViewController"];
    controller.delegate = self;
    controller.settings = NO;
    [controller setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    [self presentViewController:controller animated:NO completion: ^ {
        [controller sync];
    }];
}

@end
