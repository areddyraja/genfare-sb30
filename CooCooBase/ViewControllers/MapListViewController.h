//
//  MapListViewController.h
//  CooCooBase
//
//  Created by John Scuteri on 7/21/14.
//  Copyright (c) 2014 CooCoo. All rights reserved.
//

#import "BaseViewController.h"
#import "GetContentService.h"
#import "ContentDescription.h"

@protocol OnContentSelectedListener <NSObject>

- (void)onContentDescriptionSelected:(ContentDescription *)selectedContentDescription;

@end

@interface MapListViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id <OnContentSelectedListener> listener;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
