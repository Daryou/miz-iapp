//
//  AsyncImageView.h
//  Mizoon
//
//  Created by Daryoush Paknad on 2/1/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"ImageCache.h"
#import	"Constants.h"


@interface AsyncImageView : UIView {
	//could instead be a subclass of UIImageView instead of UIView, depending on what other features you want to 
	// to build into this class?
	
	NSURLConnection		*connection; //keep a reference to the connection so we can cancel download in dealloc
	NSMutableData		* data; //keep reference to the data so we can collect it as it downloads
								//but where is the UIImage reference? We keep it in self.subviews - no need to re-code what we have in the parent class
	NSURL				*url;
	UIActivityIndicatorView *piespinner;
}

@property (nonatomic, retain) NSURL *url;
//- (void)loadImageFromURL:(NSURL*)url;
- (void)loadImageFromURL:(NSURL*)cURL withStyle: (UIActivityIndicatorViewStyle) style;
- (UIImage*) image;

@end
