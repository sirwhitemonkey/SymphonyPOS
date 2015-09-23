

#import <UIKit/UIKit.h>
#import "GlobalStore.h"

@interface TerminalViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic,strong) IBOutlet UITextField *terminal_name;
@property (nonatomic,strong) IBOutlet UITextField *terminal_code;

@property (nonatomic,strong) IBOutlet UIButton *nextBtn;

- (IBAction)next:(id)sender;

@end
