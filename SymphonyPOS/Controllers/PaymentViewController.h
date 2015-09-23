

#import <UIKit/UIKit.h>
#import "CashViewCell.h"
#import "CreditCardViewCell.h"
#import "EFTPOSViewCell.h"
#import "APIManager.h"
#import "UILabel+FormattedText.h"
#import "SignatureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DTDevices.h"
#import "NSData-AES.h"

#define kMagicSubtractionNumber 48 // The ASCII value of 0

@interface PaymentViewController : UITableViewController<UITextFieldDelegate, APIManagerDelegate, UIActionSheetDelegate, SignatureViewControllerDelegate>

@property (nonatomic,strong) IBOutlet CashViewCell *cashViewCell;
@property (nonatomic,strong) IBOutlet CreditCardViewCell *creditCardViewCell;
@property (nonatomic,strong) IBOutlet EFTPOSViewCell *eftposViewCell;


- (IBAction)next:(id)sender;

- (IBAction)paymentCreditCardType:(id)sender;

@end
