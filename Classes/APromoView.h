 //
//  APromoView.h
//  Mizoon
//
//  Created by Daryoush Paknad on 5/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface APromoView : UIView  <UIWebViewDelegate> {
	UIWebView	*promoWebView;
	NSInteger	webViewHeight;
}

@property (nonatomic, retain) UIWebView * promoWebView;
@property NSInteger webViewHeight;

- (id)initWithFrame:(CGRect)frame promoDict: (NSDictionary *) aPromo;


@end
