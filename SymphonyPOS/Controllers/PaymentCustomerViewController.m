
#import "PaymentCustomerViewController.h"

@interface PaymentCustomerViewController ()
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@end

@implementation PaymentCustomerViewController
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Customer";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    _globalStore = [persistenceManager getGlobalStore];
    
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    [self.view setBackgroundColor:[sharedServices colorFromHexString:[_themes objectForKey:@"background"]]];
    [self.tableView setBackgroundColor:[sharedServices colorFromHexString:[_themes objectForKey:@"background"]]];
    [self.nextBtn setBackgroundColor:[sharedServices colorFromHexString:[_themes objectForKey:@"button_submit"]]];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.contentView setBackgroundColor:[sharedServices colorFromHexString:[_themes objectForKey:@"background"]]];
    
    NSDictionary *customer =[persistenceManager getDataStore:CUSTOMER];
    if (customer) {
        self.name.text = [customer objectForKey:@"customerName"];
        self.phone.text = [customer objectForKey:@"customerPhone"];
        self.email.text = [customer objectForKey:@"customerEmail"];
        self.pono.text = [customer objectForKey:@"customerPono"];
        self.comments.text = [customer objectForKey:@"customerComments"];
    }

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

#pragma mark - IBActions
- (IBAction)next:(id)sender {
    [self.view endEditing:YES];
    if ([sharedServices isEmptyString:self.name.text]) {
        [sharedServices setPlaceHolder:self.name error:YES];
        return;
    }
    if (![sharedServices isEmptyString:self.email.text]) {
        if (![sharedServices checkEmail:self.email.text]) {
            [sharedServices showMessage:self message:@"Invalid email address" error:YES
                           withCallBack:nil];
            return;
        }
    }
    self.navigationItem.title = @"Customer";
    
    NSDictionary *data = [[NSDictionary alloc] initWithObjectsAndKeys:self.name.text , @"customerName",
            self.phone.text ,@"customerPhone",
            self.email.text ,@"customerEmail",
            self.pono.text ,@"customerPono",
            self.comments.text, @"customerComments",
            nil];
    [persistenceManager setDataStore:CUSTOMER value:data];
    [self viewPaymentTypeSegue];
}

#pragma mark - UITextField
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [sharedServices setPlaceHolder:textField error:NO];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField.tag == 0) { // Customer name
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHA_CHARACTERS] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    
    return NO;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.view endEditing:YES];
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
/*!
 * PaymentCustomerController navigating to payment type page
 */
- (void) viewPaymentTypeSegue {
    [self performSegueWithIdentifier:@"PaymentTypeSegue" sender:self];
}

- (void) willEnterForegroundNotification {
    [sharedServices showPinView:self];
}

@end
