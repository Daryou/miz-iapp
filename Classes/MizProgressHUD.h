//
//  MizProgressHUD.h
//  Mizoon
//
//  Created by Daryoush Paknad on 2/10/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MizoonAppDelegate.h"

@interface MizProgressHUD : UIAlertView {
	UIImage						*backgroundImage;
	UIActivityIndicatorView		*activityIndicator;
	UILabel						*progressMessage;
	MizoonAppDelegate			*appDelegate;
}

@property (nonatomic, assign) UIImage					*backgroundImage;
@property (nonatomic, assign) UIActivityIndicatorView	*activityIndicator;
@property (nonatomic, retain) UILabel					*progressMessage;
@property (nonatomic, assign) MizoonAppDelegate		*appDelegate;

- (id)initWithLabel:(NSString *)text;

@end