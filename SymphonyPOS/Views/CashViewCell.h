
#import <UIKit/UIKit.h>
#import "RoundedButton.h"

@interface CashViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UILabel *subTotals;
@property (nonatomic,strong) IBOutlet UILabel *salesPercentageTax;
@property (nonatomic,strong) IBOutlet UILabel *grandTotals;
@property (nonatomic,strong) IBOutlet UITextField *amountPaid;
@property (nonatomic,strong) IBOutlet UITextField *balance;
@property (nonatomic,strong) IBOutlet RoundedButton *nextBtn;

@end
