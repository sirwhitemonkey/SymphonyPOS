
#import <UIKit/UIKit.h>
#import "RoundedButton.h"
#import "GlobalStore.h"

@protocol SignatureViewControllerDelegate;

@interface SignatureViewController : UIViewController
@property (nonatomic,weak) id<SignatureViewControllerDelegate> delegate;
@property (nonatomic,strong) IBOutlet UIView *signatureView;
@property (nonatomic,strong) IBOutlet RoundedButton *clearSignatureBtn;
@property (nonatomic,strong) IBOutlet RoundedButton *completeSignatureBtn;

- (IBAction)clearSignature:(id)sender;
- (IBAction)completeSignature:(id)sender;

@end

@protocol SignatureViewControllerDelegate
- (void) didSignatureFinished:(SignatureViewController*) controller image:(UIImage*)image;

@end