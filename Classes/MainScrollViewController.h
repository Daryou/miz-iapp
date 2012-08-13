//
//  MainScrollViewController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 8/5/10.
//  Copyright 2010 Mizoon. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MainScrollViewController : UIViewController <UIScrollViewDelegate>{
	IBOutlet UIScrollView	*mainScrollView;
	UIPageControl			*pageControl;
	NSMutableArray			*viewControllers;
	int						currentPage;
}
@property (nonatomic, retain) IBOutlet UIScrollView			*mainScrollView;
@property (nonatomic, retain) IBOutlet UIPageControl		*pageControl;
@property (nonatomic, retain)  NSMutableArray				*viewControllers;
@property	int currentPage;

@end
