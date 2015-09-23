

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "APIManager.h"
#import "Product.h"
#import "PriceList.h"
#import "Customer.h"
#import "GlobalItems.h"

@interface PinViewController : UIViewController <UITextFieldDelegate,APIManagerDelegate>

@property (nonatomic,strong) IBOutlet UITextField *pin1;
@property (nonatomic,strong) IBOutlet UITextField *pin2;
@property (nonatomic,strong) IBOutlet UITextField *pin3;
@property (nonatomic,strong) IBOutlet UITextField *pin4;
@property (nonatomic,strong) IBOutlet UILabel *info;
@property (nonatomic,strong) IBOutlet UIImageView *logoView;


@end
