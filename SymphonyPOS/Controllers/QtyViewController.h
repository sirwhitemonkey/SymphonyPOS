
#import <UIKit/UIKit.h>
#import "ProductStore.h"
#import "RoundedButton.h"

@protocol QtyViewContollerDelegate;


@interface QtyViewController : UIViewController <UITextFieldDelegate>
@property (nonatomic,weak) id<QtyViewContollerDelegate>delegate;
@property (nonatomic,strong) IBOutlet UITextField *qty;
@property (nonatomic,strong) IBOutlet RoundedButton *nextBtn;
@property (nonatomic,strong) IBOutlet UIView *qtyView;

/**
 
 */
- (IBAction)next:(id)sender;

- (void) initialise:(ProductStore*)productStore;

@end

@protocol QtyViewContollerDelegate
- (void) qtyDidCompleted:(QtyViewController*) controller qty: (NSNumber *)qty productStore:(ProductStore*)productStore;

@end

