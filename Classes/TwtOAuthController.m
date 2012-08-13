    //
//  TwtOAuthController.m
//  Mizoon
//
//  Created by Daryoush Paknad on 9/16/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "TwtOAuthController.h"

@interface TwtOAuthController() // private
- (NSString *) locateAuthPinInWebView: (UIWebView *) webView;
- (void) gotPin: (NSString *) pin;
- (void) denied;


- (void) showActivity: (NSString *) message;
- (void) hideActivity;
@end

@implementation TwtOAuthController
@synthesize	progressAlert;

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView 
{

	
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	Mizoon *miz = [Mizoon sharedMizoon];
	
	_firstLoad = YES;
	
	if (!miz.twtOAuthEngine.OAuthSetup) 
		[miz.twtOAuthEngine requestRequestToken];
	
	_twtWebView = [[UIWebView alloc] initWithFrame: CGRectMake(0, -40.0, 320, 416)];
	
	_twtWebView.alpha = 0.0;
	_twtWebView.delegate = self;
	_twtWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	if ([_twtWebView respondsToSelector: @selector(setDetectsPhoneNumbers:)]) 
		[(id) _twtWebView setDetectsPhoneNumbers: NO];
	
	if ([_twtWebView respondsToSelector: @selector(setDataDetectorTypes:)]) [(id) _twtWebView setDataDetectorTypes: 0];
	
	NSURLRequest *request = miz.twtOAuthEngine.authorizeURLRequest;
	[_twtWebView loadRequest: request];
	
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(pasteboardChanged:) name: UIPasteboardChangedNotification object: nil];
	
	[self.view addSubview: _twtWebView];
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}




#pragma mark Helper

- (void) showActivity: (NSString *) message
{
	progressAlert = [[MizProgressHUD alloc] initWithLabel:message];
	[progressAlert show];
}



- (void) hideActivity
{
	[progressAlert dismissWithClickedButtonIndex:0 animated:YES];
	[progressAlert release];
	
}



//=============================================================================================================================
#pragma mark Actions
- (void) denied {
	[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 1.0];
}

- (void) gotPin: (NSString *) pin 
{
	Mizoon *miz = [Mizoon sharedMizoon];
	
	miz.twtOAuthEngine.pin = pin;
	[miz.twtOAuthEngine requestAccessToken];
	
	[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 1.0];
}

- (void) cancel: (id) sender {
	[self performSelector: @selector(dismissModalViewControllerAnimated:) withObject: (id) kCFBooleanTrue afterDelay: 0.0];
}



//=============================================================================================================================
#pragma mark TwitterEngineDelegate
- (void) requestSucceeded: (NSString *) requestIdentifier {
	NSLog(@"Request %@ succeeded", requestIdentifier);
}

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {
	NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);
}





//=============================================================================================================================
#pragma mark Webview Delegate stuff
- (void) webViewDidFinishLoad: (UIWebView *) webView 
{
	_loading = NO;
	//[self performInjection];
	if (_firstLoad) {
		[_twtWebView performSelector: @selector(stringByEvaluatingJavaScriptFromString:) withObject: @"window.scrollBy(0,200)" afterDelay: 0];
		_firstLoad = NO;
	} else {
		NSString *authPin = [self locateAuthPinInWebView: webView];
		
		if (authPin.length) {
			[self gotPin: authPin];
			[self hideActivity];
			return;
		}
		
		//		NSString					*formCount = [webView stringByEvaluatingJavaScriptFromString: @"document.forms.length"];
		//		
		//		if ([formCount isEqualToString: @"0"]) {
		//			[self showPinCopyPrompt];
		//		}
	}
	
	[self hideActivity];
	
	[UIView beginAnimations: nil context: nil];
	[UIView commitAnimations];
	
	if ([_twtWebView isLoading]) {
		_twtWebView.alpha = 0.0;
	} else {
		_twtWebView.alpha = 1.0;
	}
}

/*********************************************************************************************************
 I am fully aware that this code is chock full 'o flunk. That said:
  *********************************************************************************************************/

- (NSString *) locateAuthPinInWebView: (UIWebView *) webView {
	NSString			*js = @"var d = document.getElementById('oauth-pin'); if (d == null) d = document.getElementById('oauth_pin'); if (d) d = d.innerHTML; if (d == null) {var r = new RegExp('\\\\s[0-9]+\\\\s'); d = r.exec(document.body.innerHTML); if (d.length > 0) d = d[0];} d.replace(/^\\s*/, '').replace(/\\s*$/, ''); d;";
	NSString			*pin = [webView stringByEvaluatingJavaScriptFromString: js];
	
	//	if (pin.length > 0) return pin;
	
	NSString			*html = [webView stringByEvaluatingJavaScriptFromString: @"document.body.innerText"];
	
	if (html.length == 0) return nil;
	
	const char			*rawHTML = (const char *) [html UTF8String];
	int					length = strlen(rawHTML), chunkLength = 0;
	
	for (int i = 0; i < length; i++) {
		if (rawHTML[i] < '0' || rawHTML[i] > '9') {
			if (chunkLength == 7) {
				char				*buffer = (char *) malloc(chunkLength + 1);
				
				memmove(buffer, &rawHTML[i - chunkLength], chunkLength);
				buffer[chunkLength] = 0;
				
				pin = [NSString stringWithUTF8String: buffer];
				free(buffer);
				return pin;
			}
			chunkLength = 0;
		} else
			chunkLength++;
	}
	
	return nil;
}


- (void) webViewDidStartLoad: (UIWebView *) webView {
	//[_activityIndicator startAnimating];
	[self showActivity:@"Connecting..."];
	
	_loading = YES;
	[UIView beginAnimations: nil context: nil];
	[UIView commitAnimations];
}


- (BOOL) webView: (UIWebView *) webView shouldStartLoadWithRequest: (NSURLRequest *) request navigationType: (UIWebViewNavigationType) navigationType {
	NSData				*data = [request HTTPBody];
	char				*raw = data ? (char *) [data bytes] : "";
	
	if (raw && strstr(raw, "cancel=")) {
		[self denied];
		_twtWebView.alpha = 0.0;
		
		return NO;
	}
	if (navigationType != UIWebViewNavigationTypeOther) 
		_twtWebView.alpha = 0.0;
	
	return YES;
}



@end
