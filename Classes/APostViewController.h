//
//  APostViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 3/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import	"Constants.h"

@interface APostViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>   {
	AsyncImageView	*userPic;
	AsyncImageView	*postPhoto;
    UILabel			*nameLabel;
    UILabel			*messageLabel;			// profile labels
	UILabel			*postInfoLabel;
	float			msgHeight;
}

@property float msgHeight;


@end
