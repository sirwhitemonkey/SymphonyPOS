
#import <UIKit/UIKit.h>
#import "RadioButton.h"
#import "RoundedButton.h"
#import "APIManager.h"

@interface PaymentTypeViewController : UIViewController <APIManagerDelegate>
@property (nonatomic,strong) IBOutlet RoundedButton *paymentTypeBtn;
@property (nonatomic,strong) IBOutlet UILabel *offlineMessage;

- (IBAction)paymentTypeAction:(id)sender;
- (IBAction)next:(id)sender;


@end
