//
//  MizProgressHUD.m
//  Mizoon
//
//  Created by Daryoush Paknad on 2/10/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import "MizProgressHUD.h"


@implementation MizProgressHUD
@synthesize backgroundImage, activityIndicator, progressMessage, appDelegate;
	
- (id)initWithLabel:(NSString *)text {
	
	if (self = [super init]) {
//		self.backgroundColor = [UIColor clearColor];
//		self.opaque = YES;
		
		self.appDelegate = [[UIApplication sharedApplication] delegate];

		progressMessage = [[UILabel alloc] initWithFrame:CGRectZero];
		progressMessage.textColor = [UIColor whiteColor];
		progressMessage.backgroundColor = [UIColor clearColor];
		progressMessage.text = text;
		[self addSubview:progressMessage];

		activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[activityIndicator startAnimating];
		[self addSubview:activityIndicator];

		self.backgroundImage = [UIImage imageNamed:@"MizProgressHUDBkg.png"];
	}

	return self;
}

- (void)drawRect:(CGRect)rect {
	CGSize backGroundImageSize = self.backgroundImage.size;
	[backgroundImage drawInRect:CGRectMake(0, 0, backGroundImageSize.width, backGroundImageSize.height) blendMode:kCGBlendModeNormal alpha:0.0];
}

- (void)layoutSubviews {
	[progressMessage sizeToFit];

	CGRect textRect = progressMessage.frame;
	textRect.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(textRect)) / 2;
	textRect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(textRect)) / 2;
	textRect.origin.y += 30.0;

	progressMessage.frame = textRect;

	CGRect activityRect = activityIndicator.frame;
	activityRect.origin.x = (CGRectGetWidth(self.bounds) - CGRectGetWidth(activityRect)) / 2;
	activityRect.origin.y = (CGRectGetHeight(self.bounds) - CGRectGetHeight(activityRect)) / 2;
	activityRect.origin.y -= 10.0;

	activityIndicator.frame = activityRect;
	[self bringSubviewToFront:activityIndicator];
}

- (void)show {
	[super show];
	CGSize backGroundImageSize = self.backgroundImage.size;
	self.bounds = CGRectMake(0, 0, backGroundImageSize.width, backGroundImageSize.height);
	[self.appDelegate setAlertRunning:YES];
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated {
	[super dismissWithClickedButtonIndex:buttonIndex animated:animated];
	[self.appDelegate setAlertRunning:NO];
}

- (void)dealloc {
	[activityIndicator release];
	[progressMessage release];
	[super dealloc];
}

@end
