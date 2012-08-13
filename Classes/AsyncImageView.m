//
//  AsyncImageView.m
//  Mizoon
//
//  Created by Daryoush Paknad on 2/1/10.
//  http://www.markj.net/iphone-asynchronous-table-image/
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"

@interface AsyncImageView()   // private
- (BOOL) getCachedImage: (NSURL *)url;
@end


@implementation AsyncImageView
@synthesize	url;

- (void)dealloc {
	[connection cancel]; //in case the URL is still downloading
	[connection release];
	
//	NSLog(@"loadImageFromURL(4)--------------------->cURL ref count = %d", [url retainCount]);

//	[url release]; 
	[piespinner release];
	
	[data release]; 
    [super dealloc];
}


- (void)loadImageFromURL:(NSURL*)cURL withStyle: (UIActivityIndicatorViewStyle) style
{
	if (connection!=nil) { 
		[connection release]; 
	} 
	
	//in case we are downloading a 2nd image
	if (data!=nil) { 
		[data release]; 
	}
	self.url = cURL;
	
	// check the image cache 
	if ([self getCachedImage:cURL]) {
//		NSLog(@"Returning cached  %@", [cURL description]);
		return;
	}
	
	if ([[self subviews] count]>0) {
		//then this must be another image, the old one is still in subviews
		[[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
	}
	
	NSURLRequest* request = [NSURLRequest requestWithURL:cURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];

	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //notice how delegate set to self object
	//TODO error handling, what if connection is nil?

	
//	UIActivityIndicatorView *piespinner;
//	piespinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
	piespinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:style];

	piespinner.center = CGPointMake(self.center.x, self.center.y);
	
	[self addSubview:piespinner];
	[piespinner startAnimating];
}


- (BOOL) getCachedImage: (NSURL *)cURL {
	ImageCache *imageChache = [ImageCache sharedImageCache];
    NSString *urlString = [cURL description];  // xxx
	UIImageView* imageView;
	
	NSData *cachedData = [imageChache dataForURL:cURL];
	if ( !cachedData ) {
		if ( [urlString rangeOfString:ANYONE_PICTURE].location == NSNotFound ) {
//			[urlString release];
			return FALSE;
		}
	}
//	if (cachedData) {
//		NSLog(@"CACHED DATA for %@", urlString);
//	}
	
	if (connection!=nil) { 
		[connection cancel];
		connection=nil;
	}
	
	if ([[self subviews] count]>0) {
		//then this must be another image, the old one is still in subviews
		[[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
	}
	
	if ([urlString rangeOfString:ANYONE_PICTURE].location != NSNotFound) {
		imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"anyone.png"]] autorelease];
	} else {
		//make an image view for the image
		imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:cachedData]] autorelease];
	}
	//make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight );
	[self addSubview:imageView];
	imageView.frame = self.bounds;
	
	
	[piespinner removeFromSuperview];

	[imageView setNeedsLayout];
	[self setNeedsLayout];
	
//	[urlString release];
	
	return TRUE;
}


//the URL connection calls this repeatedly as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; } 
	[data appendData:incrementalData];
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	
	/*************************************/
	ImageCache *imageChache = [ImageCache sharedImageCache];
	[imageChache storeData:data forURL:self.url];
	
	/*************************************/

	//so self data now has the complete image 
	[connection release];
	connection=nil;
	if ([[self subviews] count]>0) {
		//then this must be another image, the old one is still in subviews
		[[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
	}
	
	//make an image view for the image
	UIImageView* imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithData:data]] autorelease];
	//make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
	imageView.contentMode = UIViewContentModeScaleAspectFit;
	imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight );
	imageView.tag = kAsyncImageTag;
	
	[self addSubview:imageView];
	imageView.frame = self.bounds;
	
	[piespinner removeFromSuperview];

	[imageView setNeedsLayout];
	[self setNeedsLayout];
	
	[data release]; //don't need this any more, its in the UIImageView now
	data=nil;
	
	
	/**********************
	CGFloat size = [imageView.image size].width * [imageView.image size].height;
	NSLog(@"-----------h=%f-----w=%f---------------Image size=%f", [imageView.image size].height, [imageView.image size].width, size);
	**********************/
}

//just in case you want to get the image directly, here it is in subviews
- (UIImage*) image {
	UIImageView* iv = [[self subviews] objectAtIndex:0];
	return [iv image];
}

@end
