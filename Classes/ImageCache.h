//
//  ImageCache.h
//  Mizoon
//
//  Created by Daryoush Paknad on 1/6/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ImageCache : NSObject {
@private
    NSMutableDictionary *_data;
	NSUInteger			size;
}

+ (ImageCache *)sharedImageCache;
- (void) freeCacheSlots;

- (void)storeData:(NSData *)data forURL:(NSURL *)url;
- (NSData *)dataForURL:(NSURL *)url;

@end
