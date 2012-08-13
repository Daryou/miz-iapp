//
//  APromoView.m
//  Mizoon
//
//  Created by Daryoush Paknad on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "APromoView.h"
#import "Mizoon.h"

@implementation APromoView
@synthesize	promoWebView, webViewHeight;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}



- (id)initWithFrame:(CGRect)frame promoDict: (NSDictionary *) aPromo {
    
	Mizoon	*miz = [Mizoon sharedMizoon];
	
	if (self = [super initWithFrame:frame]) {
//		self.backgroundColor = [UIColor colorWithWhite:0.5 alpha:1.0];
		self.backgroundColor = [UIColor clearColor];

		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;  

		if ([miz isCoupon:aPromo]) {
			promoWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 365.0)]; 

		} else {
			promoWebView = [[UIWebView alloc] initWithFrame:CGRectMake(10, 40, 290, 150)]; 
		}

//		promoWebView.scalesPageToFit = YES;
		promoWebView.backgroundColor = [UIColor whiteColor];  
		
		NSString *html = [aPromo valueForKey:@"content"];  
//		NSLog(@"Html = %@", html );
		[promoWebView loadHTMLString:html baseURL:[NSURL URLWithString:MIZOON_RESTFUL_SERVER]];  

		
		[self addSubview:promoWebView];  
		promoWebView.delegate = self;
		[self sizeToFit];
	}
    return self;
}



- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
	[promoWebView release];
}


#pragma mark UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)triggerView
{
//	NSLog ( @"Client height: %@", [triggerView stringByEvaluatingJavaScriptFromString: @"document.body.clientHeight"] );
	webViewHeight = [[triggerView stringByEvaluatingJavaScriptFromString: @"document.body.clientHeight"] intValue];
	CGRect frame = [self frame];
	frame.size.height = webViewHeight;
	self.frame = frame;
	
	return;
}


@end
