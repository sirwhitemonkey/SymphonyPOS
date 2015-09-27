

#import "TerminalViewController.h"

@interface TerminalViewController()
@property (nonatomic,strong) NSDictionary *themes;
@end

@implementation TerminalViewController
@synthesize themes = _themes;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    DebugLog(@"viewDidLoad");
    
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Terminal";
    self.navigationItem.hidesBackButton = YES;
    
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    self.terminal_code.text = globalStore.terminal_code;
    self.terminal_name.text = globalStore.terminal_name;
    
    NSData *data = [globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [self.view setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    [self.nextBtn setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"button_submit"]]];
    
}

- (void)didReceiveMemoWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotate{
    return NO;
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations{
   return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}
#endif


#pragma mark - events
- (IBAction)next:(id)sender{

    if ([service isEmptyString:self.terminal_code.text]) {
        [service setPlaceHolder:self.terminal_code error:YES];
        return;
    }
    
    if ([service isEmptyString:self.terminal_name.text]) {
        [service setPlaceHolder:self.terminal_name error:YES];
        return;
    }
    GlobalStore *globalStore = [persistenceManager getGlobalStore];
    globalStore.terminal_name = self.terminal_name.text;
    globalStore.terminal_code = self.terminal_code.text;
    [persistenceManager saveContext];
    [self viewPinPage];
}


#pragma mark - UITextField
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [service setPlaceHolder:textField error:NO];
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
 * TerminalViewController navigate to pin page
 */
- (void) viewPinPage {
    [self performSegueWithIdentifier:@"TerminalPinSegue" sender:self];
}

@end

