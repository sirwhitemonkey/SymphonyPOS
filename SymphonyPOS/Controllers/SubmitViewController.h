
#import <UIKit/UIKit.h>
#import "RoundedButton.h"
#import "APIManager.h"
#import "PaymentCustomerViewController.h"
#import "PaymentViewController.h"


@interface SubmitViewController : UIViewController <APIManagerDelegate, UIActionSheetDelegate>

@property (nonatomic,strong) IBOutlet RoundedButton *submitBtn;

- (IBAction)submit:(id)sender;

@end
