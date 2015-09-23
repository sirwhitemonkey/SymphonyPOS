
#import "QtyViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface QtyViewController ()
@property (nonatomic,strong) ProductStore *currentProductStore;
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@end

@implementation QtyViewController
@synthesize delegate;
@synthesize currentProductStore = _currentProductStore;
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     self.qtyView.layer.borderWidth = 1;
    self.qtyView.layer.borderColor =[[UIColor  grayColor] CGColor];
    
    _globalStore = [persistenceManager getGlobalStore];
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
   
    [self.qtyView setBackgroundColor:[sharedServices colorFromHexString:
                                                    [_themes objectForKey:@"background"]]];
    [self.nextBtn setBackgroundColor:[sharedServices colorFromHexString:
                                      [_themes objectForKey:@"button_submit"]]];
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)initialise:(ProductStore *)productStore {
    _currentProductStore = productStore;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self registerNotifications];
}

- (void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - Notifications

- (void)registerNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForegroundNotification)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
}

#pragma mark - UITextField
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *finalString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if ( [finalString length] <= 3 ) {
        
        return YES;
    }
    return NO;
}


#pragma mark - IBActions
- (IBAction)next:(id)sender {
    if ([sharedServices isEmptyString:self.qty.text]) {
        self.qty.text = @"1";
    }
   
    [self.delegate qtyDidCompleted:self qty:[NSNumber numberWithLong:[self.qty.text integerValue]]
                      productStore:_currentProductStore];
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Private methods
- (void) willEnterForegroundNotification {
    [sharedServices showPinView:self];
}


@end
