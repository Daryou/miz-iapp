//
//  PostsViewPhotoCell.h
//  Mizoon
//
//  Created by Daryoush Paknad on 3/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PostsViewCell.h"


@interface PostsViewPhotoCell : PostsViewCell {
	AsyncImageView	*asyncPhoto;

}
- (void)setPhoto: (NSString *) imageLink;

@end
