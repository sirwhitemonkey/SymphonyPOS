#import <Foundation/Foundation.h>
#import "VisualFeedbackViewController.h"
#import "GlobalStore.h"
#import "APIManager.h"
#import "UILabel+FormattedText.h"
#import "Base64.h"
#include "NSData-AES.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>


@interface Service : NSObject
/*!
 * SharedServices shared instance
 */
+ (Service*) sharedInstance;

/*!
 * SharedServices checking the string  (i.e empty and/or null)
 */
- (BOOL)isEmptyString:(NSString *)input;

/*!
 * SharedServices trimming the string
 */
- (NSString*)trim:(NSString*)input;

/*!
 * SharedServices display message  views
 */
- (void) showMessage:(id)reference loader:(BOOL)loader message:(NSString*)message error:(BOOL)error waitUntilCompleted:(BOOL)
        waitUntilCompleted withCallBack:(void (^)(void))callbackBlock;

/*!
 * SharedServices hide message  views
 */
- (void) hideMessage :(void (^)(void))callbackBlock;

/*!
 * SharedServices display the pin view
 */
- (void) showPinView: (id)reference;

/*!
 * SharedServices basic styling of text fields
 */
- (void) boxInputStyling:(UITextField*)textField;

/*!
 * SharedServices converting hex colors to string colors
 */
- (UIColor *)colorFromHexString:(NSString *)hexString;

/*!
 * SharedServices searching a pattern texts in the label
 */
- (void) searchPatternInLabels:(UILabel*)label searchString:(NSString*)searchString;

/*!
 * SharedServices setting the placeholder
 */
- (void)setPlaceHolder:(id)reference error:(BOOL)error;

/*!
 * SharedServices checking the validity of the email
 */
- (BOOL) checkEmail:(NSString *)email;

/*!
 * SharedServices showing an alert message
 */
- (void)showAlert:(NSString *)title message:(NSString *)message;

/*!
 * SharedServices getting a random strings
 */
- (NSString *) stringsWithLength: (int) len;

/*!
 * SharedServices AES encryption with pass key
 */
- (NSString *)encrypt:(NSString *)encrypt key:(NSString*)theKey;

/*!
 * SharedServices AES decryption with pass key
 */
- (NSString*)decrypt:(NSString *)decrypt key:(NSString*)theKey;

/*!
 * SharedServices sha1 generator
 */
- (NSString*) sha1:(NSString*)input;

/*!
 * SharedServices md5 generator
 */
- (NSString *) md5:(NSString *) input;
@end
