
#import <UIKit/UIKit.h>
#import "RoundedButton.h"

#define CARD_VISA 100
#define CARD_MASTERCARD 101
#define CARD_AMERICANEXPRESS 102

@interface CreditCardViewCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *subTotals;
@property (nonatomic,strong) IBOutlet UILabel *salesPercentageTax;
@property (nonatomic,strong) IBOutlet UILabel *grandTotals;
@property (nonatomic,strong) IBOutlet RoundedButton *cardType;
@property (nonatomic,strong) IBOutlet UITextField *cardHolderName;
@property (nonatomic,strong) IBOutlet UITextField *creditCardNumber;
@property (nonatomic,strong) IBOutlet UITextField *expiryDateMonth;
@property (nonatomic,strong) IBOutlet UITextField *expiryDateYear;
@property (nonatomic,strong) IBOutlet UITextField *securityCode;
@property (nonatomic,strong) IBOutlet RoundedButton *nextBtn;
@property (nonatomic,strong) IBOutlet UIImageView *signatureView;
@property (nonatomic,strong) IBOutlet UILabel *provideSignature;
@property (nonatomic, strong) IBOutlet UIImageView *dtConnectionState;
@property (nonatomic, strong) IBOutlet UIButton *batteryBtn;

@end
