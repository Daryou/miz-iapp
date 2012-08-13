//
//  PromosController.h
//  Mizoon
//
//  Created by Daryoush Paknad on 5/4/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PromosController : UIViewController   <UITableViewDelegate, UITableViewDataSource>  {
	int selectedRow;
	int	selectedLid;
	int	selectedPrid;
}

@property int selectedRow;
@property int selectedLid;
@property int selectedPrid;

@end
