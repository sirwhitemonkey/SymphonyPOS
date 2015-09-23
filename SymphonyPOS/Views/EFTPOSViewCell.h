#import <UIKit/UIKit.h>
#import "RoundedButton.h"

@interface EFTPOSViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UILabel *subTotals;
@property (nonatomic,strong) IBOutlet UILabel *salesPercentageTax;
@property (nonatomic,strong) IBOutlet UILabel *grandTotals;
@property (nonatomic,strong) IBOutlet RoundedButton *nextBtn;

@end
