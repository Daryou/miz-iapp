//
//  TwtOAuthController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 9/16/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import	"MizDataManager.h"
#import "TwtOAuthEngine.h"


#define	TWITTER_SERVICE 0
#define	MIZOON_SRV		1
#define	FB_SERVICE		2


@class TwtOAuthEngine;


@interface TwtOAuthController : UIViewController <UIWebViewDelegate, SA_OAuthTwitterEngineDelegate, UIActionSheetDelegate> {
	UIWebView				*_twtWebView;
	BOOL					_loading, _firstLoad;
	UIAlertView				*progressAlert;
}

@property (nonatomic, retain) UIAlertView *progressAlert;



@end
