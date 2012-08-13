//
//  ImageCache.m
//  Mizoon
//
//  Created by Daryoush Paknad on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "ImageCache.h"
#import	"Constants.h"


#define CACHE_TRESH_HOLD	100000    //500000
#define CACHE_SIZE			400000   //2000000

@interface ImageCache(private) 
@end


@implementation ImageCache

static ImageCache *sharedImageCache;

- (id)init {
    if (self = [super init]) {
        _data = [[NSMutableDictionary alloc] init];
    }
    size = 0;

    return self;
}

- (void)dealloc {
    [_data release];
    [super dealloc];
}


+ (ImageCache *)sharedImageCache {
    if (!sharedImageCache) {
        sharedImageCache = [[ImageCache alloc] init];
    }

    return sharedImageCache;
}


- (void) freeCacheSlots {
	
	NSArray *keyArray = [_data allKeys];
	NSUInteger count = [keyArray count];
	NSUInteger	i=0, objSize;
	NSString *key;
	NSRange range;
	
	MizoonLog(@"--------------------------- FREEING IMAGE CHACHE DATA ---------------------------" );

	for (i=0; i < count; i++) {
		key = [keyArray objectAtIndex:i];
		
		range = [key rangeOfString:@"anyone.png"];
		if (range.length>0) {
//			NSLog(@"Skipping key=%@ ", key );
			continue;
		}
		
		
		if (size < CACHE_TRESH_HOLD) 
			break;
		
		objSize = [[_data valueForKey:key] length];
		[_data removeObjectForKey:key];
		 size = size - objSize;
	}
}


- (void)storeData:(NSData *)data forURL:(NSURL *)url {
	
	
    NSString *urlString = [url description];
	
	
	if (size > CACHE_SIZE) {
		[self freeCacheSlots];
	}
		
	
	@try {
		[_data setObject:data forKey:urlString];
//		NSLog(@"Cached  %@", urlString);
	}
	@catch (NSException * e) {
//		NSLog(@"Caught a bad image!  %@", urlString);
	}
	
	size = size + [data length];
//	NSLog(@"Image Cache size=%d  image=%@", size, urlString);
}

- (NSData *)dataForURL:(NSURL *)url {
		
    NSString *urlString = [url description];
	
//	NSLog(@"Returning cached  %@", urlString);

    return [_data valueForKey:urlString];
}

@end
