
#import <UIKit/UIKit.h>
#import "RoundedButton.h"

@interface PaymentCustomerViewController : UITableViewController<UITextFieldDelegate, UIScrollViewDelegate>

@property (nonatomic,strong) IBOutlet UITextField *name;
@property (nonatomic,strong) IBOutlet UITextField *phone;
@property (nonatomic,strong) IBOutlet UITextField *email;
@property (nonatomic,strong) IBOutlet UITextField *pono;
@property (nonatomic,strong) IBOutlet UITextField *comments;
@property (nonatomic,strong) IBOutlet RoundedButton *nextBtn;

- (IBAction)next:(id)sender;

@end
