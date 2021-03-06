
/*
     File: APLWebViewController.m
 Abstract: The view controller for hosting the UIWebView feature of this sample.
 
  Version: 2.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "APLWebViewController.h"
#import "APLPrintPageRenderer.h"


@interface APLWebViewController ()
@property (nonatomic,strong) GlobalStore *globalStore;
@property (nonatomic,strong) NSDictionary *themes;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *printButton;

@end



@implementation APLWebViewController
@synthesize globalStore = _globalStore;
@synthesize themes = _themes;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Invoice Receipt";
    
    _globalStore = [persistenceManager getGlobalStore];
    NSData *data = [_globalStore.themes dataUsingEncoding:NSUTF8StringEncoding];
    _themes = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    [self.view setBackgroundColor:[service colorFromHexString:[_themes objectForKey:@"background"]]];
    
    NSDictionary *printCopy =[persistenceManager getDataStore:@"printCopy"];
    NSString *invoiceNo = [printCopy objectForKey:@"invoiceNo"];
    NSDictionary *customer = [printCopy objectForKey:@"customer"];
    NSArray *carts = [printCopy objectForKey:@"carts"];
    NSString *paymentType = [printCopy objectForKey:@"paymentType"];
    NSDictionary *cashSales = [printCopy objectForKey:@"cashSales"];
    
    NSString *currency = [cashSales objectForKey:@"currency"];
    NSNumber *subTotals = [cashSales objectForKey:@"subTotals"];
    NSNumber *salesPercentageTax = [cashSales objectForKey:@"salesPercentageTax"];
    NSNumber *grandTotals = [cashSales objectForKey:@"grandTotals"];

    
    NSString *receipts = @"<html><head></head><body><table border='0'>";
    receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4 align=left>Invoice:%@</td></tr>",receipts,invoiceNo];
    
    NSDate *currentDateTime = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateInString = [dateFormatter stringFromDate:currentDateTime];

    receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4 align='left'>Date:%@</td></tr>",receipts,dateInString];
    receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4><br/></td></tr>",receipts];
    receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4 align='left'>Customer:%@</td></tr>",receipts,[customer objectForKey:@"customerName"]];
    receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4 align='left'>Phone:%@</td></tr>",receipts,[customer objectForKey:@"customerPhone"]];
    receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4 align='left'>Email:%@</td></tr>",
                receipts,[customer objectForKey:@"customerEmail"]];
     receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4><br/><br/></td></tr>",receipts];
    receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4 align='left'>Payment type:%@</td></tr>",receipts,paymentType];
     receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4><br/><br/></td></tr>",receipts];
    receipts = [NSString stringWithFormat:@"%@<tr><td>Product</td><td>Qty</td><td>Unit Price</td><td>Amount</td></tr>",receipts];
    
    
    CustomerStore *customerStore = [persistenceManager getCustomerStore:[printCopy objectForKey:@"customer_code"]];
    for (NSDictionary *cart  in carts) {
        ProductStore *productStore = [persistenceManager getProductStore:[cart objectForKey:@"product_code"]];
        PriceStore *priceStore = [persistenceManager  getPriceStore:customerStore.priceCode
                                                                          itemNo:[cart objectForKey:@"product_code"]];
        NSNumber *qty =[cart objectForKey:@"qty"];
        float amount = [priceStore.unitPrice floatValue] * [qty floatValue];
        receipts = [NSString stringWithFormat:@"%@<tr><td>%@</td><td>%ld</td><td>%@%.2f</td><td>%@%.2f</td></tr>",receipts,
                    productStore.desc, (long)[qty integerValue], currency,[priceStore.unitPrice floatValue] ,currency,amount];
        
    }
   
    receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4 align='Right'>SubTotals:<b>%@%.2f</b></td></tr>",receipts,currency,[subTotals floatValue]];
    receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4 align='Right'>SalesTax:<b>%@%.2f</b></td></tr>",receipts,currency,[salesPercentageTax floatValue]];
    receipts = [NSString stringWithFormat:@"%@<tr><td colspan=4 align='Right'>Totals:<b>%@%.2f</b></td></tr>",receipts,currency,[grandTotals floatValue]];
    receipts = [NSString stringWithFormat:@"%@</table></body></html>",receipts];
    
    //self.webView.userInteractionEnabled = NO;
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView loadHTMLString: receipts baseURL: nil];
    [[self.webView scrollView] setBounces:NO];
    
    if(![UIPrintInteractionController isPrintingAvailable]){
        self.printButton.enabled = NO;
    }
}


- (void)viewWillAppear:(BOOL)animated {
    // Set self as the web view's delegate when the view is shown; use the delegate methods to toggle display of the network activity indicator.
    [super viewWillAppear:animated];
    self.webView.delegate = self;
}


- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.webView stopLoading];	// In case the web view is still loading its content.
    self.webView.delegate = nil;	// Disconnect the delegate as the webview is hidden.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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


#pragma mark - UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    // Starting the load, show the activity indicator in the status bar.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView{
    // Finished loading, hide the activity indicator in the status bar.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    // Load error, hide the activity indicator in the status bar.
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // Report the error inside the webview.
    NSString* errorString = [NSString stringWithFormat:
                            @"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\"><html><head><meta http-equiv='Content-Type' content='text/html;charset=utf-8'><title></title></head><body><div style='width: 100%%; text-align: center; font-size: 36pt; color: red;'>An error occurred:<br>%@</div></body></html>",
                             error.localizedDescription];
    [self.webView loadHTMLString:errorString baseURL:nil];
}


#pragma mark - Printing


- (IBAction)printWebPage:(id)sender{
    UIPrintInteractionController *controller = [UIPrintInteractionController sharedPrintController];
    if(!controller){
        NSLog(@"Couldn't get shared UIPrintInteractionController!");
        return;
    }
    
    UIPrintInteractionCompletionHandler completionHandler =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            NSLog(@"FAILED! due to error in domain %@ with error code %ld", error.domain, (long)error.code);
        }
    };
    
    
    // Obtain a printInfo so that we can set our printing defaults.
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    // This application produces General content that contains color.
    printInfo.outputType = UIPrintInfoOutputGeneral;
    // We'll use the URL as the job name.
   //printInfo.jobName = [self.urlField text];
    // Set duplex so that it is available if the printer supports it. We are
    // performing portrait printing so we want to duplex along the long edge.
    printInfo.duplex = UIPrintInfoDuplexLongEdge;
    // Use this printInfo for this print job.
    controller.printInfo = printInfo;
    
    // Be sure the page range controls are present for documents of > 1 page.
    controller.showsPageRange = YES;
    
    // This code uses a custom UIPrintPageRenderer so that it can draw a header and footer.
    APLPrintPageRenderer *myRenderer = [[APLPrintPageRenderer alloc] init];
    // The APLPrintPageRenderer class provides a jobtitle that it will label each page with.
    myRenderer.jobTitle = printInfo.jobName;
    // To draw the content of each page, a UIViewPrintFormatter is used.
    UIViewPrintFormatter *viewFormatter = [self.webView viewPrintFormatter];
    
#if SIMPLE_LAYOUT
    /*
     For the simple layout we simply set the header and footer height to the height of the
     text box containing the text content, plus some padding.
     
     To do a layout that takes into account the paper size, we need to do that
     at a point where we know that size. The numberOfPages method of the UIPrintPageRenderer
     gets the paper size and can perform any calculations related to deciding header and
     footer size based on the paper size. We'll do that when we aren't doing the simple
     layout.
     */
    NSDictionary *sizeWithAttributes = @{NSFontAttributeName: [UIFont fontWithName:@"Helvetica" size:HEADER_FOOTER_TEXT_HEIGHT]};

    CGSize titleSize = [myRenderer.jobTitle sizeWithAttributes:sizeWithAttributes];
    myRenderer.headerHeight = myRenderer.footerHeight = titleSize.height + HEADER_FOOTER_MARGIN_PADDING;
#endif
    [myRenderer addPrintFormatter:viewFormatter startingAtPageAtIndex:0];
    // Set our custom renderer as the printPageRenderer for the print job.
    controller.printPageRenderer = myRenderer;
    
    /*
     The method we use to present the printing UI depends on the type of UI idiom that is currently executing. Once we invoke one of these methods to present the printing UI, our application's direct involvement in printing is complete. Our custom printPageRenderer will have its methods invoked at the appropriate time by UIKit.
     */
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [controller presentFromBarButtonItem:self.printButton animated:YES completionHandler:completionHandler];  // iPad
    }
    else {
        [controller presentAnimated:YES completionHandler:completionHandler];  // iPhone
    }
}


#pragma - Text field delegate

// When the "Done" button is clicked, dismiss the keyboard and load the URL.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    NSString *URLString = [textField text];
    NSString *httpPrefix = @"http://";
    if (![URLString hasPrefix:httpPrefix])
    {
        URLString = [httpPrefix stringByAppendingString:URLString];
    }
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:URLString]]];
    return YES;
}

#pragma mark - Private methods
- (void) willEnterForegroundNotification {
    [service showPinView:self];
}

@end

