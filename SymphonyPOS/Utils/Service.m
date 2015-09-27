
#import "Service.h"

@interface  Service()
@property (nonatomic,strong) VisualFeedBackViewController *vfbViewController;
@end
@implementation Service
@synthesize vfbViewController = _vfbViewController;

+(Service*)sharedInstance {
    static dispatch_once_t oncePredicate;
    static Service *_sharedInstance;
    dispatch_once(&oncePredicate,^{
        [Base64 load];
        _sharedInstance=[[Service alloc]init];
     });
    return _sharedInstance;
}

#pragma mark - Public methods
-(BOOL)isEmptyString:(NSString *)input {
    input = [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (input ==nil || [input isEqualToString:@""] || [input isEqualToString:@" "])
        return YES;
    
    return NO;
}

- (NSString*)trim:(NSString *)input {
    return [input stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void) showMessage:(id)reference loader:(BOOL)loader message:(NSString *)message error:(BOOL)error
        waitUntilCompleted:(BOOL)waitUntilCompleted withCallBack:(void (^)(void))callbackBlock {
   
    dispatch_async(dispatch_get_main_queue(), ^() {
        _vfbViewController = (VisualFeedBackViewController*)[persistenceManager getView:@"VisualFeedBackViewController"];
        _vfbViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [_vfbViewController initialise:loader message:message error:error];
        [_vfbViewController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
        [reference presentViewController:_vfbViewController animated:YES completion: ^ {
            if (!waitUntilCompleted) {
                [self hideMessage:^ {
                    if (callbackBlock != nil) {
                        callbackBlock();
                    }
                }];
            } else {
                if (callbackBlock != nil) {
                    callbackBlock();
                }
            }
        }];

    });
    
    }

- (void) hideMessage :(void (^)(void))callbackBlock  {
    
    if (_vfbViewController) {
        double delayInSeconds = 2.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [_vfbViewController dismissViewControllerAnimated:NO completion: ^ {
                _vfbViewController = nil;
                if (callbackBlock != nil) {
                    callbackBlock();
                }
            }];
        });
    } else {
        if (callbackBlock != nil) {
            callbackBlock();
        }
    }
}

- (void) showPinView:(id)reference {
    UIViewController *controller = [persistenceManager getView:@"PinViewController"];
    [controller setModalPresentationStyle:UIModalPresentationFullScreen];
    [reference presentViewController:controller animated:YES completion:nil];

}


- (void) boxInputStyling:(UITextField *)textField {
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [[UIColor  grayColor] CGColor];
}


-(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void) searchPatternInLabels:(UILabel*)label searchString:(NSString*)searchString {
    NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:searchString options:0 error:nil];
    NSArray *matches = [regEx matchesInString:label.text options:0 range:NSMakeRange(0, label.text.length)];
    
    for (NSTextCheckingResult *result in matches) {
        [label setTextColor:[UIColor redColor] range:result.range];
    }

}

- (void)setPlaceHolder:(id)reference error:(BOOL)error {
    UIColor *color;
    
    if (error) {
        color = [UIColor redColor];
    } else {
        color = [UIColor lightGrayColor];
    }
    
    if ([reference isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField*)reference;
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: color}];
    }
 }

-(BOOL) checkEmail:(NSString *)email {
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$";
    NSString *laxString = @"^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

-(void)showAlert:(NSString *)title message:(NSString *)message {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
}

-(NSString *) stringsWithLength: (int) len {
    NSString *characters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *strings = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [strings appendFormat: @"%C", [characters characterAtIndex: arc4random_uniform([characters length])]];
    }
    return strings;
}

- (NSString *)encrypt:(NSString *)encrypt key:(NSString*)theKey{
    NSData *data = [encrypt dataUsingEncoding: NSASCIIStringEncoding];
    NSData *encryptedData = [data AESEncryptWithPassphrase:theKey];
    return [Base64 encode:encryptedData];
}

- (NSString*)decrypt:(NSString *)decrypt key:(NSString*)theKey{
    NSData	*b64DecData = [Base64  decode:decrypt encoding:NSASCIIStringEncoding];
    NSData *decryptedData = [b64DecData AESDecryptWithPassphrase:theKey];
    return [[NSString alloc] initWithData:decryptedData
                                 encoding:NSASCIIStringEncoding];
}

-(NSString*) sha1:(NSString*)input {
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    [output appendFormat:@"%02x", digest[i]];
    
    return  output;
    
}

@end
