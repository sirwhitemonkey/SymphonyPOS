

#import <UIKit/UIKit.h>
#import "UILabel+FormattedText.h"
#import "APIManager.h"
#import "DataDefaults.h"
#import "GlobalStore.h"


@interface LoginViewController : UIViewController<APIManagerDelegate, UITextFieldDelegate>

@property(nonatomic,strong) IBOutlet UITextField *username;
@property(nonatomic,strong) IBOutlet UITextField *password;
@property(nonatomic) IBOutlet UILabel *footer;

- (IBAction)signIn:(id)sender;
- (IBAction)forgotPassword:(id)sender;

@end
