//
//  VScrollerViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 8/9/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface VScrollerViewController : UIViewController {
	BOOL	visible;
	int		pageNum;
}
@property	BOOL visible;
@property	int pageNum;

@end
